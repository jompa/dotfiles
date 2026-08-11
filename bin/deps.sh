#!/usr/bin/env bash
#
# Install the tools this config depends on.
#
# Only installs what can be installed safely and idempotently. Two things are
# deliberately reported rather than installed -- see MANUAL below.
#
# Usage: bin/deps.sh [--check] [--dry-run]

set -u
IFS=$'\n\t'

[ -n "${BASH_VERSION:-}" ] || exec /bin/bash "$0" "$@"

SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

# make(1) and other non-interactive shells never source ~/.zshrc, so the Go
# paths it exports are absent here. Add the well-known locations before probing,
# otherwise go and gopls look missing when they are merely not on this PATH.
[ -d /usr/local/go/bin ] && PATH="$PATH:/usr/local/go/bin"
[ -d "${GOPATH:-$HOME/go}/bin" ] && PATH="$PATH:${GOPATH:-$HOME/go}/bin"
export PATH

CHECK_ONLY=0
DRY_RUN=0

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

usage() {
    cat <<'EOF'
Install the tools this config depends on.

Usage: bin/deps.sh [options]

Options:
  --check      Report what is present or missing; install nothing.
  -n, --dry-run  Show the commands that would run; change nothing.
  -h, --help   This message.

Installs via Homebrew: tmux, ripgrep, tmuxp
Installs via go:       gopls (only if go is present)

Never installs (reported instead):
  oh-my-zsh  its installer replaces ~/.zshrc, which `make link` has made a
             symlink into this repo -- running it would undo that
  go         installed from the official tarball into /usr/local/go, not brew
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --check)       CHECK_ONLY=1 ;;
        -n|--dry-run)  DRY_RUN=1 ;;
        -h|--help)     usage; exit 0 ;;
        *)             err "unknown option: $1"; echo; usage; exit 2 ;;
    esac
    shift
done

run() {
    if [ "$DRY_RUN" = 1 ]; then
        local IFS=' '
        printf '%sDRY-RUN  %s%s\n' "$C_DIM" "$*" "$C_OFF"
        return 0
    fi
    "$@"
}

n_ok=0; n_installed=0; n_failed=0; n_manual=0
FAILED_LIST=""

# Homebrew formulae, "formula|binary" -- the binary is what gets probed, since
# formula name and command name do not always match.
BREW_DEPS=(
    "tmux|tmux"
    "ripgrep|rg"
    "tmuxp|tmuxp"
)

have() { command -v "$1" >/dev/null 2>&1; }

# --------------------------------------------------------------- homebrew

do_brew() {
    if ! have brew; then
        warn "homebrew not found -- skipping tmux, ripgrep, tmuxp"
        warn "  install it from https://brew.sh, then re-run"
        n_manual=$((n_manual + 1))
        return 0
    fi

    local row formula binary
    for row in "${BREW_DEPS[@]}"; do
        formula="${row%%|*}"
        binary="${row#*|}"

        if have "$binary"; then
            ok_msg "$formula: ok ($(command -v "$binary"))"
            n_ok=$((n_ok + 1))
            continue
        fi

        if [ "$CHECK_ONLY" = 1 ]; then
            warn "$formula: MISSING"
            n_failed=$((n_failed + 1))
            continue
        fi

        info "$formula: installing"
        if run brew install "$formula"; then
            n_installed=$((n_installed + 1))
        else
            err "$formula: brew install failed"
            FAILED_LIST="$FAILED_LIST  $formula"$'\n'
            n_failed=$((n_failed + 1))
        fi
    done
}

# --------------------------------------------------------------- go tooling

do_gopls() {
    if ! have go; then
        # Probe the tarball location too: go is installed there but is only on
        # PATH once the .zshrc from this repo is active.
        if [ -x /usr/local/go/bin/go ]; then
            warn "gopls: go exists at /usr/local/go/bin but is not on PATH"
            warn "  open a new shell after \`make link\`, then re-run"
        else
            warn "gopls: skipped, go is not installed (see MANUAL below)"
        fi
        n_manual=$((n_manual + 1))
        return 0
    fi

    if have gopls; then
        ok_msg "gopls: ok ($(command -v gopls))"
        n_ok=$((n_ok + 1))
        return 0
    fi

    if [ "$CHECK_ONLY" = 1 ]; then
        warn "gopls: MISSING"
        n_failed=$((n_failed + 1))
        return 0
    fi

    info "gopls: installing (go install, this fetches from the module proxy)"
    if run go install golang.org/x/tools/gopls@latest; then
        n_installed=$((n_installed + 1))
    else
        err "gopls: go install failed"
        FAILED_LIST="$FAILED_LIST  gopls"$'\n'
        n_failed=$((n_failed + 1))
    fi
}

# --------------------------------------------------------------- manual only

report_manual() {
    printf '\n'
    info "MANUAL -- not installed automatically:"

    if [ -d "$HOME/.oh-my-zsh" ]; then
        ok_msg "  oh-my-zsh: ok ($HOME/.oh-my-zsh)"
    else
        warn "  oh-my-zsh: MISSING"
        info "    The upstream installer REPLACES ~/.zshrc, which is a symlink"
        info "    into this repo after \`make link\`. Install it first, or clone"
        info "    it without running the installer:"
        info "      git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh"
        info "    then re-run \`make link\`."
    fi

    if have go; then
        ok_msg "  go: ok ($(command -v go))"
    elif [ -x /usr/local/go/bin/go ]; then
        warn "  go: present at /usr/local/go but not on PATH in this shell"
        info "    The .zshrc in this repo adds it; open a new shell."
    else
        warn "  go: MISSING"
        info "    Official installer (not brew, so it is not managed above):"
        info "      https://go.dev/dl/  -- installs to /usr/local/go"
    fi

    # Vim is a hard requirement, not something to install blindly over.
    if have vim && vim --version 2>/dev/null | grep -q '+packages'; then
        ok_msg "  vim: ok ($(vim --version | head -1 | cut -d' ' -f1-5), +packages)"
    else
        err "  vim: missing or built without +packages"
        info "    The plugin setup needs Vim 8+ with +packages: brew install vim"
        n_failed=$((n_failed + 1))
    fi
}

# --------------------------------------------------------------- main

printf '\n'
info "dotfiles deps: $SCRIPT_DIR"
[ "$CHECK_ONLY" = 1 ] && info "check only -- nothing will be installed"
[ "$DRY_RUN" = 1 ] && warn "dry run -- nothing will be changed"
printf '\n'

do_brew
do_gopls
report_manual

printf '\n'
if [ "$CHECK_ONLY" = 1 ]; then
    info "summary: $n_ok ok, $n_failed missing, $n_manual need manual action"
else
    info "summary: $n_installed installed, $n_ok already ok, $n_failed failed, $n_manual need manual action"
fi

if [ -n "$FAILED_LIST" ]; then
    err "failed:"
    printf '%s' "$FAILED_LIST" >&2
fi

[ "$n_failed" -gt 0 ] && exit 1
ok_msg "done"
