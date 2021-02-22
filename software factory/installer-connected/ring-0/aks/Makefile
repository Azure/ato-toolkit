SHELL:=/bin/bash
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: test shellcheck bats config_lint ci_tool_tests ci_tool_build reset_testing

test: ci_tool_tests shellcheck bats config_lint opa_test

shellcheck:
	docker run --rm -w /mnt -v $(ROOT_DIR):/mnt -t koalaman/shellcheck $(shell find . -name *.sh | grep -v vendor)

shellcheck_ci:
	docker run --rm -w /mnt -v $(ROOT_DIR):/mnt -t koalaman/shellcheck -f checkstyle $(shell find . -name *.sh | grep -v vendor) > shellcheck.xml

bats:
	docker run --rm -w /mnt -v $(ROOT_DIR):/mnt -t bats/bats . -r

bats_ci:
	docker run --rm -w /mnt -v $(ROOT_DIR):/mnt -t bats/bats . -r > bats.tap

config_lint:
	docker run --rm -w /mnt -v $(ROOT_DIR):/mnt -t stelligent/config-lint:v0.0.44 -terraform12 .

ci_tool_tests:
	$(MAKE) -C src/runtime/ci-tooling test

ci_tool_build:
	$(MAKE) -C src/runtime/ci-tooling build

opa_test:
	docker run --rm  -v $(ROOT_DIR)/src/runtime/manifests/gatekeeper/policies:/policies openpolicyagent/opa test -v /policies

opa_generate:
	$(MAKE) -C src/runtime/manifests/gatekeeper/tools/render_templates

reset_testing:
	find ./ -name '*.tfplan' -prune -exec rm -rf {} \;
	find ./ -name 'terraform.tfstate*' -prune -exec rm -rf {} \;
	find ./ -name '\.terraform' -prune -exec rm -rf {} \;
