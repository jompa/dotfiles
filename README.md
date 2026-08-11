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
| `make install` | `submodules` then `link` |
| `make link` | Symlink configs into `$HOME` |
| `make dry-run` | Print the plan, change nothing |
| `make submodules` | Init/update Vundle |

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
- Vundle — vendored as a submodule, installed by `make submodules`
- `brew install ack ctags tmux`
- `tmuxp` for the `.tmuxp/` session layouts

## Vim

Plugins are managed by Vundle; run `:PluginInstall` in vim after the first
install.

### Active plugins

vim-powerline, vim-ack, vim-fugitive, fuzzyfinder, L9, NERDtree, NERDcomment,
tagbar, Syntastic, snipmate, Surround

### To look at

Repeat, Sparkup, Yankring, Codesniffer

## Tmux

`.tmux.conf` plus session layouts in `.tmuxp/` (`cc`, `dev`, `kafka-prod`, `lp`).
Start one with `tmuxp load dev`.
