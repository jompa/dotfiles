# CLAUDE.md

Personal dotfiles for macOS + zsh + vim, installed by symlinking into `$HOME`.

Entry point is the `Makefile` (`make` lists targets). Logic lives in
`bin/link.sh`; the Makefile is a dispatcher only.

## This repo is public

`git@github.com:jompa/dotfiles.git` is a **public** GitHub repo. Never commit a
credential, token, internal hostname, or anything company-confidential. A Snyk
API token was committed here in 2022 and stayed public for four years before
being purged in August 2026 — assume anything pushed is permanently harvested.

Do not track `~/.claude/` wholesale. See "Claude Code config" below.

## Hard invariants

Violating any of these silently breaks or destroys something.

**Editor configs are linked as individual files, never as directories.**
`~/Library/Application Support/Zed/` and `.../Code/User/` hold live application
state (`db/`, `extensions/`, `threads/`). Linking the repo's `zed/` or
`vscode/` directory over them destroys it. The `LINKS` table in `bin/link.sh`
lists four individual `.json` files for this reason — do not "simplify" them
into two directory rows.

**`.vimrc` load order matters.** Plugins in `.vim/pack/*/start/` are loaded
*after* `.vimrc` is sourced, so `.vimrc` calls `packloadall` explicitly partway
through. That splits the file:

- Before `packloadall`: plugin settings (`g:ale_*`, `g:ctrlp_*`, `NERDTree*`)
  **and `mapleader`** — plugins expand `<leader>` at load time, so setting it
  later leaves their default mappings bound to `\`.
- After `packloadall`: anything needing a plugin present — `colorscheme
  solarized8`, and highlight overrides, since a colorscheme resets every
  highlight group.

`:packadd!` is not a shortcut for this; it only searches `pack/*/opt/`, never
`start/`. Verified, not assumed.

**Toolchain is old.** `/bin/bash` is 3.2.57 — no associative arrays, no
`mapfile`/`readarray`. `make` is GNU Make 3.81 — no `.ONESHELL`, so each recipe
line runs in its own shell. This is why non-trivial logic is in `bin/link.sh`
rather than the Makefile.

**`bin/link.sh` contract.** Idempotent (an already-correct link reports `ok`);
backs up anything real to `~/.dotfiles-backup/<UTC stamp>/` mirroring the path
under `$HOME`; never `exit`s on a single failure, and returns non-zero if any
entry failed. Keep every mutation inside the `run()` wrapper so `--dry-run`
stays side-effect-free. `ln -sfn` over a *real* directory silently nests on
macOS (tested), so the explicit pre-`ln` guard is load-bearing.

**Vim plugins are git submodules under `.vim/pack/plugins/start/`.** No plugin
manager. Do not reintroduce Vundle, Pathogen, or vim-plug.

## Testing conventions

**Never test vim with `vim -es`.** Silent Ex mode does not source `~/.vimrc`
while still auto-loading packages, so plugins run under Vi defaults and throw
spurious `E10`/`E697` line-continuation errors that look like real config bugs.
Use a real pty:

```sh
script -q /dev/null vim -c "redir! > /tmp/m.txt" -c 'silent messages' \
    -c 'redir END' -c 'qa!' </dev/null >/dev/null 2>&1
```

Checking stderr alone is not enough — vimrc errors land in `:messages`, not
stderr.

Before any link change, run `make dry-run` and confirm the plan. After linking,
confirm `ls "$HOME/Library/Application Support/Zed"` still shows `db/` and
`extensions/`.

## Verify tools exist before configuring them

This repo has a long history of configuration for software that is not
installed — every instance was found by checking rather than reading:

- `ag.vim` configured, `ag` never installed (`<leader>a` silently dead)
- `.mac_alias` pinned `ctags` to a nonexistent `/usr/local/bin/ctags`, which
  would have shadowed the real `/usr/bin/ctags`. (Nothing needs ctags now —
  navigation is LSP-based — and the system one is BSD ctags, which cannot index
  Go, TypeScript or Python regardless.)
- the old `.zshrc` sourced a missing `virtualenvwrapper.sh` on every shell start
- all 13 `start_directory` paths in `.tmuxp/*.yaml` point at `/Users/jompa` or
  `/home/jompa`; the user is `johan.kock`, so none exist
- `vscode/settings.json` configures GitHub Copilot; the extension is not
  installed
- Go was installed at `/usr/local/go` but never added to `PATH`

So: `command -v` the binary before adding config that depends on it, and make
config degrade gracefully when it is absent (see the `rg` → `grep` fallback for
`grepprg`, which is required, not cosmetic — Vim's default `grepprg` searches no
files when given only a pattern).

## Claude Code config

Safe to track and symlink from here: `settings.json`, `CLAUDE.md`, and
`commands/`, `agents/`, `skills/`, `output-styles/` — after checking them for
internal hostnames and project names.

Never track: `projects/`, `sessions/`, `history.jsonl`, `file-history/`,
`shell-snapshots/`, `plans/`, `cache/`, `backups/`, `.credentials.json`,
`session-env/`, `*-cache.json`. These contain full session transcripts, shell
environments, and file snapshots. Confirmed by grep: the purged Snyk token
still sits in 5 files across `projects/`, `plans/`, and `file-history/`.

## Known gaps

- `.tmuxp/*.yaml` start directories are all stale (see above); they also embed
  internal GCP project names and Kafka hostnames in a public repo.
- `jompa.zsh` and `.mac_alias` overlap on `gs`/`gd`/`gc`/`lns`; `.mac_alias` is
  sourced second and wins. Worth collapsing.
- `/usr/bin/vim` (9.1) shadows the newer Homebrew vim (9.2) because
  `/opt/homebrew/bin` sits late in `PATH`.
