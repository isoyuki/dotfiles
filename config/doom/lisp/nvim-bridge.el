;;; nvim-bridge.el --- Neovim inside Doom: one server per project -*- lexical-binding: t; -*-

;; Neovim owns code editing. Each project root gets one terminal buffer that
;; runs `nvim --listen SOCKET' with NVIM_IN_EMACS=1. Emacs opens files there
;; through `EmacsBridge.open' (nvim/lua/emacs_bridge.lua); Neovim calls back
;; with `emacsclient -n --eval'.

(require 'cl-lib)
(require 'subr-x)

(declare-function doom-project-root "doom-lib")
(declare-function ghostel-exec "ghostel")
(declare-function ghostel-char-mode "ghostel")
(declare-function evil-emacs-state "evil")
(declare-function persp-add-buffer "persp-mode")
(declare-function magit-status "magit")
(declare-function magit-diff-visit-worktree-file "magit-diff")
(defvar ghostel--process)
(defvar ghostel-kill-buffer-on-exit)
(defvar embark-keymap-alist)
(defvar embark-general-map)
(defvar embark-file-map)

(defvar my/nvim-lsp-off-modes
  '(c-mode c++-mode c-ts-mode c++-ts-mode objc-mode
    go-mode go-ts-mode go-mod-ts-mode
    python-mode python-ts-mode
    js-mode js-ts-mode typescript-mode typescript-ts-mode tsx-ts-mode
    lua-mode lua-ts-mode sh-mode bash-ts-mode
    terraform-mode latex-mode LaTeX-mode)
  "Major modes edited in Neovim.
Doom starts no LSP client (lsp-mode or eglot) in them.")

(defadvice! my/nvim-no-lsp-a (&rest _)
  "Skip `lsp!' in `my/nvim-lsp-off-modes': Neovim runs that language server."
  :before-until #'lsp!
  (apply #'derived-mode-p my/nvim-lsp-off-modes))

(defvar-local my/nvim-root nil "Project root of the Neovim server in this buffer.")
(put 'my/nvim-root 'permanent-local t)
(defvar-local my/nvim-started nil "Time the Neovim server in this buffer started.")
(put 'my/nvim-started 'permanent-local t)

;;; Servers

(defun my/nvim--root (&optional path)
  "Project root for PATH (a file or a directory), else for `default-directory'."
  (let ((default-directory (if path
                               (file-name-directory (expand-file-name path))
                             default-directory)))
    (file-name-as-directory (expand-file-name (or (doom-project-root) default-directory)))))

(defun my/nvim--name (root) (file-name-nondirectory (directory-file-name root)))

(defun my/nvim--socket (root)
  ;; The hash keeps two roots with the same basename apart; the 24-char cap
  ;; keeps the path under the 104-byte macOS socket limit.
  (expand-file-name (format "nvim-%s-%s.sock"
                            (truncate-string-to-width (my/nvim--name root) 24)
                            (substring (md5 root) 0 6))
                    (or (getenv "TMPDIR") temporary-file-directory)))

(defun my/nvim--buffer (root)
  (cl-find root (buffer-list) :test #'equal
           :key (lambda (b) (buffer-local-value 'my/nvim-root b))))

(defun my/nvim--live-p (buf root)
  "Non-nil when BUF runs Neovim and its socket exists or it started under 5 s ago."
  (and (buffer-live-p buf)
       (process-live-p (buffer-local-value 'ghostel--process buf))
       (or (file-exists-p (my/nvim--socket root))
           (< (float-time (time-since (buffer-local-value 'my/nvim-started buf))) 5))))

(defun my/nvim--passthrough ()
  "Send every key to Neovim, except emulation-map keys such as Doom's `M-SPC'."
  ;; Char mode binds every key, C-c, C-x, C-h and ESC too. M-RET exits it.
  (ghostel-char-mode)
  (when (fboundp 'evil-emacs-state) (evil-emacs-state)))

(defun my/nvim--start (root &optional file line col)
  "Start Neovim for ROOT, open FILE at LINE and COL. Return the buffer."
  (let* ((sock (my/nvim--socket root))
         (old (my/nvim--buffer root))
         (name (if (buffer-live-p old)
                   (buffer-name old)
                 (generate-new-buffer-name (format "*nvim:%s*" (my/nvim--name root))))))
    (when (buffer-live-p old)
      (let ((kill-buffer-query-functions nil)) (kill-buffer old)))
    (when (file-exists-p sock) (delete-file sock))
    (require 'ghostel)
    (let ((buf (get-buffer-create name))
          (default-directory root))
      (ghostel-exec buf "env"
                    `("-u" "TMUX" "NVIM_IN_EMACS=1" "nvim" "--listen" ,sock
                      ,@(when file
                          (list (format "+call cursor(%d,%d)" (or line 1) (or col 1))
                                "+normal! zz" "--" file))))
      (when (bound-and-true-p persp-mode) (persp-add-buffer buf))
      (with-current-buffer buf
        (setq-local ghostel-kill-buffer-on-exit t)
        (setq my/nvim-root root
              my/nvim-started (current-time))
        (my/nvim--passthrough))
      buf)))

(defun my/nvim--show (buf)
  (let ((win (get-buffer-window buf)))
    (if win (select-window win) (switch-to-buffer buf)))
  (when (fboundp 'evil-emacs-state) (evil-emacs-state)))

(defun my/nvim (&optional dir)
  "Show the Neovim buffer for the project of DIR, starting Neovim when needed."
  (interactive)
  (let* ((root (my/nvim--root (and dir (file-name-as-directory dir))))
         (buf (my/nvim--buffer root)))
    (my/nvim--show (if (my/nvim--live-p buf root) buf (my/nvim--start root)))))

(defun my/nvim--vimstr (s)
  (concat "'" (string-replace "'" "''" s) "'"))

(defun my/nvim-open (file &optional line col)
  "Open FILE at LINE and COL in the Neovim server of its project."
  (interactive (list (read-file-name "Open in Neovim: ")))
  (let* ((file (expand-file-name file))
         (root (my/nvim--root file))
         (buf (my/nvim--buffer root)))
    (when (string-match-p "[\n\r]" file) (user-error "File name has a newline: %S" file))
    (if (not (my/nvim--live-p buf root))
        (my/nvim--show (my/nvim--start root file line col))
      (call-process "nvim" nil 0 nil "--server" (my/nvim--socket root) "--remote-expr"
                    (format "v:lua.EmacsBridge.open(%s,%d,%d)"
                            (my/nvim--vimstr file) (or line 1) (or col 1)))
      (my/nvim--show buf))))

;;; Open-in-Neovim actions

(defconst my/nvim--ref-re
  "\\([^ \t\n\"'`()<>|:]+\\):\\([0-9]+\\)\\(?::\\([0-9]+\\)\\)?"
  "A `path:line' or `path:line:col' reference.")

(defun my/nvim--resolve (path)
  "PATH as an existing absolute file.
Try `default-directory' first, then the project root."
  (cl-find-if #'file-regular-p
              (list (expand-file-name path)
                    (expand-file-name path (my/nvim--root)))))

(defun my/nvim-open-at-point ()
  "Open the `file:line[:col]' reference at point in Neovim.
Without a reference, open the file name at point."
  (interactive)
  (let ((pt (point)) ref)
    (save-excursion
      (goto-char (line-beginning-position))
      (while (and (not ref) (re-search-forward my/nvim--ref-re (line-end-position) t))
        (let ((file (my/nvim--resolve (match-string-no-properties 1))))
          (when (and file (or (<= (match-beginning 0) pt (match-end 0)) (not ref)))
            (setq ref (list file (string-to-number (match-string 2))
                            (and (match-string 3) (string-to-number (match-string 3)))))))))
    (unless ref
      (when-let* ((f (thing-at-point 'filename t)) (file (my/nvim--resolve f)))
        (setq ref (list file))))
    (if ref
        (apply #'my/nvim-open ref)
      (user-error "No file:line reference on this line"))))

(defun my/nvim-open-buffer-file ()
  "Open the file of the current buffer in Neovim at point."
  (interactive)
  (unless buffer-file-name (user-error "This buffer visits no file"))
  (my/nvim-open buffer-file-name (line-number-at-pos) (1+ (current-column))))

(defun my/nvim-magit-open ()
  "Open the worktree file at point (file or hunk line) in Neovim."
  (interactive)
  ;; Magit computes the hunk position; read it back, then restore the windows.
  (cl-destructuring-bind (file line col)
      (save-window-excursion
        (call-interactively #'magit-diff-visit-worktree-file)
        (with-current-buffer (window-buffer)
          (list buffer-file-name (line-number-at-pos (window-point))
                (save-excursion (goto-char (window-point)) (1+ (current-column))))))
    (my/nvim-open file line col)))

(defun my/nvim-embark-grep (cand)
  "Open the consult grep candidate CAND in Neovim."
  ;; Same split as `consult--grep-position': the file ends where the face changes.
  (let* ((file-end (next-single-property-change 0 'face cand))
         (line-end (next-single-property-change (1+ file-end) 'face cand)))
    (my/nvim-open (my/nvim--resolve (substring-no-properties cand 0 file-end))
                  (string-to-number (substring-no-properties cand (1+ file-end) line-end)))))

(defvar-keymap my/nvim-embark-grep-map
  "n" #'my/nvim-embark-grep)

(after! embark
  (set-keymap-parent my/nvim-embark-grep-map embark-general-map)
  (setf (alist-get 'consult-grep embark-keymap-alist) '(my/nvim-embark-grep-map))
  (keymap-set embark-file-map "n" #'my/nvim-open))

;;; Called from Neovim through emacsclient

(defun my/nvim-windmove (dir)
  "Move to the Emacs window in DIR. Do nothing at the frame edge."
  (ignore-errors
    (pcase dir
      ('left (windmove-left)) ('right (windmove-right))
      ('up (windmove-up)) ('down (windmove-down)))))

(defun my/nvim--leave-nvim-window ()
  "Select a window that does not show Neovim. Split when there is none."
  (when (buffer-local-value 'my/nvim-root (window-buffer))
    (select-window (or (cl-find-if-not (lambda (w) (buffer-local-value 'my/nvim-root (window-buffer w)))
                                       (window-list))
                       (split-window-right)))))

(defun my/nvim-magit (dir)
  "Show Magit status for DIR outside the Neovim window."
  (my/nvim--leave-nvim-window)
  (magit-status (file-name-as-directory dir)))

;;; Keys

(map! :nm "C-h" #'windmove-left
      :nm "C-j" #'windmove-down
      :nm "C-k" #'windmove-up
      :nm "C-l" #'windmove-right
      :leader
      :desc "Neovim (project)" "o n" #'my/nvim
      :desc "File in Neovim" "f n" #'my/nvim-open-buffer-file
      :desc "file:line in Neovim" "l e" #'my/nvim-open-at-point)

(map! :after magit :map magit-mode-map :n "C-<return>" #'my/nvim-magit-open)

(provide 'nvim-bridge)
;;; nvim-bridge.el ends here
