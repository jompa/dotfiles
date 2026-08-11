# dotfiles installer.
#
# The real logic lives in bin/link.sh -- this file is a dispatcher. That split
# is deliberate: the system make is GNU Make 3.81, which predates .ONESHELL
# (3.82), so every recipe line runs in its own shell and non-trivial branching
# cannot live in a recipe.

REPO := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
LINK := $(REPO)/bin/link.sh

.DEFAULT_GOAL := help
.PHONY: help install link dry-run submodules

help: ## Show this help
	@echo 'dotfiles ($(REPO))'
	@echo
	@grep -hE '^[a-z][a-z-]*:.*##' $(MAKEFILE_LIST) \
		| sed -e 's/:[^#]*##/@/' \
		| awk -F'@' '{ printf "  make %-12s %s\n", $$1, $$2 }'
	@echo
	@echo 'Pass extra flags via ARGS, e.g. make link ARGS="--skip .gitconfig"'

install: submodules link ## Init submodules, then symlink everything

link: ## Symlink configs into your home dir (backing up what it replaces)
	@"$(LINK)" --no-submodules $(ARGS)

dry-run: ## Show what link would do, without changing anything
	@"$(LINK)" --dry-run $(ARGS)

submodules: ## Init/update git submodules (vundle)
	@"$(LINK)" --submodules-only $(ARGS)
