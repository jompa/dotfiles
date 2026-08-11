#!/usr/bin/env bash
#
# Symlink dotfiles from this repo into $HOME.
#
# Idempotent: re-running reports "ok" for links that are already correct.
# Anything real that would be overwritten is moved to a timestamped backup
# directory first -- nothing is ever silently destroyed.
#
# Usage: bin/link.sh [--dry-run] [--skip NAME]... [--no-submodules]
# Run with --help for the full list.

# No `set -e`: one bad entry must not abort the remaining links.
set -u
IFS=$'\n\t'

# Re-exec under bash if invoked as `sh bin/link.sh`.
[ -n "${BASH_VERSION:-}" ] || exec /bin/bash "$0" "$@"

SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

DRY_RUN=0
DO_SUBMODULES=1
SUBMODULES_ONLY=0
BACKUP_ROOT="$HOME/.dotfiles-backup"
SKIPS=""

# ---------------------------------------------------------------- logging

if [ -t 1 ]; then
    C_RED=$'\033[31m'; C_YEL=$'\033[33m'; C_GRN=$'\033[32m'
    C_DIM=$'\033[2m';  C_OFF=$'\033[0m'
else
    C_RED=""; C_YEL=""; C_GRN=""; C_DIM=""; C_OFF=""
fi

info()   { printf '%s\n' "$*"; }
ok_msg() { printf '%s%s%s\n' "$C_GRN" "$*" "$C_OFF"; }
warn()   { printf '%s%s%s\n' "$C_YEL" "$*" "$C_OFF"; }
err()    { printf '%s%s%s\n' "$C_RED" "$*" "$C_OFF" >&2; }
die()    { err "error: $*"; exit 1; }

# ---------------------------------------------------------------- options

usage() {
    cat <<'EOF'
Symlink dotfiles into $HOME.

Usage: bin/link.sh [options]

Options:
  -n, --dry-run          Show what would happen; change nothing.
      --skip NAME        Skip an entry by name (repeatable).
                         NAME matches either the repo-relative source
                         (e.g. vscode/settings.json) or the target
                         basename (e.g. .vimrc).
      --no-submodules    Do not touch git submodules.
      --submodules-only  Only init/update submodules; create no links.
      --backup-dir DIR   Backup root (default: ~/.dotfiles-backup).
  -h, --help             This message.

Existing real files and directories are moved under
  <backup-dir>/<UTC timestamp>/
preserving their path relative to $HOME. Symlinks are replaced in place
(their previous value is printed, so nothing is lost silently).
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run)      DRY_RUN=1 ;;
        --no-submodules)   DO_SUBMODULES=0 ;;
        --submodules-only) SUBMODULES_ONLY=1 ;;
        --skip)
            [ $# -ge 2 ] || die "--skip needs a value"
            SKIPS="$SKIPS$2"$'\n'; shift ;;
        --backup-dir)
            [ $# -ge 2 ] || die "--backup-dir needs a value"
            BACKUP_ROOT="$2"; shift ;;
        -h|--help)         usage; exit 0 ;;
        *)                 err "unknown option: $1"; echo; usage; exit 2 ;;
    esac
    shift
done

# Guard against running from a directory that is not a dotfiles checkout,
# which would otherwise produce a wall of "missing source" errors.
[ -f "$SCRIPT_DIR/.vimrc" ] && [ -f "$SCRIPT_DIR/vscode/settings.json" ] \
    || die "not a dotfiles checkout: $SCRIPT_DIR"

