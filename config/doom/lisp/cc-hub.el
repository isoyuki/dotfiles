;;; lisp/cc-hub.el -*- lexical-binding: t; -*-
;;
;; SPC l command centre. Claude Code runs the agents, cc-hubd (127.0.0.1:7777)
;; polls and keeps state, and these buffers watch, act and join on the issue key.
;; Every fetch is async (curl or claude/gh subprocesses). Buffers draw from a
;; cache at once, then refresh. Secrets come from auth-source and reach curl on
;; stdin, never in argv. Keys are listed in ~/dotfiles/README.md.

(require 'cl-lib)
(require 'json)
(require 'auth-source)
(require 'tabulated-list)
(require 'subr-x)
(require 'ansi-color)
(require 'url-parse)
(require 'url-util)

(defvar vterm-shell)
(defvar vterm-max-scrollback)
(defvar vterm-kill-buffer-on-exit)
(defvar ghostel--process)
(defvar ghostel-kill-buffer-on-exit)
(declare-function vterm "vterm")
(declare-function ghostel-exec "ghostel")
(declare-function magit-git-string "magit-git")
(declare-function magit-diff-range "magit-diff")
(declare-function forge-visit-topic-from-url "forge-commands")
(declare-function svg-lib-tag "svg-lib")
(declare-function org-fold-show-all "org-fold")
(defvar cc-hub--issues-source)
(defvar cc-hub--procs-source)
(declare-function xwidget-webkit-browse-url "xwidget")
(declare-function xwidget-webkit-current-session "xwidget")
(declare-function xwidget-webkit-goto-uri "xwidget")
(declare-function xwidget-buffer "xwidget")
(declare-function xwidget-webkit-edit-mode "xwidget")
(declare-function evil-emacs-state "evil-states")
(declare-function +workspace-buffer-list "workspaces/autoload/workspaces")
(declare-function persp-add-buffer "persp-mode")
(declare-function projectile-relevant-known-projects "projectile")

(defgroup cc-hub nil "Agent cockpit." :group 'tools)

(defcustom cc-hub-url "http://127.0.0.1:7777" "Base URL of cc-hubd." :type 'string)
(defcustom cc-hub-terminal 'ghostel
  "Terminal for attach and process buffers: `ghostel' or `vterm'."
  :type '(choice (const ghostel) (const vterm)))
(defcustom cc-hub-datadog-site "datadoghq.com"
  "Datadog site. Keys: auth-source host api.SITE, users \"api\" and \"app\"." :type 'string)
(defcustom cc-hub-datadog-query "status:alert"
  "Monitor search query, e.g. \"status:alert team:my-team\"." :type 'string)
(defcustom cc-hub-octopus-url nil
  "Octopus server URL. Key: auth-source host of this URL." :type '(choice (const nil) string))
(defcustom cc-hub-octopus-space "Spaces-1" "Octopus space ID." :type 'string)
(defcustom cc-hub-opal-url "https://app.opal.dev/requests"
  "Opal web page for access requests. Creation stays in the web UI: MFA blocks CLI and API."
  :type 'string)
(defcustom cc-hub-project-procs nil
  "Alist of (PROJECT-ROOT . SPECS) for repos without a .cc-procs.el file.
SPECS has the same shape as .cc-procs.el: a list of (NAME COMMAND &rest PLIST),
where PLIST takes :dir (subdirectory) and :auto (start on project switch)."
  :type '(alist :key-type directory :value-type sexp))

(defcustom cc-hub-mcp-prefix nil
  "Tool name prefix of the MCP gateway for Slack, Calendar, Linear and Datadog.
Set it in local.el, which git ignores." :type '(choice (const nil) string))
(defconst cc-hub--colors
  '(("needs_input" . "#d70015") ("working" . "#0a84ff") ("done" . "#248a3d") ("failed" . "#bf5af2")
    ("running" . "#248a3d") ("exited" . "#d70015") ("Alert" . "#d70015") ("Warn" . "#ff9f0a")
    ("OK" . "#248a3d") ("Success" . "#248a3d") ("Failed" . "#d70015") ("Executing" . "#0a84ff")))

;;; Async primitives

(defun cc-hub--json-read (buffer)
  (with-current-buffer buffer
    (goto-char (point-min))
    (json-parse-buffer :object-type 'alist :array-type 'list :null-object nil :false-object nil)))

(defun cc-hub--quote (s)
  (concat "\"" (replace-regexp-in-string "[\"\\\\]" "\\\\\\&" s) "\""))

(defun cc-hub--report (what msg)
  (message "cc-hub: %s failed: %s" what (string-trim (or msg "")))
  nil)

(defun cc-hub--run (what command callback &optional stdin json)
  "Run COMMAND async. Call CALLBACK with stdout (parsed when JSON) on exit 0.
STDIN, when non-nil, is sent on standard input. Errors are reported, never dropped."
  (let* ((out (generate-new-buffer " *cc-hub-out*"))
         (err (generate-new-buffer " *cc-hub-err*"))
         (proc (make-process
                :name "cc-hub" :buffer out :stderr err :command command :noquery t
                :connection-type 'pipe
                :sentinel
                (lambda (p _)
                  (when (memq (process-status p) '(exit signal))
                    (unwind-protect
                        (if (/= (process-exit-status p) 0)
                            (cc-hub--report what (concat (with-current-buffer err (buffer-string))
                                                         (with-current-buffer out (buffer-string))))
                          (let ((data (condition-case e
                                          (if json (cc-hub--json-read out)
                                            (with-current-buffer out (buffer-string)))
                                        (error (cc-hub--report what (error-message-string e)) 'cc-hub--bad))))
                            (unless (eq data 'cc-hub--bad) (funcall callback data))))
                      (kill-buffer out)
                      (when (buffer-live-p err) (kill-buffer err))))))))
    (when stdin
      (process-send-string proc stdin)
      (process-send-eof proc))
    proc))

(cl-defun cc-hub--http (what url callback &key headers method body)
  "Fetch URL with curl and call CALLBACK with the parsed JSON body.
HEADERS, METHOD and BODY go through curl's stdin config, so secrets stay out of argv."
  (cc-hub--run what '("curl" "-sS" "--fail-with-body" "--max-time" "20" "-K" "-")
               callback
               (concat (format "url = %s\n" (cc-hub--quote url))
                       (if method (format "request = %s\n" (cc-hub--quote method)) "")
                       (mapconcat (lambda (h) (format "header = %s\n" (cc-hub--quote (format "%s: %s" (car h) (cdr h)))))
                                  headers "")
                       (if body (format "data-binary = %s\n" (cc-hub--quote body)) ""))
               t))

(defun cc-hub--secret (host &optional user)
  (auth-source-pick-first-password :host host :user user))

;;; Small helpers

(defun cc-hub--s (x) (if x (format "%s" x) ""))
(defun cc-hub--line (x) (replace-regexp-in-string "\n" " " (cc-hub--s x)))

(defun cc-hub--chip (text)
  (let ((color (or (cdr (assoc text cc-hub--colors)) "#8e8e93"))
        (text (cc-hub--s text)))
    (if (and (display-graphic-p) (not (string-empty-p text)) (require 'svg-lib nil t))
        (propertize text 'display (svg-lib-tag text nil :foreground "white" :background color))
      (propertize text 'face `(:foreground ,color :weight bold)))))

(defun cc-hub--ago (epoch)
  (if (not (numberp epoch)) ""
    (let ((m (/ (- (float-time) epoch) 60)))
      (if (< m 60) (format "%dm" m) (format "%dh" (/ m 60))))))

(defun cc-hub--project-root ()
  (or (and (fboundp 'doom-project-root) (doom-project-root)) default-directory))

(defun cc-hub--read-project ()
  (if (fboundp 'projectile-relevant-known-projects)
      (completing-read "Project: " (projectile-relevant-known-projects) nil t nil nil (cc-hub--project-root))
    (read-directory-name "Project: " (cc-hub--project-root))))

;;; Sources: one cache entry, one buffer and one async fetch per SPC l list

(cl-defstruct (cc-hub-source (:constructor cc-hub-source-create) (:copier nil))
  name buffer format fetch rows open mode)

(defvar cc-hub--cache (make-hash-table) "Source name -> last fetched data.")
(defvar-local cc-hub--source nil)
(defvar-local cc-hub--filter nil)
(defvar-local cc-hub--status "")
(put 'cc-hub--status 'risky-local-variable t)

(define-derived-mode cc-hub-list-mode tabulated-list-mode "cc-hub"
  "List buffer for the SPC l command centre."
  (setq tabulated-list-padding 1
        tabulated-list-sort-key nil
        mode-line-process '(:eval cc-hub--status)))

(defun cc-hub--render (src)
  "Draw SRC from the cache. Fast: no I/O."
  (when-let ((buf (get-buffer (cc-hub-source-buffer src))))
    (with-current-buffer buf
      (let ((entries (condition-case e (funcall (cc-hub-source-rows src) (gethash (cc-hub-source-name src) cc-hub--cache))
                       (error (cc-hub--report (cc-hub-source-name src) (error-message-string e))))))
        (when cc-hub--filter
          (setq entries (seq-filter (lambda (e) (string-match-p cc-hub--filter (mapconcat #'cc-hub--s (cadr e) " ")))
                                    entries)))
        (setq tabulated-list-entries entries)
        (tabulated-list-print t)))))

(defun cc-hub--set-status (src text)
  (when-let ((buf (get-buffer (cc-hub-source-buffer src))))
    (with-current-buffer buf (setq cc-hub--status text) (force-mode-line-update))))

(defun cc-hub--fetch (src)
  (if (null (cc-hub-source-fetch src))
      (cc-hub--render src)
    (cc-hub--set-status src " [loading]")
    (funcall (cc-hub-source-fetch src)
             (lambda (data)
               (puthash (cc-hub-source-name src) data cc-hub--cache)
               (cc-hub--set-status src (format-time-string " [%H:%M]"))
               (cc-hub--render src)))))

(defun cc-hub--show (src)
  (with-current-buffer (get-buffer-create (cc-hub-source-buffer src))
    (unless (eq cc-hub--source src)
      (funcall (or (cc-hub-source-mode src) #'cc-hub-list-mode))
      (setq cc-hub--source src
            tabulated-list-format (cc-hub-source-format src))
      (tabulated-list-init-header))
    (switch-to-buffer (current-buffer))
    (cc-hub--render src)
    (cc-hub--fetch src)))

(defun cc-hub-refresh ()
  "Fetch this list again."
  (interactive)
  (cc-hub--fetch cc-hub--source))

(defun cc-hub-filter (regexp)
  "Show only rows that match REGEXP. Empty input clears the filter."
  (interactive (list (read-string "Filter (regexp): " cc-hub--filter)))
  (setq cc-hub--filter (unless (string-empty-p regexp) regexp))
  (cc-hub--render cc-hub--source))

(defun cc-hub--row () (or (tabulated-list-get-id) (user-error "No item on this line")))

(defun cc-hub-open ()
  (interactive)
  (funcall (cc-hub-source-open cc-hub--source) (cc-hub--row)))

(map! :map cc-hub-list-mode-map
      :n "RET" #'cc-hub-open
      :n "gr"  #'cc-hub-refresh
      :n "/"   #'cc-hub-filter
      :n "q"   #'quit-window)

(defmacro cc-hub--define (name &rest props)
  "Define source NAME (a symbol) and the command `cc-hub-NAME' that shows it."
  (declare (indent 1))
  (let ((doc (plist-get props :doc)))
    (cl-remf props :doc)
    `(progn
       (defvar ,(intern (format "cc-hub--%s-source" name))
         (cc-hub-source-create :name ',name :buffer ,(format "*cc-hub %s*" name) ,@props))
       (defun ,(intern (format "cc-hub-%s" name)) ()
         ,doc
         (interactive)
         (cc-hub--show ,(intern (format "cc-hub--%s-source" name)))))))

;;; Terminals: ghostel first, vterm fallback, scoped to the current workspace

(put 'cc-hub-proc 'permanent-local t)
(defvar-local cc-hub-proc nil "Plist (:root :name :command) for process buffers.")

(defun cc-hub--live-p (buf)
  (and (buffer-live-p buf)
       (with-current-buffer buf
         (or (process-live-p (get-buffer-process buf))
             (and (boundp 'ghostel--process) (process-live-p ghostel--process))))))

(defun cc-hub--term (name program args dir &optional proc show)
  "Run PROGRAM ARGS in DIR in terminal buffer NAME. Reuse the buffer when it runs.
PROC is stored as `cc-hub-proc'. SHOW non-nil displays the buffer."
  (let ((buf (get-buffer name)))
    (unless (cc-hub--live-p buf)
      (when (buffer-live-p buf) (kill-buffer buf))
      (let ((default-directory (file-name-as-directory (expand-file-name dir))))
        (if (and (eq cc-hub-terminal 'ghostel) (require 'ghostel nil t))
            (progn
              (setq buf (get-buffer-create name))
              (when show (switch-to-buffer buf))
              (ghostel-exec buf program args)
              (with-current-buffer buf (setq-local ghostel-kill-buffer-on-exit (not proc))))
          (require 'vterm)
          (let ((vterm-shell (mapconcat #'shell-quote-argument (cons program args) " "))
                (vterm-max-scrollback 10000))
            (save-window-excursion (setq buf (vterm name)))
            (with-current-buffer buf (setq-local vterm-kill-buffer-on-exit (not proc)))))))
    (with-current-buffer buf (when proc (setq cc-hub-proc proc)))
    (when (bound-and-true-p persp-mode) (persp-add-buffer buf))
    (when show (switch-to-buffer buf))
    buf))

;;; Sessions: read from cc-hubd, cached, shared by agents, review, issues and the modeline

(defun cc-hub--sessions () (gethash 'agents cc-hub--cache))

(defun cc-hub--fetch-sessions (callback)
  (cc-hub--run "cc-hubd" (list "curl" "-sS" "--fail" "--max-time" "3" (concat cc-hub-url "/api/sessions.json"))
               callback nil t))

(defun cc-hub--label (s)
  (or (alist-get 'key s) (alist-get 'name s) (substring (alist-get 'sid s) 0 8)))

(defun cc-hub--background-id (s)
  (unless (equal (alist-get 'kind s) "background")
    (user-error "%s is an interactive session, not a background one" (cc-hub--label s)))
  (alist-get 'id s))

(defun cc-hub--attach (s)
  (cc-hub--term (format "*claude:%s*" (cc-hub--label s)) "claude"
                (list "attach" (cc-hub--background-id s)) (alist-get 'cwd s) nil t))

(defun cc-hub--interactive-buffer (s)
  "A claude-code.el buffer in Emacs that runs session S, if any."
  (let ((dir (file-name-as-directory (cc-hub--s (alist-get 'cwd s)))))
    (seq-find (lambda (b) (and (string-prefix-p "*claude" (buffer-name b))
                               (equal (file-name-as-directory (buffer-local-value 'default-directory b)) dir)))
              (buffer-list))))

(defun cc-hub-agent-attach (s)
  "Attach to session S. Background sessions open in a terminal buffer."
  (interactive (list (cc-hub--row)))
  (if (equal (alist-get 'kind s) "background")
      (cc-hub--attach s)
    (if-let ((buf (cc-hub--interactive-buffer s)))
        (switch-to-buffer buf)
      (user-error "%s runs in a terminal outside Emacs (cwd %s)" (cc-hub--label s) (alist-get 'cwd s)))))

(defun cc-hub--transcript (sid)
  (car (file-expand-wildcards (expand-file-name (format "~/.claude/projects/*/%s.jsonl" sid)))))

(defun cc-hub--transcript-text (file n)
  "The last N text and tool messages of the transcript FILE."
  (let (msgs)
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (while (not (eobp))
        (let* ((e (ignore-errors (json-parse-string (buffer-substring-no-properties (point) (line-end-position))
                                                    :object-type 'alist :array-type 'list :null-object nil)))
               (who (alist-get 'type e))
               (c (alist-get 'content (alist-get 'message e))))
          (when (member who '("user" "assistant"))
            (dolist (part (if (stringp c) `(((type . "text") (text . ,c))) c))
              (pcase (alist-get 'type part)
                ("text" (push (format "%s: %s" who (alist-get 'text part)) msgs))
                ("tool_use" (push (format "%s: [%s]" who (alist-get 'name part)) msgs))))))
        (forward-line 1)))
    (string-join (nreverse (seq-take msgs n)) "\n\n")))

(defun cc-hub--show-logs (text)
  (with-current-buffer (get-buffer-create "*cc-hub logs*")
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert text)
      (goto-char (point-max)))
    (special-mode)
    (display-buffer (current-buffer))))

(defun cc-hub-agent-peek (s)
  "Show the recent output of session S.
Reads the saved transcript, so it works when the background daemon is gone."
  (interactive (list (cc-hub--row)))
  (if-let ((file (cc-hub--transcript (alist-get 'sid s))))
      (cc-hub--show-logs (let ((text (cc-hub--transcript-text file 40)))
                           (if (string-empty-p text)
                               (format "No messages in %s.\nThe session ended before its first message." file)
                             text)))
    (cc-hub--run "claude logs" (list "claude" "logs" (cc-hub--background-id s))
                 (lambda (out) (cc-hub--show-logs (ansi-color-apply out))))))

(defun cc-hub-agent-diff (s)
  "Magit diff of the worktree branch of S against origin/HEAD."
  (interactive (list (cc-hub--row)))
  (let ((default-directory (file-name-as-directory (alist-get 'cwd s))))
    (magit-diff-range (concat (or (magit-git-string "rev-parse" "--abbrev-ref" "origin/HEAD") "main") "...HEAD"))))

(defun cc-hub-agent-pr (s)
  "Open the PR of the worktree branch of S in Forge."
  (interactive (list (cc-hub--row)))
  (let ((default-directory (file-name-as-directory (alist-get 'cwd s))))
    (cc-hub--run "gh pr view" '("gh" "pr" "view" "--json" "url") (lambda (pr) (cc-hub--visit-pr (alist-get 'url pr))) nil t)))

(defun cc-hub-agent-stop (s)
  (interactive (list (cc-hub--row)))
  (cc-hub--run "claude stop" (list "claude" "stop" (cc-hub--background-id s))
               (lambda (_) (message "cc-hub: stopped %s" (cc-hub--label s)))))

(defun cc-hub-agent-rm (s)
  "Delete session S and its worktree. Claude refuses when commits are unpushed."
  (interactive (list (cc-hub--row)))
  (let ((id (cc-hub--background-id s)))
    (when (yes-or-no-p (format "claude rm %s (%s)? " id (cc-hub--label s)))
      (cc-hub--run "claude rm" (list "claude" "rm" id) (lambda (out) (message "cc-hub: %s" (string-trim out)))))))

(define-derived-mode cc-hub-agents-mode cc-hub-list-mode "cc-agents")
(map! :map cc-hub-agents-mode-map
      :n "p" #'cc-hub-agent-peek
      :n "d" #'cc-hub-agent-diff
      :n "r" #'cc-hub-agent-pr
      :n "s" #'cc-hub-agent-stop
      :n "x" #'cc-hub-agent-rm
      :n "n" #'cc-hub-dispatch)

(cc-hub--define agents
  :doc "Claude Code sessions. RET attach, p peek, d diff, r PR, s stop, x rm, n new."
  :format [("State" 13 nil) ("Key / name" 30 nil) ("Repo" 20 nil) ("Branch" 24 nil)
           ("Kind" 11 nil) ("Upd" 5 nil) ("Last message" 0 nil)]
  :fetch #'cc-hub--fetch-sessions
  :rows (lambda (data)
          (cl-loop for s in data
                   unless (equal (alist-get 'state s) "ended")
                   collect (list s (vector (cc-hub--chip (alist-get 'state s)) (cc-hub--label s)
                                           (cc-hub--s (alist-get 'repo s)) (cc-hub--s (alist-get 'branch s))
                                           (cc-hub--s (alist-get 'kind s)) (cc-hub--ago (alist-get 'updated_at s))
                                           (cc-hub--line (alist-get 'last_msg s))))))
  :open #'cc-hub-agent-attach
  :mode #'cc-hub-agents-mode)

;;;###autoload
(defun cc-hub-next-waiting ()
  "Jump to the session that has waited longest for input, at its prompt."
  (interactive)
  (let ((waiting (seq-sort-by (lambda (s) (or (alist-get 'updated_at s) 0)) #'<
                              (seq-filter (lambda (s) (equal (alist-get 'state s) "needs_input"))
                                          (cc-hub--sessions)))))
    (if (null waiting)
        (message "cc-hub: no session waits for input")
      (let ((buf (cc-hub-agent-attach (car waiting))))
        (when (bufferp buf)
          (with-current-buffer buf (goto-char (point-max))))))))

;;; Dispatch

(defun cc-hub--default-key ()
  (when-let ((row (and (derived-mode-p 'tabulated-list-mode) (tabulated-list-get-id))))
    (and (listp row) (or (alist-get 'identifier row) (alist-get 'key row)))))

;;;###autoload
(defun cc-hub-dispatch (dir key prompt)
  "Start background session KEY in a new worktree of DIR, in plan mode."
  (interactive
   (let ((default-key (cc-hub--default-key)))
     (list (cc-hub--read-project)
           (read-string (format-prompt "Issue key" default-key) nil nil default-key)
           (read-string "Prompt: "))))
  (when (string-empty-p key) (user-error "An issue key is required: it names the session and worktree"))
  (let ((default-directory (file-name-as-directory (expand-file-name dir))))
    (cc-hub--run (format "dispatch %s" key)
                 (list "claude" "--bg" "--permission-mode" "plan" "--name" key "--worktree" key prompt)
                 (lambda (_) (message "cc-hub: dispatched %s in %s" key (abbreviate-file-name dir))))))

;;; Review queue: finished agents and PRs that request my review

(defun cc-hub--visit-pr (url)
  "Open URL in Forge. Fall back to the browser, and say why."
  (condition-case e
      (progn (require 'forge) (forge-visit-topic-from-url url))
    (error (message "cc-hub: Forge cannot open %s (%s); opened the browser" url (error-message-string e))
           (browse-url url))))

(defun cc-hub--review-fetch (callback)
  (cc-hub--run "gh search prs"
               '("gh" "search" "prs" "--review-requested=@me" "--state=open"
                 "--json" "number,title,repository,url,isDraft" "--limit" "50")
               callback nil t))

(defun cc-hub--review-pr (row)
  (unless (eq (car row) 'pr) (user-error "Not a PR"))
  (alist-get 'url (cdr row)))

(defun cc-hub-review-approve (row)
  (interactive (list (cc-hub--row)))
  (let ((url (cc-hub--review-pr row)))
    (when (yes-or-no-p (format "Approve %s? " url))
      (cc-hub--run "gh pr review" (list "gh" "pr" "review" url "--approve")
                   (lambda (_) (message "cc-hub: approved %s" url))))))

(defun cc-hub-review-request-changes (row body)
  (interactive (list (cc-hub--row) (read-string "Request changes: ")))
  (let ((url (cc-hub--review-pr row)))
    (cc-hub--run "gh pr review" (list "gh" "pr" "review" url "--request-changes" "--body" body)
                 (lambda (_) (message "cc-hub: requested changes on %s" url)))))

(defun cc-hub-review-diff (row)
  "Diff of the PR, or of the agent worktree."
  (interactive (list (cc-hub--row)))
  (if (eq (car row) 'session)
      (cc-hub-agent-diff (cdr row))
    (cc-hub--run "gh pr diff" (list "gh" "pr" "diff" (cc-hub--review-pr row))
                 (lambda (out)
                   (with-current-buffer (get-buffer-create "*cc-hub pr diff*")
                     (let ((inhibit-read-only t)) (erase-buffer) (insert out) (goto-char (point-min)))
                     (diff-mode) (view-mode 1)
                     (switch-to-buffer (current-buffer)))))))

(define-derived-mode cc-hub-review-mode cc-hub-list-mode "cc-review")
(map! :map cc-hub-review-mode-map
      :n "a" #'cc-hub-review-approve
      :n "c" #'cc-hub-review-request-changes
      :n "d" #'cc-hub-review-diff
      :n "o" (cmd! (browse-url (cc-hub--review-pr (cc-hub--row)))))

(cc-hub--define review
  :doc "Finished agents and PRs for my review. RET Forge, d diff, a approve, c request changes, o browser."
  :format [("Type" 8 nil) ("Ref" 30 nil) ("Repo" 32 nil) ("Title" 0 nil)]
  :fetch #'cc-hub--review-fetch
  :rows (lambda (prs)
          (append
           (cl-loop for s in (cc-hub--sessions)
                    when (and (equal (alist-get 'state s) "done") (equal (alist-get 'kind s) "background"))
                    collect (list (cons 'session s)
                                  (vector (cc-hub--chip "done") (cc-hub--label s) (cc-hub--s (alist-get 'repo s))
                                          (cc-hub--line (alist-get 'last_msg s)))))
           (cl-loop for pr in prs
                    collect (list (cons 'pr pr)
                                  (vector (cc-hub--chip (if (alist-get 'isDraft pr) "draft" "PR"))
                                          (format "#%s" (alist-get 'number pr))
                                          (cc-hub--s (alist-get 'nameWithOwner (alist-get 'repository pr)))
                                          (alist-get 'title pr))))))
  :open (lambda (row) (if (eq (car row) 'session) (cc-hub-agent-diff (cdr row))
                        (cc-hub--visit-pr (cc-hub--review-pr row))))
  :mode #'cc-hub-review-mode)

;;; Linear issues: read and write through GraphQL with a personal key

(defun cc-hub--linear (what query variables callback &optional fallback-url)
  "Run a Linear GraphQL QUERY. Without a key, open FALLBACK-URL and say why."
  (let ((key (cc-hub--secret "api.linear.app")))
    (cond
     (key (cc-hub--http what "https://api.linear.app/graphql"
                        (lambda (res)
                          (if-let ((errors (alist-get 'errors res)))
                              (progn (cc-hub--report what (format "%S" errors))
                                     (when fallback-url (browse-url fallback-url)))
                            (funcall callback (alist-get 'data res))))
                        :method "POST"
                        :headers `(("Content-Type" . "application/json") ("Authorization" . ,key))
                        :body (json-encode `((query . ,query) (variables . ,(or variables (make-hash-table)))))))
     (fallback-url
      (message "cc-hub: no Linear key in auth-source (host api.linear.app); opened the browser")
      (browse-url fallback-url))
     (t (message "cc-hub: no Linear key in auth-source (host api.linear.app). Add one to list issues")))))

(defconst cc-hub--linear-issues-query
  "{ viewer { assignedIssues(first: 100, filter: {state: {type: {nin: [\"completed\", \"canceled\"]}}}) {
       nodes { id identifier title url priorityLabel state { name } cycle { number } team { id } } } } }")

(defun cc-hub-issue-transition (issue)
  "Move ISSUE to another workflow state."
  (interactive (list (cc-hub--row)))
  (let ((url (alist-get 'url issue)))
    (cc-hub--linear
     "Linear states" "query($id: String!) { team(id: $id) { states { nodes { id name } } } }"
     `((id . ,(alist-get 'id (alist-get 'team issue))))
     (lambda (data)
       (let* ((states (mapcar (lambda (s) (cons (alist-get 'name s) (alist-get 'id s)))
                              (thread-last data (alist-get 'team) (alist-get 'states) (alist-get 'nodes))))
              (name (completing-read (format "%s to state: " (alist-get 'identifier issue)) states nil t)))
         (cc-hub--linear
          "Linear transition"
          "mutation($id: String!, $state: String!) { issueUpdate(id: $id, input: {stateId: $state}) { success } }"
          `((id . ,(alist-get 'id issue)) (state . ,(cdr (assoc name states))))
          (lambda (_) (message "cc-hub: %s is now %s" (alist-get 'identifier issue) name)
            (cc-hub--fetch cc-hub--issues-source))
          url)))
     url)))

(defun cc-hub-issue-comment (issue body)
  "Add comment BODY to ISSUE."
  (interactive (list (cc-hub--row) (read-string "Comment: ")))
  (cc-hub--linear
   "Linear comment"
   "mutation($id: String!, $body: String!) { commentCreate(input: {issueId: $id, body: $body}) { success } }"
   `((id . ,(alist-get 'id issue)) (body . ,body))
   (lambda (_) (message "cc-hub: commented on %s" (alist-get 'identifier issue)))
   (alist-get 'url issue)))

(define-derived-mode cc-hub-issues-mode cc-hub-list-mode "cc-issues")
(map! :map cc-hub-issues-mode-map
      :n "t" #'cc-hub-issue-transition
      :n "c" #'cc-hub-issue-comment
      :n "n" #'cc-hub-dispatch
      :n "o" (cmd! (browse-url (alist-get 'url (cc-hub--row)))))

(cc-hub--define issues
  :doc "My open Linear issues joined to agents by key. t transition, c comment, n dispatch, RET/o open."
  :format [("Key" 11 nil) ("State" 14 nil) ("Prio" 8 nil) ("Cycle" 6 nil) ("Agent" 13 nil) ("Title" 0 nil)]
  :fetch (lambda (callback)
           (cc-hub--linear "Linear issues" cc-hub--linear-issues-query nil
                           (lambda (data) (funcall callback (thread-last data (alist-get 'viewer)
                                                                         (alist-get 'assignedIssues) (alist-get 'nodes))))))
  :rows (lambda (issues)
          (let ((agents (mapcar (lambda (s) (cons (alist-get 'key s) (alist-get 'state s))) (cc-hub--sessions))))
            (cl-loop for i in issues
                     for agent = (cdr (assoc (alist-get 'identifier i) agents))
                     collect (list i (vector (alist-get 'identifier i) (cc-hub--s (alist-get 'name (alist-get 'state i)))
                                             (cc-hub--s (alist-get 'priorityLabel i))
                                             (cc-hub--s (alist-get 'number (alist-get 'cycle i)))
                                             (if agent (cc-hub--chip agent) "") (alist-get 'title i))))))
  :open (lambda (i) (browse-url (alist-get 'url i)))
  :mode #'cc-hub-issues-mode)

;;; Octopus deploys: status here, the deploy action is a deep link

(cc-hub--define deploys
  :doc "Octopus deployment state per project and environment. RET opens the project in Octopus."
  :format [("State" 10 nil) ("Project" 32 nil) ("Env" 14 nil) ("Release" 18 nil) ("Completed" 0 nil)]
  :fetch (lambda (callback)
           (let* ((host (and cc-hub-octopus-url (url-host (url-generic-parse-url cc-hub-octopus-url))))
                  (key (and host (cc-hub--secret host))))
             (if (not key)
                 (message "cc-hub: set `cc-hub-octopus-url' and an auth-source key for its host")
               (cc-hub--http "Octopus" (format "%s/api/%s/dashboard" cc-hub-octopus-url cc-hub-octopus-space)
                             callback :headers `(("X-Octopus-ApiKey" . ,key))))))
  :rows (lambda (res)
          (let ((name (lambda (key id) (alist-get 'Name (seq-find (lambda (x) (equal (alist-get 'Id x) id))
                                                                  (alist-get key res))))))
            (cl-loop for it in (alist-get 'Items res)
                     collect (list it (vector (cc-hub--chip (alist-get 'State it))
                                              (cc-hub--s (funcall name 'Projects (alist-get 'ProjectId it)))
                                              (cc-hub--s (funcall name 'Environments (alist-get 'EnvironmentId it)))
                                              (cc-hub--s (alist-get 'ReleaseVersion it))
                                              (cc-hub--s (alist-get 'CompletedTime it)))))))
  :open (lambda (it) (browse-url (format "%s/app#/%s/projects/%s/deployments" cc-hub-octopus-url
                                         cc-hub-octopus-space (alist-get 'ProjectId it)))))

;;; Datadog monitors: dispatch an investigation agent, deep-link for depth

(defun cc-hub--datadog-app-host ()
  (if (equal cc-hub-datadog-site "datadoghq.com") "app.datadoghq.com" cc-hub-datadog-site))

(defun cc-hub-monitor-investigate (m dir)
  "Dispatch a read-only investigation agent for monitor M in a worktree of DIR."
  (interactive (list (cc-hub--row) (cc-hub--read-project)))
  (cc-hub-dispatch
   dir (format "DD-%s" (alist-get 'id m))
   (format "Investigate Datadog monitor %s \"%s\" (status %s). Use only the Datadog MCP read tools: search_datadog_monitors, search_datadog_logs, get_datadog_trace, get_change_stories. Change nothing. Report the likely cause, the evidence and the next step."
           (alist-get 'id m) (alist-get 'name m) (alist-get 'status m))))

(define-derived-mode cc-hub-monitors-mode cc-hub-list-mode "cc-monitors")
(map! :map cc-hub-monitors-mode-map :n "n" #'cc-hub-monitor-investigate)

(cc-hub--define monitors
  :doc "Datadog monitors that match `cc-hub-datadog-query'. n investigate with an agent, RET Datadog."
  :format [("Status" 10 nil) ("Monitor" 60 nil) ("Tags" 0 nil)]
  :fetch (lambda (callback)
           (let* ((host (concat "api." cc-hub-datadog-site))
                  (api (cc-hub--secret host "api")) (app (cc-hub--secret host "app")))
             (if (not (and api app))
                 (message "cc-hub: no Datadog keys in auth-source (host %s, users api and app)" host)
               (cc-hub--http "Datadog" (format "https://%s/api/v1/monitor/search?query=%s" host (url-hexify-string cc-hub-datadog-query))
                             (lambda (res) (funcall callback (alist-get 'monitors res)))
                             :headers `(("DD-API-KEY" . ,api) ("DD-APPLICATION-KEY" . ,app))))))
  :rows (lambda (monitors)
          (cl-loop for m in monitors
                   collect (list m (vector (cc-hub--chip (cc-hub--s (alist-get 'status m))) (cc-hub--s (alist-get 'name m))
                                           (string-join (alist-get 'tags m) " ")))))
  :open (lambda (m) (browse-url (format "https://%s/monitors/%s" (cc-hub--datadog-app-host) (alist-get 'id m))))
  :mode #'cc-hub-monitors-mode)

;;; Project processes (SPC l t): dev servers, k9s and shells as workspace buffers

(defun cc-hub--proc-specs (root)
  "Specs from ROOT/.cc-procs.el, else from `cc-hub-project-procs'. Read, never evaluated."
  (let ((file (expand-file-name ".cc-procs.el" root)))
    (if (file-readable-p file)
        (with-temp-buffer (insert-file-contents file) (read (current-buffer)))
      (cdr (assoc (file-name-as-directory root) cc-hub-project-procs
                  (lambda (a b) (equal (file-name-as-directory (expand-file-name a)) b)))))))

(defun cc-hub--proc-buffer-name (root name)
  (format "*proc:%s:%s*" (file-name-nondirectory (directory-file-name root)) name))

(defun cc-hub--proc-start (root spec &optional show)
  (pcase-let ((`(,name ,command . ,plist) spec))
    (cc-hub--term (cc-hub--proc-buffer-name root name)
                  (or (getenv "SHELL") "/bin/zsh") (list "-lic" command)
                  (expand-file-name (or (plist-get plist :dir) ".") root)
                  (list :root root :name name :command command) show)))

(defun cc-hub--workspace-buffers ()
  (if (fboundp '+workspace-buffer-list) (+workspace-buffer-list) (buffer-list)))

(defun cc-hub--proc-rows (_)
  (let* ((root (file-name-as-directory (cc-hub--project-root)))
         (specs (ignore-errors (cc-hub--proc-specs root)))
         (rows (cl-loop for spec in specs
                        for buf = (get-buffer (cc-hub--proc-buffer-name root (car spec)))
                        collect (list (list :root root :spec spec :buffer buf)
                                      (vector (cc-hub--chip (cond ((cc-hub--live-p buf) "running") (buf "exited") (t "")))
                                              (car spec) (cadr spec) (if buf (buffer-name buf) ""))))))
    (append rows
            (cl-loop for buf in (cc-hub--workspace-buffers)
                     when (and (memq (buffer-local-value 'major-mode buf) '(ghostel-mode vterm-mode))
                               (not (seq-find (lambda (r) (eq (plist-get (car r) :buffer) buf)) rows)))
                     collect (list (list :buffer buf)
                                   (vector (cc-hub--chip (if (cc-hub--live-p buf) "running" "exited"))
                                           (buffer-name buf) "" (buffer-name buf)))))))

(defun cc-hub-proc-start (row)
  "Start the process on this line, or jump to it when it runs."
  (interactive (list (cc-hub--row)))
  (let ((buf (plist-get row :buffer)))
    (if (cc-hub--live-p buf) (switch-to-buffer buf)
      (unless (plist-get row :spec) (user-error "No spec for %s; it is not in .cc-procs.el" (buffer-name buf)))
      (cc-hub--proc-start (plist-get row :root) (plist-get row :spec) t))))

(defun cc-hub-proc-kill (row)
  (interactive (list (cc-hub--row)))
  (when-let ((buf (plist-get row :buffer)))
    (when (yes-or-no-p (format "Kill %s? " (buffer-name buf)))
      (let ((kill-buffer-query-functions nil)) (kill-buffer buf))
      (cc-hub--render cc-hub--procs-source))))

(defun cc-hub-proc-restart (row)
  (interactive (list (cc-hub--row)))
  (unless (plist-get row :spec) (user-error "No .cc-procs.el spec for this buffer"))
  (when-let ((buf (plist-get row :buffer)))
    (let ((kill-buffer-query-functions nil)) (kill-buffer buf)))
  (cc-hub--proc-start (plist-get row :root) (plist-get row :spec))
  (cc-hub--render cc-hub--procs-source))

(defun cc-hub-proc-start-all ()
  "Start every process in this project's spec that is not running."
  (interactive)
  (let ((root (file-name-as-directory (cc-hub--project-root))))
    (dolist (spec (cc-hub--proc-specs root))
      (unless (cc-hub--live-p (get-buffer (cc-hub--proc-buffer-name root (car spec))))
        (cc-hub--proc-start root spec)))
    (cc-hub--render cc-hub--procs-source)))

(defun cc-hub--maybe-start-procs ()
  "On project switch, offer to start the :auto processes of the project."
  (let* ((root (file-name-as-directory (cc-hub--project-root)))
         (auto (seq-filter (lambda (spec) (and (plist-get (cddr spec) :auto)
                                               (not (cc-hub--live-p (get-buffer (cc-hub--proc-buffer-name root (car spec)))))))
                           (ignore-errors (cc-hub--proc-specs root)))))
    ;; A cloned repo can ship .cc-procs.el, so ask before running its commands.
    (when (and auto (y-or-n-p (format "Start %s? " (mapconcat (lambda (s) (format "%s (%s)" (car s) (cadr s))) auto ", "))))
      (dolist (spec auto) (cc-hub--proc-start root spec)))))

(add-hook 'projectile-after-switch-project-hook #'cc-hub--maybe-start-procs)

(define-derived-mode cc-hub-procs-mode cc-hub-list-mode "cc-procs")
(map! :map cc-hub-procs-mode-map
      :n "s" #'cc-hub-proc-start
      :n "S" #'cc-hub-proc-start-all
      :n "R" #'cc-hub-proc-restart
      :n "x" #'cc-hub-proc-kill)

(cc-hub--define procs
  :doc "Process buffers of this workspace and the project's .cc-procs.el. RET jump/start, S start all, R restart, x kill."
  :format [("State" 9 nil) ("Name" 18 nil) ("Command" 40 nil) ("Buffer" 0 nil)]
  :rows #'cc-hub--proc-rows
  :open #'cc-hub-proc-start
  :mode #'cc-hub-procs-mode)

;;; Slack catch-up and morning brief: local skills on MCP read tools, rendered as org

(defun cc-hub--claude-org (buffer-name skill tools)
  "Run SKILL with `claude -p' limited to read-only TOOLS. Show its org output in BUFFER-NAME.
The buffer visits no file, so messages never reach the disk."
  (let ((buf (get-buffer-create buffer-name)))
    (with-current-buffer buf
      (let ((inhibit-read-only t)) (erase-buffer) (insert (format "# Running /%s ...\n" skill)))
      (org-mode))
    (switch-to-buffer buf)
    (unless cc-hub-mcp-prefix (user-error "cc-hub: set `cc-hub-mcp-prefix' in local.el"))
    (let ((default-directory (expand-file-name "~/")))
      (cc-hub--run skill
                   (list "claude" "-p" (concat "/" skill) "--permission-mode" "default"
                         "--allowedTools" (mapconcat (lambda (tl) (concat cc-hub-mcp-prefix tl)) tools ","))
                   (lambda (out)
                     (when (buffer-live-p buf)
                       (with-current-buffer buf
                         (let ((inhibit-read-only t))
                           (erase-buffer)
                           (insert (format "#+title: %s %s\n\n" skill (format-time-string "%F %H:%M")) out)
                           (goto-char (point-min))
                           (org-fold-show-all)))))))))

(defconst cc-hub--slack-tools
  '("Slack_slack_search_public_and_private" "Slack_slack_read_channel" "Slack_slack_read_thread"
    "Slack_slack_read_user_profile" "Slack_slack_list_user_channels"))

;;;###autoload
(defun cc-hub-slack ()
  "Slack catch-up through the slack-catchup skill. Write replies in the Slack app."
  (interactive)
  (cc-hub--claude-org "*cc-hub slack*" "slack-catchup" cc-hub--slack-tools))

;;;###autoload
(defun cc-hub-brief ()
  "Morning brief through the morning-brief skill."
  (interactive)
  (cc-hub--claude-org "*cc-hub brief*" "morning-brief"
                      (append cc-hub--slack-tools
                              '("Google-Calendar_list_events" "Linear_get_notifications" "Linear_list_issues"))))

;;; Web view in xwidget-webkit, with the browser as fallback

(defun cc-hub--view-url (view) (concat cc-hub-url "/#" view))

(defun cc-hub-web (&optional view)
  "Open dashboard VIEW (agents, graph or metrics) in an xwidget-webkit buffer."
  (interactive)
  (let ((url (cc-hub--view-url (or view "agents"))))
    (if (not (featurep 'xwidget-internal))
        (progn (message "cc-hub: this Emacs has no xwidgets; opened the browser") (browse-url url))
      (if-let ((session (ignore-errors (xwidget-webkit-current-session))))
          (progn (xwidget-webkit-goto-uri session url) (switch-to-buffer (xwidget-buffer session)))
        (xwidget-webkit-browse-url url t))
      (when-let ((session (xwidget-webkit-current-session)))
        (with-current-buffer (xwidget-buffer session)
          ;; Printable keys go to the page (j k / g a g g g m); C-x and M-SPC stay with Emacs.
          (when (fboundp 'evil-emacs-state) (evil-emacs-state))
          (xwidget-webkit-edit-mode 1))))))

;;;###autoload
(defun cc-hub-web-browser ()
  "Open the dashboard in the external browser."
  (interactive)
  (browse-url (cc-hub--view-url "agents")))

;;; Pokes from cc-hubd and the modeline flag

(defvar cc-hub--poke-timer nil)
(defvar cc-hub-mode-line-string "")
(put 'cc-hub-mode-line-string 'risky-local-variable t)

(defun cc-hub--update-mode-line ()
  (let ((n (seq-count (lambda (s) (equal (alist-get 'state s) "needs_input")) (cc-hub--sessions))))
    (setq cc-hub-mode-line-string
          (if (> n 0)
              (propertize (format " ⚑%d " n) 'face 'error 'help-echo "SPC l . jumps to the oldest waiting session")
            ""))
    (force-mode-line-update t)))

(defun cc-hub--after-poke ()
  (cc-hub--fetch-sessions
   (lambda (data)
     (puthash 'agents data cc-hub--cache)
     (cc-hub--update-mode-line)
     (dolist (src (list cc-hub--agents-source cc-hub--review-source cc-hub--issues-source))
       (when-let ((buf (get-buffer (cc-hub-source-buffer src))))
         (when (get-buffer-window buf t) (cc-hub--render src)))))))

(defun cc-hub-poke ()
  "Called by cc-hubd through emacsclient when a session changes."
  (when cc-hub--poke-timer (cancel-timer cc-hub--poke-timer))
  (setq cc-hub--poke-timer (run-with-timer 0.3 nil #'cc-hub--after-poke)))

(add-to-list 'global-mode-string '(:eval cc-hub-mode-line-string) t)
(cc-hub-poke)

(map! :leader
      (:prefix-map ("l" . "command centre")
       :desc "Agents"            "a" #'cc-hub-agents
       :desc "Next waiting"      "." #'cc-hub-next-waiting
       :desc "Dispatch agent"    "n" #'cc-hub-dispatch
       :desc "Review queue"      "r" #'cc-hub-review
       :desc "My issues"         "i" #'cc-hub-issues
       :desc "Deploys"           "d" #'cc-hub-deploys
       :desc "Monitors"          "m" #'cc-hub-monitors
       :desc "Processes"         "t" #'cc-hub-procs
       :desc "Slack catch-up"    "s" #'cc-hub-slack
       :desc "Morning brief"     "b" #'cc-hub-brief
       :desc "Opal (web)"        "o" (cmd! (browse-url cc-hub-opal-url))
       :desc "Dashboard browser" "W" #'cc-hub-web-browser
       (:prefix ("w" . "web view")
        :desc "Dashboard"        "w" #'cc-hub-web
        :desc "Agent timeline"   "a" (cmd! (cc-hub-web "agents"))
        :desc "Graph"            "g" (cmd! (cc-hub-web "graph"))
        :desc "Metrics"          "m" (cmd! (cc-hub-web "metrics")))))
