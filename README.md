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

### Known gaps

- **`.zshrc` is not linked.** The `.zshrc` in this repo has drifted from the
  live `~/.zshrc` (a newer oh-my-zsh config). Reconcile them by hand, then add
  a `.zshrc` row to `LINKS` in `bin/link.sh`.
- `jompa.zsh` and `.mac_alias` are linked but **nothing sources them**. Add
  `source ~/jompa.zsh` and `source ~/.mac_alias` to whichever `.zshrc` wins.
- The repo `.zshrc` still references dead paths (Python 2.7 in
  `/usr/local/Cellar`, old RVM/virtualenvwrapper).

## Dependencies

- [oh-my-zsh](https://ohmyz.sh) at `~/.oh-my-zsh`
- Vim 8 or newer (needs `+packages`; `vim --version | grep packages`)
- `brew install ripgrep` — used by `<leader>a` project search. Without it the
  config falls back to a recursive `grep`, which works but is slower.
- `brew install ctags tmux`
- `tmuxp` for the `.tmuxp/` session layouts
- `go` — only if you want vim-go's commands; it stays quiet when go is absent

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

### Active plugins

nerdtree, nerdcommenter, ctrlp.vim, vim-airline, vim-solarized8, vim-surround,
vim-gitgutter, ale, vim-go, typescript-vim, bufexplorer, vim-fugitive

## Tmux

`.tmux.conf` plus session layouts in `.tmuxp/` (`cc`, `dev`, `kafka-prod`, `lp`).
Start one with `tmuxp load dev`.