# ---------------------------------------------------------------- link table
#
# One "source|target" record per line. Source is relative to the repo root
# and joined with $SCRIPT_DIR at use time, so the table stays valid for any
# clone location. No path here contains '|'.
#
# NOTE: vscode/ and zed/ are listed as INDIVIDUAL FILES, never as
# directories. "~/Library/Application Support/Zed" holds live application
# state (db/, extensions/, threads/); linking the directory would destroy it.
#
LINKS=(
    ".zshrc|$HOME/.zshrc"
    ".vimrc|$HOME/.vimrc"
    ".vim|$HOME/.vim"
    ".tmux.conf|$HOME/.tmux.conf"
    ".gitconfig|$HOME/.gitconfig"
    ".tmuxp|$HOME/.tmuxp"
    "jompa.zsh|$HOME/jompa.zsh"
    ".mac_alias|$HOME/.mac_alias"
    "vscode/settings.json|$HOME/Library/Application Support/Code/User/settings.json"
    "vscode/keybindings.json|$HOME/Library/Application Support/Code/User/keybindings.json"
    "zed/settings.json|$HOME/.config/zed/settings.json"
    "zed/keymap.json|$HOME/.config/zed/keymap.json"
)

# ---------------------------------------------------------------- state

n_ok=0; n_linked=0; n_backed=0; n_skipped=0; n_failed=0
FAILED_LIST=""
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_RUN="$BACKUP_ROOT/$STAMP"
backup_made=0

fail() { n_failed=$((n_failed + 1)); FAILED_LIST="$FAILED_LIST  $1"$'\n'; }

# Every mutation goes through run(), so --dry-run is side-effect-free.
run() {
    if [ "$DRY_RUN" = 1 ]; then
        # Local IFS: the global IFS=$'\n\t' would join "$*" with newlines.
        local IFS=' '
        printf '%sDRY-RUN  %s%s\n' "$C_DIM" "$*" "$C_OFF"
        return 0
    fi
    "$@"
}

should_skip() {
    case "$SKIPS" in
        *"$1"$'\n'*) return 0 ;;
        *"$2"$'\n'*) return 0 ;;
    esac
    return 1
}

# ---------------------------------------------------------------- backup

