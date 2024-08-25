JSONNET_BIN ?= jsonnet

.PHONY: test
test:
	@$(JSONNET_BIN) \
		-J semver/vendor \
		-J test/vendor \
		test/main.libsonnet

.PHONY: fmt
fmt:
	@find . \
		-path './.git' -prune \
		-o -name 'vendor' -prune \
		-o -name '*.libsonnet' -print \
		-o -name '*.jsonnet' -print \
		| xargs -n 1 -- jsonnetfmt --no-use-implicit-plus -i

.PHONY: docs
docs:
	@$(JSONNET_BIN) \
		-J semver/vendor \
		-J semver/lib \
		-S -m . \
		-e '(import "github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet").render(import "semver/main.libsonnet")'


DEFAULT: all
.PHONY: all
all: test fmt docs
