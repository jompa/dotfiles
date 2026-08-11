# dotfiles installer.
#
# The real logic lives in bin/link.sh -- this file is a dispatcher. That split
# is deliberate: the system make is GNU Make 3.81, which predates .ONESHELL
# (3.82), so every recipe line runs in its own shell and non-trivial branching
# cannot live in a recipe.

REPO := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
LINK := $(REPO)/bin/link.sh
DEPS := $(REPO)/bin/deps.sh

.DEFAULT_GOAL := help
.PHONY: help install link dry-run submodules vim-update vim-helptags deps deps-check

help: ## Show this help
	@echo 'dotfiles ($(REPO))'
	@echo
	@grep -hE '^[a-z][a-z-]*:.*##' $(MAKEFILE_LIST) \
		| sed -e 's/:[^#]*##/@/' \
		| awk -F'@' '{ printf "  make %-12s %s\n", $$1, $$2 }'
	@echo
	@echo 'Pass extra flags via ARGS, e.g. make link ARGS="--skip .gitconfig"'

install: submodules link vim-helptags ## Init submodules, symlink, build vim helptags

deps: ## Install dependencies (brew + gopls); reports what it will not touch
	@"$(DEPS)" $(ARGS)

deps-check: ## Report which dependencies are present or missing
	@"$(DEPS)" --check $(ARGS)

link: ## Symlink configs into your home dir (backing up what it replaces)
	@"$(LINK)" --no-submodules $(ARGS)

dry-run: ## Show what link would do, without changing anything
	@"$(LINK)" --dry-run $(ARGS)

submodules: ## Init/update git submodules (the vim plugins)
	@"$(LINK)" --submodules-only $(ARGS)

vim-update: ## Pull each vim plugin to its latest upstream commit
	@git -C "$(REPO)" submodule update --remote --merge -- .vim/pack
	@echo
	@git -C "$(REPO)" submodule status -- .vim/pack
	@echo
	@echo 'Review, then commit the new pins:'
	@echo '  git -C "$(REPO)" commit -am "vim: update plugins"'
	@$(MAKE) --no-print-directory -f "$(firstword $(MAKEFILE_LIST))" vim-helptags

vim-helptags: ## Rebuild :help tags for the vim plugins
	@n=0; for d in "$(REPO)"/.vim/pack/plugins/start/*/doc; do \
		[ -d "$$d" ] || continue; \
		vim -es -u NONE -c "helptags $$d" -c 'qa!' >/dev/null 2>&1 && n=$$((n+1)); \
	done; echo "helptags rebuilt for $$n plugin(s)"