# Move an existing real file/dir into the backup run directory, mirroring its
# path under $HOME. Mirroring (rather than flattening) matters: a flat layout
# would collide vscode/settings.json with zed/settings.json.
backup_target() {
    local t="$1" rel dest
    case "$t" in
        "$HOME"/*) rel="${t#"$HOME"/}" ;;
        *)         rel="abs/$(printf '%s' "$t" | tr '/' '_')" ;;
    esac
    dest="$BACKUP_RUN/$rel"

    run mkdir -p "$(dirname -- "$dest")" || return 1
    run mv -- "$t" "$dest"               || return 1
    backup_made=1
    warn "    backed up existing -> $dest"
}

# ---------------------------------------------------------------- linking

link_one() {
    local src="$1" target="$2" name="$3" cur parent

    # (a) Source must exist. -e, not -f: .vim and .tmuxp are directories
    #     (testing -f here was the original script's central bug).
    if [ ! -e "$src" ]; then
        err "$name: missing source $src"
        fail "$name (missing source)"
        return 1
    fi

    # (b) Ensure the parent exists -- Code/User may be absent entirely.
    parent="$(dirname -- "$target")"
    if [ ! -d "$parent" ]; then
        run mkdir -p -- "$parent" \
            || { err "$name: cannot create $parent"; fail "$name (mkdir)"; return 1; }
        info "    created $parent"
    fi

    # (c) Classify the target. -L must be tested BEFORE -e, because -e
    #     follows symlinks and is false for a dangling one.
    if [ -L "$target" ]; then
        cur="$(readlink "$target")"
        if [ "$cur" = "$src" ]; then
            ok_msg "$name: ok"
            n_ok=$((n_ok + 1)); return 0
        fi
        if [ -e "$target" ] && [ "$target" -ef "$src" ]; then
            ok_msg "$name: ok (equivalent path: $cur)"
            n_ok=$((n_ok + 1)); return 0
        fi
        warn "$name: replacing symlink that pointed to $cur"
        run rm -f -- "$target" \
            || { err "$name: cannot remove stale link"; fail "$name (rm)"; return 1; }
    elif [ -e "$target" ]; then
        backup_target "$target" \
            || { err "$name: backup failed, leaving target untouched"; fail "$name (backup)"; return 1; }
        n_backed=$((n_backed + 1))
    fi

    # (d) Hard guard. Verified on macOS: `ln -sfn` over a real directory
    #     silently creates target/<basename> instead of refusing. Step (c)
    #     should have cleared the path; if anything real is still here, stop
    #     rather than nest a link inside it.
    if [ "$DRY_RUN" = 0 ] && [ ! -L "$target" ] && [ -e "$target" ]; then
        err "$name: $target still exists after backup; refusing to link into it"
        fail "$name (target not clear)"
        return 1
    fi

    # (e) Create. -n keeps ln from descending into a symlinked directory.
    run ln -sfn -- "$src" "$target" \
        || { err "$name: ln failed"; fail "$name (ln)"; return 1; }

    # (f) Verify what we actually created.
    if [ "$DRY_RUN" = 0 ]; then
        if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$src" ]; then
            err "$name: verification failed"
            fail "$name (verify)"
            return 1
        fi
    fi

    info "$name: linked -> $src"
    n_linked=$((n_linked + 1))
}

# ---------------------------------------------------------------- submodules

setup_submodules() {
    if [ "$DO_SUBMODULES" != 1 ]; then
        info "submodules: skipped (--no-submodules)"
        return 0
    fi
    command -v git >/dev/null 2>&1 || { warn "submodules: git not found, skipping"; return 0; }
    git -C "$SCRIPT_DIR" rev-parse --git-dir >/dev/null 2>&1 \
        || { warn "submodules: not a git repo, skipping"; return 0; }
    [ -f "$SCRIPT_DIR/.gitmodules" ] || return 0

    info "submodules: init"
    run git -C "$SCRIPT_DIR" submodule init || warn "submodules: init reported an error"

    # GitHub disabled the git:// protocol in 2022. Rewrite any such URL that
    # init copied into .git/config. This runs BETWEEN init and update because
    # .git/config is exactly where update reads the URL from.
    # Deliberately NOT `git submodule sync`, which would copy a stale
    # .gitmodules URL back over this fix.
    local key url
    while read -r key url; do
        [ -n "${key:-}" ] || continue
        case "$url" in
            git://github.com/*)
                run git -C "$SCRIPT_DIR" config "$key" \
                    "https://github.com/${url#git://github.com/}" \
                    && warn "submodules: rewrote $key from git:// to https://"
                ;;
        esac
    done < <(git -C "$SCRIPT_DIR" config --get-regexp '^submodule\..*\.url$' 2>/dev/null)

    info "submodules: update"
    run git -C "$SCRIPT_DIR" submodule update --recursive \
        || warn "submodules: update failed (network or auth?) -- vim plugins may be missing"
}

# ---------------------------------------------------------------- main

printf '\n'
info "dotfiles: $SCRIPT_DIR"
[ "$DRY_RUN" = 1 ] && warn "dry run -- nothing will be changed"
printf '\n'

setup_submodules
printf '\n'

if [ "$SUBMODULES_ONLY" = 1 ]; then
    info "--submodules-only: no links created"
    exit 0
fi

for row in "${LINKS[@]}"; do
    rel="${row%%|*}"
    target="${row#*|}"

    # Disambiguate the two settings.json entries in log output.
    name="$(basename -- "$target")"
    [ "$rel" = "$(basename -- "$rel")" ] || name="$rel"

    if should_skip "$rel" "$name"; then
        info "$name: skipped"
        n_skipped=$((n_skipped + 1))
        continue
    fi

    # Return value ignored on purpose: one failure must not stop the rest.
    link_one "$SCRIPT_DIR/$rel" "$target" "$name"
done

# ---------------------------------------------------------------- summary

printf '\n'
info "summary: $n_linked linked, $n_ok already ok, $n_backed backed up, $n_skipped skipped, $n_failed failed"

if [ "$backup_made" = 1 ]; then
    warn "backups saved under $BACKUP_RUN"
fi

if [ "$n_failed" -gt 0 ]; then
    err "failed:"
    printf '%s' "$FAILED_LIST" >&2
    exit 1
fi

ok_msg "done"
