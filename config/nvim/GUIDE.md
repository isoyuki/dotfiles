# Neovim Config - Complete Guide & Keymap Reference

> **Leader key: `Space`** | **Tip: Press `Space` and wait to see which-key popup**

---

## Table of Contents

1. [Core Basics](#1-core-basics)
2. [Navigation & Motion](#2-navigation--motion)
3. [File Management](#3-file-management)
4. [Search & Find (Telescope)](#4-search--find-telescope)
5. [LSP - Code Intelligence](#5-lsp---code-intelligence)
6. [Autocompletion (nvim-cmp)](#6-autocompletion-nvim-cmp)
7. [Git](#7-git)
8. [Debugging (DAP)](#8-debugging-dap)
9. [Testing (Neotest)](#9-testing-neotest)
10. [Code Editing Power Tools](#10-code-editing-power-tools)
11. [Diagnostics & Trouble](#11-diagnostics--trouble)
12. [Search & Replace (Spectre)](#12-search--replace-spectre)
13. [Notifications (Noice)](#13-notifications-noice)
14. [Misc Utilities](#14-misc-utilities)
15. [Practice Drills](#15-practice-drills)

---

## 1. Core Basics

Your config uses **Space** as leader. Relative line numbers are on. Clipboard syncs with OS.

| Key | Mode | Action |
|-----|------|--------|
| `Esc` | Normal | Clear search highlights |
| `Esc Esc` | Terminal | Exit terminal mode |
| `C-h/j/k/l` | Normal | Navigate between splits (works across tmux panes too) |
| `C-Left/Down/Up/Right` | Normal | Same as above (arrow key variant) |

**Options to know:**
- `scrolloff=10` - cursor always has 10 lines of context
- `inccommand=split` - live preview of `:s/old/new/` substitutions
- `smartcase` - search is case-insensitive unless you use uppercase
- `undofile` - undo history persists across sessions

---

## 2. Navigation & Motion

### Flash (s/S) - Lightning-fast jumps

Flash replaces the default `s` key. It lets you jump anywhere visible in 2-3 keystrokes.

| Key | Mode | Action |
|-----|------|--------|
| `s` | n/x/o | **Flash jump** - type chars, then the label to jump |
| `S` | n/x/o | **Flash Treesitter** - select by syntax node |
| `r` | Operator-pending | **Remote Flash** - operate on remote location |
| `R` | o/x | **Treesitter search** - search + select syntax nodes |
| `C-s` | Command-line | Toggle Flash in search mode |

**How to use Flash:**
1. Press `s` in normal mode
2. Start typing characters of your target (e.g., `fu` for a function)
3. Labels appear on all matches - press the label letter to jump
4. Use `S` to select entire syntax blocks (functions, if-blocks, etc.)

### Harpoon - Pin your most-used files

Mark up to 4 files for instant switching. Think of it as bookmarks on steroids.

| Key | Mode | Action |
|-----|------|--------|
| `Space a` | Normal | **Add** current file to harpoon list |
| `C-e` | Normal | **Open** harpoon list (in Telescope) |
| `Space 1` | Normal | Jump to harpoon file **1** |
| `Space 2` | Normal | Jump to harpoon file **2** |
| `Space 3` | Normal | Jump to harpoon file **3** |
| `Space 4` | Normal | Jump to harpoon file **4** |
| `C-S-P` | Normal | Previous harpoon file |
| `C-S-N` | Normal | Next harpoon file |

**Workflow:** When working on a feature, `Space a` the 3-4 files you bounce between (e.g., model, handler, test), then use `Space 1/2/3/4` to instantly switch.

### Marks - Visual bookmarks within files

| Key | Mode | Action |
|-----|------|--------|
| `m,` | Normal | Set next available mark |
| `m]` | Normal | Jump to next mark |
| `m[` | Normal | Jump to previous mark |
| `m:` | Normal | Preview mark |
| `dm-` | Normal | Delete mark on current line |
| `dm<space>` | Normal | Delete all marks in buffer |
| `m<letter>` | Normal | Set mark (a-z local, A-Z global) |
| `'<letter>` | Normal | Jump to mark |

### Treesitter Context

Shows the enclosing function/class at the top of the screen when you scroll deep into code.

| Key | Mode | Action |
|-----|------|--------|
| `gC` | Normal | Jump up to the context (enclosing function/class) |
| `Space tc` | Normal | Toggle treesitter context display |

---

## 3. File Management

### Neo-tree - Sidebar file explorer

| Key | Mode | Action |
|-----|------|--------|
| `Space E` | Normal | **Toggle** Neo-tree sidebar |
| `Space ef` | Normal | **Reveal** current file in Neo-tree |

### Oil - Edit directories like buffers

Oil opens directories as editable buffers. Rename files by editing text, delete by deleting lines, etc.

| Key | Mode | Action |
|-----|------|--------|
| `Space o` | Normal | **Open** Oil (parent directory) |

**Inside Oil:** Edit filenames to rename, `dd` a line to delete, paste lines to copy. Save with `:w` to apply.

### Telescope File Browser

| Key | Mode | Action |
|-----|------|--------|
| `Space fb` | Normal | **File browser** from current file's directory |

---

## 4. Search & Find (Telescope)

Telescope is your Swiss-army knife for finding anything. All pickers support fuzzy matching.

### File search

| Key | Mode | Action |
|-----|------|--------|
| `Space sf` | Normal | **Search files** (respects .gitignore) |
| `Space s.` | Normal | **Recent files** (oldfiles) |
| `Space Space` | Normal | **Open buffers** |
| `Space sn` | Normal | **Search Neovim config** files |

### Content search

| Key | Mode | Action |
|-----|------|--------|
| `Space sl` | Normal | **Live grep** - search text across all files |
| `Space sw` | Normal | **Grep current word** under cursor |
| `Space /` | Normal | **Fuzzy find** in current buffer (dropdown) |
| `Space s/` | Normal | **Live grep in open files** only |

### Other pickers

| Key | Mode | Action |
|-----|------|--------|
| `Space sh` | Normal | Search **help** tags |
| `Space sk` | Normal | Search **keymaps** (great for discovering bindings!) |
| `Space ss` | Normal | Search Telescope **builtins** |
| `Space sd` | Normal | Search **diagnostics** |
| `Space sr` | Normal | **Resume** last Telescope search |
| `Space st` | Normal | Search **TODO** comments |
| `Space sx` | Normal | Search **TODO/FIX/FIXME** comments |

### Git search (via Telescope)

| Key | Mode | Action |
|-----|------|--------|
| `Space sgf` | Normal | Search **git files** |
| `Space sgg` | Normal | Search **git status** (changed files) |
| `Space sgc` | Normal | Search **git commits** |
| `Space sgb` | Normal | Search **git branches** |

**Inside Telescope:**
- Type to filter results
- `C-n` / `C-p` or `Tab` / `S-Tab` - navigate results
- `Enter` - select
- `C-x` - open in horizontal split
- `C-v` - open in vertical split
- `C-t` - open in new tab

---

## 5. LSP - Code Intelligence

These keymaps activate automatically when an LSP server attaches to a buffer.

### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `gd` | Normal | **Go to definition** |
| `gr` | Normal | **Go to references** (via Telescope) |
| `gI` | Normal | **Go to implementation** |
| `gD` | Normal | **Go to declaration** (e.g., C headers) |
| `C-t` | Normal | **Jump back** (after gd/gr/gI) |

### Information

| Key | Mode | Action |
|-----|------|--------|
| `K` | Normal | **Hover docs** - show documentation popup |
| `Space D` | Normal | **Type definition** - jump to type |
| `Space ds` | Normal | **Document symbols** - list all symbols in file |
| `Space ws` | Normal | **Workspace symbols** - search symbols across project |

### Actions

| Key | Mode | Action |
|-----|------|--------|
| `Space rn` | Normal | **Rename** symbol (uses inc-rename for live preview) |
| `Space ca` | Normal | **Code action** (quickfix, refactor suggestions) |
| `Space th` | Normal | **Toggle inlay hints** (type annotations inline) |

### Diagnostics

| Key | Mode | Action |
|-----|------|--------|
| `[d` | Normal | Go to **previous** diagnostic |
| `]d` | Normal | Go to **next** diagnostic |
| `Space e` | Normal | Show diagnostic **float** |
| `Space q` | Normal | Open diagnostic **quickfix list** |

**Configured LSP servers:** `clangd` (C/C++), `gopls` (Go), `pyright` (Python), `texlab` (LaTeX), `terraformls` (Terraform), `lua_ls` (Lua), plus `rust-analyzer` via rustaceanvim.

---

## 6. Autocompletion (nvim-cmp)

Completion appears automatically as you type. Sources: LSP, snippets, file paths.

| Key | Mode | Action |
|-----|------|--------|
| `Tab` / `C-n` | Insert | Select **next** completion item |
| `S-Tab` / `C-p` | Insert | Select **previous** completion item |
| `Enter` / `C-y` | Insert | **Accept** completion |
| `C-Space` | Insert | **Manually trigger** completion menu |
| `C-b` / `C-f` | Insert | **Scroll** documentation up/down |
| `C-l` | Insert/Select | **Jump forward** in snippet |
| `C-h` | Insert/Select | **Jump backward** in snippet |

**Snippet workflow:** Accept a snippet with `Enter`, then use `C-l` to jump through placeholders, `C-h` to go back.

---

## 7. Git

### Fugitive - Git commands

| Key | Mode | Action |
|-----|------|--------|
| `Space gs` | Normal | **Git status** (interactive staging window) |
| `Space gc` | Normal | **Git commit** |
| `Space gb` | Normal | **Git blame** (full file) |
| `Space gl` | Normal | **Git log** |

**Inside Fugitive status (`Space gs`):**
- `s` - stage file/hunk
- `u` - unstage file/hunk
- `=` - toggle inline diff
- `cc` - commit
- `dv` - open file in diff split

### Gitsigns - Hunk-level operations

| Key | Mode | Action |
|-----|------|--------|
| `]h` | Normal | Jump to **next** changed hunk |
| `[h` | Normal | Jump to **previous** changed hunk |
| `Space gh` | Normal | **Preview** hunk (inline popup) |
| `Space gr` | Normal | **Reset** hunk (discard changes) |
| `Space gS` | Normal | **Stage** hunk |
| `Space gab` | Normal | **Stage entire buffer** |
| `Space gu` | Normal | **Undo stage** hunk |
| `Space gB` | Normal | **Blame** current line (full detail) |
| `Space gD` | Normal | **Diff** this file |

### Diffview - Full diff UI

| Key | Mode | Action |
|-----|------|--------|
| `Space gd` | Normal | **Toggle** diffview (all changes) |
| `Space gfh` | Normal | **File history** for current file |

---

## 8. Debugging (DAP)

Works with Go, Python, and Rust (via neotest-dap). Set breakpoints, step through code, inspect variables.

| Key | Mode | Action |
|-----|------|--------|
| `Space dt` | Normal | **Toggle breakpoint** |
| `Space dB` | Normal | **Conditional breakpoint** (prompted for condition) |
| `Space dc` | Normal | **Continue** (start/resume debugging) |
| `Space dC` | Normal | **Run to cursor** |
| `Space di` | Normal | **Step into** |
| `Space do` | Normal | **Step over** |
| `Space dO` | Normal | **Step out** |
| `Space dr` | Normal | **Open REPL** |
| `Space dq` | Normal | **Quit** debugging session |
| `Space du` | Normal | **Toggle DAP UI** (variables, watches, etc.) |

**Debugging workflow:**
1. `Space dt` on lines you want to inspect
2. `Space dc` to start debugging
3. `Space du` to open the UI (variables, call stack, watches)
4. `Space di/do/dO` to step through code
5. `Space dq` when done

---

## 9. Testing (Neotest)

Run tests inline with results displayed in the sign column. Supports Python, Go, Rust.

| Key | Mode | Action |
|-----|------|--------|
| `Space tn` | Normal | Run **nearest** test |
| `Space tf` | Normal | Run all tests in **file** |
| `Space ta` | Normal | Run **all** tests in project |
| `Space tl` | Normal | **Re-run last** test |
| `Space ts` | Normal | Toggle test **summary** panel |
| `Space to` | Normal | Toggle **output** panel |
| `Space tO` | Normal | Show **output** for nearest test |
| `Space td` | Normal | **Debug** nearest test (launches DAP) |
| `Space tS` | Normal | **Stop** running test |
| `Space tw` | Normal | **Watch** file (re-run on save) |
| `]T` | Normal | Jump to next **failed** test |
| `[T` | Normal | Jump to previous **failed** test |

**TDD workflow:**
1. `Space tw` to start watching the current test file
2. Write code - tests re-run automatically on save
3. `]T` / `[T` to jump between failures
4. `Space tO` to see failure details
5. `Space td` to debug a tricky test with DAP

---

## 10. Code Editing Power Tools

### Surround (nvim-surround)

Add, change, or delete surrounding characters. Think quotes, brackets, tags.

| Key | Mode | Action | Example |
|-----|------|--------|---------|
| `ys<motion><char>` | Normal | **Add** surrounding | `ysiw"` - surround word with `"` |
| `yss<char>` | Normal | **Surround line** | `yss)` - wrap line in `()` |
| `ds<char>` | Normal | **Delete** surrounding | `ds"` - remove surrounding `"` |
| `cs<old><new>` | Normal | **Change** surrounding | `cs"'` - change `"` to `'` |
| `S<char>` | Visual | **Surround selection** | Select + `S"` wraps in `"` |

**Common patterns:**
- `ysiw)` - surround inner word with parens: `word` -> `(word)`
- `ysiw"` - surround inner word with quotes: `word` -> `"word"`
- `cs'"` - change single quotes to double: `'hello'` -> `"hello"`
- `ds(` - delete parens: `(hello)` -> `hello`
- `ysa")` - surround around quotes with parens: `"hello"` -> `("hello")`

### Mini.ai - Enhanced text objects

Better inner/around text objects with `next`/`last` support.

| Key | Mode | Action |
|-----|------|--------|
| `va)` | Normal | **Visually select around** parentheses |
| `ci'` | Normal | **Change inside** quotes |
| `din)` | Normal | **Delete inside next** parens |
| `yal)` | Normal | **Yank around last** parens |

### Comment (gcc/gc)

| Key | Mode | Action |
|-----|------|--------|
| `gcc` | Normal | **Toggle comment** on current line |
| `gc` | Visual | **Toggle comment** on selection |

### Refactoring

| Key | Mode | Action |
|-----|------|--------|
| `Space re` | Visual | **Extract** to function |
| `Space rf` | Visual | **Extract to file** |
| `Space rv` | Visual | **Extract variable** |
| `Space ri` | Normal/Visual | **Inline variable** |
| `Space rI` | Normal | **Inline function** |
| `Space rb` | Normal | **Extract block** |
| `Space rbf` | Normal | **Extract block to file** |
| `Space rr` | Normal/Visual | Open refactoring **Telescope picker** |

### Formatting & Linting

| Key | Mode | Action |
|-----|------|--------|
| `Space f` | Any | **Format** buffer (auto-formats on save too) |
| `Space ll` | Normal | **Lint** current buffer |

Formatters: `stylua` (Lua), `clang-format` (C), `rustfmt` (Rust), `ruff` (Python).
Linters: `ruff` (Python), `golangcilint` (Go), `cpplint` (C/C++), `markdownlint` (Markdown).

---

## 11. Diagnostics & Trouble

Trouble provides a persistent panel for viewing diagnostics, symbols, and LSP results.

| Key | Mode | Action |
|-----|------|--------|
| `Space xx` | Normal | Toggle **all diagnostics** |
| `Space xX` | Normal | Toggle **buffer diagnostics** only |
| `Space cs` | Normal | Toggle **symbols** panel |
| `Space cl` | Normal | Toggle **LSP definitions/references** panel |
| `Space xL` | Normal | Toggle **location list** |
| `Space xQ` | Normal | Toggle **quickfix list** |

### Aerial - Code outline

| Key | Mode | Action |
|-----|------|--------|
| `Space A` | Normal | Toggle **Aerial** code outline sidebar |

---

## 12. Search & Replace (Spectre)

Project-wide search and replace with preview.

| Key | Mode | Action |
|-----|------|--------|
| `Space Sr` | Normal | Open **Spectre** (full search & replace) |
| `Space Sw` | Normal/Visual | Spectre with **current word** |
| `Space Sf` | Normal | Spectre scoped to **current file** |

**Inside Spectre:**
- Edit the search/replace fields
- `dd` on a result to exclude it
- `<leader>R` to replace all
- `<leader>rc` to replace current

---

## 13. Notifications (Noice)

Noice replaces the default command line and notification system.

| Key | Mode | Action |
|-----|------|--------|
| `Space nd` | Normal | **Dismiss** all notifications |
| `Space nl` | Normal | Show **last** notification |
| `Space nh` | Normal | Show notification **history** |
| `Space na` | Normal | Show **all** messages |
| `C-f` | n/i/s | **Scroll forward** in LSP docs/hover |
| `C-b` | n/i/s | **Scroll backward** in LSP docs/hover |

---

## 14. Misc Utilities

### Undotree - Visual undo history

| Key | Mode | Action |
|-----|------|--------|
| `Space u` | Normal | Toggle **undo tree** (branching undo history) |

### BQF - Better quickfix

| Key | Mode | Action |
|-----|------|--------|
| `Space p` | Normal | Toggle quickfix **preview** |

### Suda - Write with sudo

Use `:SudaWrite` to save files that need root permissions.

### Autopairs

Automatically closes `()`, `[]`, `{}`, `""`, `''` as you type. Integrated with nvim-cmp.

### Vim-sleuth

Automatically detects indent style (tabs vs spaces, width) from the file.

### Which-key

Press any prefix (like `Space`) and **wait** - a popup shows all available continuations. This is your built-in cheat sheet.

---

## 15. Practice Drills

Work through these exercises to build muscle memory. Do each drill until it feels natural.

### Drill 1: Navigation basics (5 min daily)
1. Open any project. Use `Space sf` to find and open a file
2. Use `Space sl` to grep for a function name, jump to it
3. Use `s` (Flash) to jump to 5 different locations on screen
4. Use `S` (Flash Treesitter) to select a function body
5. Use `Space Space` to switch between open buffers
6. Use `Space s.` to reopen a recently closed file

### Drill 2: Harpoon workflow (practice per project)
1. Open your 3 most important files with `Space sf`
2. In each one, press `Space a` to add to harpoon
3. Practice: `Space 1` -> file 1, `Space 2` -> file 2, `Space 3` -> file 3
4. Use `C-e` to see your harpoon list in Telescope
5. Goal: never use `Space sf` for your core files during a session

### Drill 3: LSP power moves (10 min)
1. Open a codebase you know. Put cursor on a function call
2. `gd` to jump to definition, `C-t` to come back
3. `gr` to see all references across the project
4. `K` to see documentation
5. `Space rn` to rename a variable - watch it update everywhere
6. `Space ca` on a diagnostic to see code actions
7. `Space ds` to see all symbols in the file

### Drill 4: Git workflow (10 min)
1. Make some changes to a file
2. `]h` / `[h` to jump between changed hunks
3. `Space gh` to preview a hunk
4. `Space gS` to stage a hunk (not the whole file!)
5. `Space gs` to open Fugitive status, review staged changes
6. `Space gd` to open Diffview for a full picture
7. `Space gb` to see blame annotations

### Drill 5: Test & Debug cycle (15 min)
1. Open a test file. `Space tn` to run the nearest test
2. `Space ts` to open the summary panel
3. `Space tf` to run all tests in the file
4. If a test fails: `]T` to jump to it, `Space tO` for details
5. Set a breakpoint with `Space dt`, then `Space td` to debug-run the test
6. `Space du` to open DAP UI, `Space di` to step into

### Drill 6: Editing efficiency (10 min)
1. Practice surround: put cursor on a word, `ysiw"` to quote it
2. Change the quotes: `cs"'` (double to single)
3. Delete the quotes: `ds'`
4. Select a block visually, `S(` to wrap in parens
5. Use `gcc` to comment a line, undo with `gcc` again
6. Select 5 lines, `gc` to comment them all
7. Use `Space f` to format the buffer

### Drill 7: Search & Replace (5 min)
1. `Space Sw` on a variable name to open Spectre with it
2. Type the replacement in the replace field
3. Review matches, `dd` to exclude any you don't want
4. Replace all remaining matches
5. For buffer-only: use `Space Sf` instead

---

## Quick Reference Card

Print this or keep it nearby until the keymaps are second nature.

```
NAVIGATE                          SEARCH (Space s...)
s         Flash jump              sf  Files
S         Flash treesitter        sl  Live grep (content)
gd        Go to definition        sw  Grep current word
gr        Go to references        sk  Keymaps
gD        Go to declaration       sh  Help
K         Hover docs              sr  Resume last search
C-t       Jump back               s.  Recent files
gC        Jump to context         st  TODO comments
                                  Space Space  Buffers
FILES                             Space /      Fuzzy in buffer
Space E   Toggle Neo-tree
Space ef  Reveal in Neo-tree    GIT (Space g...)
Space o   Oil (edit dirs)       gs  Status (Fugitive)
Space fb  File browser          gc  Commit
                                gb  Blame
HARPOON                         gh  Preview hunk
Space a   Add file              gr  Reset hunk
C-e       Open list             gS  Stage hunk
Space 1/2/3/4  File 1/2/3/4         gd  Toggle Diffview

CODE                            DEBUG (Space d...)
Space rn  Rename                dt  Toggle breakpoint
Space ca  Code action           dc  Continue
Space f   Format                di  Step into
Space re  Extract (visual)      do  Step over
Space ri  Inline variable       du  Toggle DAP UI
gcc / gc  Toggle comment        dq  Quit

TEST (Space t...)               DIAGNOSTICS
tn  Run nearest                 [d / ]d  Prev/next diagnostic
tf  Run file                    Space e  Show diagnostic float
ta  Run all                     Space xx Toggle Trouble
td  Debug test                  Space cs Symbols panel
ts  Toggle summary
tw  Watch file                  MISC
]T  Next failed test            Space u   Undo tree
                                Space Sr  Search & Replace
                                Space nd  Dismiss notifications
```
