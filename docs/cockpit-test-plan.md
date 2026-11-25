# Cockpit test plan

Use this list to try each integration once on a new machine or after a big
change. Do the sections in order: each section needs the one above it. Tick a
box when the result matches. When a result is wrong, write down the step number
and the text in `*Messages*` (`SPC h e`).

## 0. Before you start

- [ ] `doom doctor` shows only the Symbola warning.
- [ ] `launchctl list | grep cc-hubd` shows the agent with PID and exit 0.
- [ ] `curl -s 127.0.0.1:7777/api/summary.txt` returns a line such as `in:3 run:1 done:0 fail:1`.
- [ ] `config/doom/local.el` exists and sets `cc-hub-mcp-prefix`.
- [ ] `auth-source` has entries for Linear, Datadog, Octopus and GitHub (see the README table).
- [ ] Start Emacs from the Dock or Raycast, not from a terminal, so the test uses the GUI environment.

## 1. OS layer

1. [ ] Tap Caps Lock. Expect `Esc`.
2. [ ] Hold Caps Lock and press `E`, `B`, `S`, `M`. Expect AeroSpace to show the Emacs, browser, Slack and meetings workspaces.
3. [ ] Press Hyper+`` ` ``. Expect the Ghostty quick terminal. Press it again to hide it.
4. [ ] Open Leader Key and press `o e`. Expect Emacs to come to the front.
5. [ ] In Leader Key, press `g d`. Expect the cc-hub dashboard at `127.0.0.1:7777` in the browser.
6. [ ] In Ghostty, run `tmux`, then press `C-Space T`. Expect the sesh picker.

## 2. Agents

1. [ ] `SPC l n`, give a key such as `TEST-1` and a short prompt. Expect a new background session in plan mode in a worktree.
2. [ ] `SPC l a`. Expect the new row. `gr` refreshes the list.
3. [ ] On the row, press `p`. Expect the log in a peek buffer.
4. [ ] Press `RET`. Expect a ghostel buffer attached to the session.
5. [ ] Make the agent wait for input. Expect `⚑1` in the modeline. Switch to another app and expect a macOS notification.
6. [ ] `SPC l .`. Expect a jump to the waiting session at its prompt.
7. [ ] In `SPC l a`, press `d`. Expect Magit diff of the worktree.
8. [ ] Press `s` to stop the session, then `x` to remove it.
9. [ ] `SPC o c`. Expect a claude-code.el session for the current project.

## 3. Claude keys inside ghostel

`C-x` belongs to Emacs in ghostel, so the Claude `ctrl+x` chords do not arrive.
`~/.claude/keybindings.json` adds `ctrl+q` copies.

1. [ ] In an attached session, press `C-q C-e`. Expect the external editor.
2. [ ] Press `C-q C-k` while subagents run. Expect them to stop.
3. [ ] Press `C-q RET` while the agent works. Expect the message to queue.

## 4. Review and issues

1. [ ] `SPC l r`. Expect finished agents and PRs that wait for your review.
2. [ ] On a PR row, press `RET`. Expect the PR in Forge. Press `o` and expect the browser.
3. [ ] Do not press `a` or `c` on a real PR unless you mean it: they approve or request changes.
4. [ ] `SPC l i`. Expect your Linear issues, with the agent column filled for keys that have an agent.
5. [ ] On an issue, press `RET`. Expect the issue in the browser.
6. [ ] On a test issue, press `c` and add a comment. Expect it in Linear.

## 5. Deploys, monitors and access

1. [ ] `SPC l d`. Expect deploy state per project and environment. `RET` opens the project page.
2. [ ] `SPC l m`. Expect monitors that match `cc-hub-datadog-query`. `RET` opens the monitor page.
3. [ ] On a monitor row, press `n`. Expect a read-only investigation agent in `SPC l a`.
4. [ ] `SPC l o`. Expect the Opal access-request page in the browser.

## 6. Slack and morning brief

1. [ ] `SPC l s`. Expect `# Running /slack-catchup ...`, then an org buffer with mentions and threads.
2. [ ] `SPC l b`. Expect an org buffer with `* Today`, `* Waiting on me`, `* My issues` and `* Suggested first task`.
3. [ ] Check that neither buffer visits a file (`SPC b` list shows no path).

## 7. Dashboard

1. [ ] `SPC l w w`. Expect the dashboard in xwidget-webkit.
2. [ ] In the page, press `g a`, `g g`, `g m`. Expect the agent timeline, graph and metrics.
3. [ ] Press `M-SPC`. Expect the Doom leader. Press `C-x b` to leave the page.
4. [ ] `SPC l W`. Expect the dashboard in the external browser.

## 8. Project processes

1. [ ] In a repo, add `.cc-procs.el` with one entry and `:auto t`.
2. [ ] Switch to the project (`SPC p p`). Expect a question before the `:auto` entry starts.
3. [ ] `SPC l t`. Expect the process. Test `RET`, `R` and `x`.

## 9. Neovim inside Emacs

1. [ ] `SPC o n` in a repo. Expect `*nvim:<project>*` with Neovim.
2. [ ] In Neovim, type in insert mode, press `Esc`, `C-c` and `C-x`. Expect Neovim to get each key.
3. [ ] Press `M-SPC l a` in Neovim. Expect the Emacs agent list.
4. [ ] Split Neovim (`:vsplit`). Press `C-h/j/k/l`. Expect moves between splits, then into the Emacs window at the edge.
5. [ ] In an Emacs window in normal state, press `C-h/j/k/l`. Expect moves back into the Neovim window.
6. [ ] In Emacs on a file, press `SPC f n`. Expect the same file and line in Neovim.
7. [ ] Put point on `config/doom/init.el:34` in any buffer and press `SPC l e`. Expect Neovim at line 34.
8. [ ] In a Magit diff, press `C-RET` on a hunk. Expect Neovim at that line. `RET` still visits in Emacs.
9. [ ] `SPC s p`, search a word, press `C-;` then `n`. Expect the match in Neovim.
10. [ ] In `SPC l a`, press `e` on an agent. Expect Neovim in the agent's worktree.
11. [ ] Open a second repo and press `SPC o n`. Expect a second `*nvim:*` buffer with its own socket.
12. [ ] In Neovim, press `<leader>hg`, `<leader>ha` and `<leader>hr`. Expect Magit status, the agent list and the review queue.
13. [ ] Select lines in visual mode and press `<leader>hc`. Expect `@file#La-Lb` in this project's Claude prompt, not submitted.
14. [ ] Kill the Neovim buffer with `SPC b k` and press `SPC o n`. Expect a clean restart.
15. [ ] Open a Go or Python file in Emacs. Expect no LSP client to start (`my/nvim-lsp-off-modes`).

## 10. Neovim outside Emacs

1. [ ] In Ghostty with tmux, start `nvim`. Expect `C-h/j/k/l` to move between tmux panes as before.
2. [ ] Press `<leader>h`. Expect no hand-off group in which-key.

## 11. Haskell

1. [ ] Open a `.hs` file in a cabal project. Expect `haskell-language-server-wrapper` to start.
2. [ ] `SPC c k` on a symbol. Expect hoogle documentation.
