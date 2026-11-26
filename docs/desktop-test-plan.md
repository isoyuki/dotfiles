# Desktop test plan

Use this list to try each integration once on a new machine or after a big
change. Tick a box when the result matches. When a result is wrong, write down
the step number and the text in `*Messages*` (`SPC h e`).

## 0. Before you start

- [ ] `doom doctor` shows only the Symbola warning.
- [ ] Start Emacs from the Dock or Raycast, not from a terminal, so the test uses the GUI environment.

## 1. OS layer

1. [ ] Tap Caps Lock. Expect `Esc`.
2. [ ] Hold Caps Lock and press `E`, `B`, `S`, `M`. Expect AeroSpace to show the Emacs, browser, Slack and meetings workspaces.
3. [ ] Press Hyper+`` ` ``. Expect the Ghostty quick terminal. Press it again to hide it.
4. [ ] Press Hyper+`Space`, then `e`. Expect Emacs to come to the front.
5. [ ] In Ghostty, run `tmux`, then press `C-Space T`. Expect the sesh picker.
6. [ ] In Ghostty, press `Cmd+O`. Expect the tms picker.

## 2. Neovim inside Emacs

1. [ ] `SPC o n` in a repo. Expect `*nvim:<project>*` with Neovim.
2. [ ] In Neovim, type in insert mode, press `Esc`, `C-c` and `C-x`. Expect Neovim to get each key.
3. [ ] Press `M-SPC g g` in Neovim. Expect Magit status.
4. [ ] Split Neovim (`:vsplit`). Press `C-h/j/k/l`. Expect moves between splits, then into the Emacs window at the edge.
5. [ ] In an Emacs window in normal state, press `C-h/j/k/l`. Expect moves back into the Neovim window.
6. [ ] In Emacs on a file, press `SPC f n`. Expect the same file and line in Neovim.
7. [ ] Put point on `config/doom/init.el:34` in any buffer and press `SPC l e`. Expect Neovim at line 34.
8. [ ] In a Magit diff, press `C-RET` on a hunk. Expect Neovim at that line. `RET` still visits in Emacs.
9. [ ] `SPC s p`, search a word, press `C-;` then `n`. Expect the match in Neovim.
10. [ ] Open a second repo and press `SPC o n`. Expect a second `*nvim:*` buffer with its own socket.
11. [ ] In Neovim, press `<leader>hg`. Expect Magit status in another window.
12. [ ] Kill the Neovim buffer with `SPC b k` and press `SPC o n`. Expect a clean restart.
13. [ ] Open a Go or Python file in Emacs. Expect no LSP client to start (`my/nvim-lsp-off-modes`).

## 3. Neovim outside Emacs

1. [ ] In Ghostty with tmux, start `nvim`. Expect `C-h/j/k/l` to move between tmux panes as before.
2. [ ] Press `<leader>h`. Expect no hand-off group in which-key.

## 4. Haskell

1. [ ] Open a `.hs` file in a cabal project. Expect `haskell-language-server-wrapper` to start.
2. [ ] `SPC c k` on a symbol. Expect hoogle documentation.
