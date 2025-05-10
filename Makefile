# SPDX-License-Identifier: MIT

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
test:  ## run unit tests
	bats test

.PHONY: doc
doc:  ## extract documentation from the shell scripts
	shdoc < toolbox.sh > docs/toolbox.md

.PHONY: deps
deps:  ## Install dependencies
	bash <(curl -s https://raw.githubusercontent.com/little-engineer-2025/shell-lib/refs/heads/main/retrieve.sh)

