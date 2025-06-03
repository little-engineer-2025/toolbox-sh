# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>

##@ General

.PHONY: help
help:  ## Print out the help content
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all
all: format lint test doc

.PHONY: format
format:  ## Format shell scripts
	shfmt -w *.sh

.PHONY: lint
lint:  ## Lint the shell scripts
	shellcheck *.sh

.PHONY: test
test: deps  ## run unit tests
	bats test

.PHONY: doc
doc:  ## extract documentation from the shell scripts
	shdoc < toolbox.sh > docs/toolbox.md
	shdoc < toolbox_helpers.sh > docs/toolbox_helpers.md

.PHONY: deps
deps:  ## Install dependencies
	bash <(curl -s https://raw.githubusercontent.com/little-engineer-2025/shell-lib/refs/heads/main/retrieve.sh)

.PHONY: pkg
pkg:  ## Create linux distro package
	echo "error: not implemented"; exit 1

.PHONY: rpm-pkg
rpm-pkg:
	echo "error: not implemented"; exit 1

.PHONY: rpm-deb
rpm-deb:
	echo "error: not implemented"; exit 1

.PHONY: release
release: all ## Create a new release
	if [ $(shell git rev-list --count HEAD..origin/main) -ne 0 ]; then
		echo "fatal: the HEAD branch is not the 'main' or 'master' branch."
		exit 1
	fi

