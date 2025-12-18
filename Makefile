# Helm
SRC_ROOT = $(shell git rev-parse --show-toplevel)

helm-docs: helm-doc
	$(HELM_DOCS) --chart-search-root ./charts

helm-lint: ct
	@$(CT) lint --config ./.github/configs/ct.yaml --lint-conf ./.github/configs/lintconf.yaml --all --debug

helm-test: kind
	@$(KIND) create cluster --wait=60s --name peak-scale-charts
	@$(MAKE) helm-install
	@$(KIND) delete cluster --name buttah-charts

helm-install: ct
	@$(CT) install --config $(SRC_ROOT)/.github/configs/ct.yaml --all --debug

helm-destroy: kind
	@$(KIND) delete cluster --name buttah-charts


## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

HELM_DOCS         := $(LOCALBIN)/helm-docs
HELM_DOCS_VERSION := v1.14.1
HELM_DOCS_LOOKUP  := norwoodj/helm-docs
helm-doc:
	@test -s $(HELM_DOCS) || \
	$(call go-install-tool,$(HELM_DOCS),github.com/$(HELM_DOCS_LOOKUP)/cmd/helm-docs@$(HELM_DOCS_VERSION))

CT         := $(LOCALBIN)/ct
CT_VERSION := v3.13.0
CT_LOOKUP  := helm/chart-testing
ct:
	@test -s $(CT) && $(CT) version | grep -q $(CT_VERSION) || \
	$(call go-install-tool,$(CT),github.com/$(CT_LOOKUP)/v3/ct@$(CT_VERSION))

KIND         := $(LOCALBIN)/kind
KIND_VERSION := v0.31.0
KIND_LOOKUP  := kubernetes-sigs/kind
kind:
	@test -s $(KIND) && $(KIND) --version | grep -q $(KIND_VERSION) || \
	$(call go-install-tool,$(KIND),sigs.k8s.io/kind/cmd/kind@$(KIND_VERSION))

# go-install-tool will 'go install' any package $2 and install it to $1.
PROJECT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
define go-install-tool
[ -f $(1) ] || { \
    set -e ;\
    GOBIN=$(LOCALBIN) go install $(2) ;\
}
endef