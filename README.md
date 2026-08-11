# Jompa's dotfiles

## Install

```sh
git clone git@github.com:jompa/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make dry-run     # see what would happen
make install     # init submodules, then symlink
```

`make` on its own lists the available targets.

| Target | Does |
| --- | --- |
| `make deps` | Install dependencies (brew + gopls) |
| `make deps-check` | Report which dependencies are missing |
| `make install` | `submodules`, then `link`, then vim helptags |
| `make link` | Symlink configs into `$HOME` |
| `make dry-run` | Print the plan, change nothing |
| `make submodules` | Check out the vim plugins |
| `make vim-update` | Pull every vim plugin to latest upstream |
| `make vim-helptags` | Rebuild plugin `:help` tags |

Extra flags go through `ARGS`:

```sh
make link ARGS="--skip .gitconfig"
```

`--skip NAME` (repeatable), `--backup-dir DIR`, `--no-submodules`, `--dry-run`.
See `bin/link.sh --help`.

### Safety

Re-running is safe — links that are already correct report `ok` and are left
alone. Anything **real** that would be overwritten is moved to
`~/.dotfiles-backup/<UTC timestamp>/` first, keeping its path relative to
`$HOME`, so nothing is destroyed silently. Existing symlinks are replaced in
place, with their previous value printed. A failed entry doesn't stop the rest;
the exit code is non-zero if anything failed.

### What gets linked

| Repo | Target |
| --- | --- |
| `.vimrc`, `.vim/` | `~/.vimrc`, `~/.vim` |
| `.tmux.conf`, `.tmuxp/` | `~/.tmux.conf`, `~/.tmuxp` |
| `.gitconfig` | `~/.gitconfig` |
| `jompa.zsh`, `.mac_alias` | `~/jompa.zsh`, `~/.mac_alias` |
| `vscode/{settings,keybindings}.json` | `~/Library/Application Support/Code/User/` |
| `zed/{settings,keymap}.json` | `~/Library/Application Support/Zed/` |

The editor configs are linked as **individual files, never as directories** —
`~/Library/Application Support/Zed/` also holds live application state (`db/`,
`extensions/`, `threads/`) that linking the directory would destroy. Don't
convert those four rows in `bin/link.sh` into directory links.

### Code navigation (LSP, not ctags)

ALE doubles as an LSP client, so there's no tags file to regenerate and no
extra plugin:

| Key | Action |
| --- | --- |
| `gd` | go to definition |
| `gy` / `gi` | type definition / implementation |
| `gr` | find references |
| `K` | hover (type + docs) |
| `<leader>r` | rename symbol |
| `<leader>.` | code action |

Each language needs its server on `PATH`:

```sh
go install golang.org/x/tools/gopls@latest   # go
npm i -g typescript                          # tsserver
npm i -g pyright                             # python
```

vim-go's own gopls client and its `gd` binding are disabled
(`g:go_gopls_enabled`, `g:go_def_mapping_enabled`) so ALE is the single LSP
client and `gd` means the same thing in every filetype.

### Known gaps

- `/usr/bin/vim` (9.1) shadows the newer Homebrew vim (9.2), because
  `/opt/homebrew/bin` sits late in `PATH`. Both work with this config. Add
  `eval "$(/opt/homebrew/bin/brew shellenv)"` early in `.zshrc` if you want
  brew's tools to win generally — note that changes more than just vim.
- `jompa.zsh` and `.mac_alias` overlap on `gs`/`gd`/`gc`/`lns`; `.mac_alias` is
  sourced second and wins. Worth collapsing into one file.

## Dependencies

```sh
make deps-check   # what is missing
make deps         # install it
```

Installed automatically — `tmux`, `ripgrep`, `tmuxp` (Homebrew) and `gopls`
(`go install`). Re-running is a no-op.

Reported but **never** installed automatically:

- **oh-my-zsh** — its installer *replaces* `~/.zshrc`, which `make link` has
  made a symlink into this repo, so running it would undo the setup. Clone it
  directly instead: `git clone https://github.com/ohmyzsh/ohmyzsh.git
  ~/.oh-my-zsh`
- **go** — installed from the official tarball into `/usr/local/go`, not
  Homebrew, so there is nothing safe to automate. Only needed for vim-go and
  `gopls`; both stay quiet without it.
- **vim** — 8 or newer with `+packages` (`vim --version | grep packages`). A
  hard requirement, and not something to reinstall over blindly.

`ripgrep` is optional: `<leader>a` falls back to a recursive `grep` without it.

**No ctags.** Code navigation is LSP-based (see below), so there is no tags
file to generate. `/usr/bin/ctags` on macOS is BSD ctags, which only handles
C/Pascal/Fortran/Lisp/yacc anyway — it could not index Go, TypeScript or Python
even if something wanted it to.

## Vim

No plugin manager. Plugins use **Vim's built-in package support**
(`:help packages`): each is a git submodule under
`.vim/pack/plugins/start/`, so versions are pinned by this repo and a fresh
clone gets exactly what's running here.

```sh
make submodules     # check them out
make vim-update     # bump all to latest upstream, then commit the new pins
make vim-helptags   # after adding or updating a plugin
```

Add one:

```sh
git submodule add --depth 1 https://github.com/tpope/vim-repeat.git \
    .vim/pack/plugins/start/vim-repeat
make vim-helptags
```

Remove one:

```sh
git submodule deinit -f .vim/pack/plugins/start/vim-repeat
git rm -f .vim/pack/plugins/start/vim-repeat
rm -rf .git/modules/.vim/pack/plugins/start/vim-repeat
```

### Load order in `.vimrc` — read before editing

`start/` packages load *immediately after* `.vimrc` is sourced, not during. So
`.vimrc` calls `packloadall` explicitly partway through, which splits the file
in two:

- **Before `packloadall`**: plugin settings (`g:ale_*`, `g:ctrlp_*`,
  `NERDTree*`) **and `mapleader`** — plugins that build default mappings expand
  `<leader>` at load time, so setting it later silently binds them to `\`.
- **After `packloadall`**: anything needing a plugin present — `colorscheme
  solarized8`, and highlight overrides (a colorscheme resets every group, so
  `highlight clear ALEErrorSign` has to come after it).

`:packadd!` is not a shortcut for this — it only searches `pack/*/opt/`, never
`start/`.

### Commenting

vim-commentary, using the standard operator — no custom mappings:

| Key | Action |
| --- | --- |
| `gcc` | toggle current line |
| `gc{motion}` | toggle over a motion (`gcap` = paragraph) |
| `gc` (visual) | toggle the selection |

Replaced NERDCommenter's `<leader><Space>`. `gc` is the de facto standard and
is what Neovim adopted for its built-in commenting in 0.10.

### Active plugins

nerdtree, vim-commentary, ctrlp.vim, vim-airline, vim-solarized8, vim-surround,
vim-gitgutter, ale, vim-go, typescript-vim, bufexplorer, vim-fugitive

## Tmux

`.tmux.conf` plus session layouts in `.tmuxp/` (`cc`, `dev`, `kafka-prod`, `lp`).
Start one with `tmuxp load dev`.
