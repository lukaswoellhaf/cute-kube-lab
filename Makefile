.DEFAULT_GOAL := help

# ===== Default config (override via: make start PROFILE=...) =====
PROFILE ?= cute-kube-lab
DRIVER  ?= docker      # docker | podman | hyperkit | virtualbox | qemu
CPUS    ?= 2
MEMORY  ?= 4096
NODES   ?= 1
K8S_VERSION ?=         # e.g. v1.30.3 (empty = latest)
ADDONS  ?= ingress metrics-server

START_FLAGS := --profile $(PROFILE) --driver=$(DRIVER) --cpus=$(CPUS) --memory=$(MEMORY) --nodes=$(NODES)
ifneq ($(strip $(K8S_VERSION)),)
START_FLAGS += --kubernetes-version=$(K8S_VERSION)
endif

.PHONY: help env check start resume stop delete status ip addons wait

help:
	@echo "cute-kube-lab — minimal Make targets"
	@printf "  %-10s %s\n" \
	  help      "Show this help" \
	  env       "Print effective settings" \
	  check     "Check required tools" \
	  start     "Create/start cluster with flags" \
	  resume    "Resume existing cluster (no flags)" \
	  stop      "Stop cluster (preserves state)" \
	  delete    "Delete cluster (DESTROYS state)" \
	  status    "Show cluster status" \
	  ip        "Show minikube IP" \
	  addons    "Enable addons: $(ADDONS)" \
	  wait      "Wait for nodes (and ingress if enabled)"
	@echo
	@echo "Override defaults, e.g.: make start PROFILE=mytest CPUS=4 MEMORY=8192"

## env: Print effective configuration
env:
	@echo PROFILE=$(PROFILE)
	@echo DRIVER=$(DRIVER)
	@echo CPUS=$(CPUS)
	@echo MEMORY=$(MEMORY)
	@echo NODES=$(NODES)
	@echo K8S_VERSION=$(K8S_VERSION)
	@echo ADDONS=$(ADDONS)

## check: Verify required tools are available
check:
	@command -v minikube >/dev/null || { echo "minikube not found"; exit 1; }
	@command -v kubectl  >/dev/null || { echo "kubectl not found";  exit 1; }
	@echo "All good ✅"

## start: Create/start cluster and set kubectl context
start: check
	@echo "Starting: profile=$(PROFILE) driver=$(DRIVER) cpus=$(CPUS) mem=$(MEMORY) nodes=$(NODES) k8s=$(if $(K8S_VERSION),$(K8S_VERSION),latest)"
	minikube start $(START_FLAGS)
	@echo "Tip: run 'make addons' to enable: $(ADDONS)"

## resume: Resume an existing cluster without reapplying flags
resume:
	minikube start --profile $(PROFILE)

## stop: Stop cluster (state preserved)
stop:
	minikube stop --profile $(PROFILE)

## delete: Delete cluster (Attention: DESTROYS all state)
delete:
	minikube delete --profile $(PROFILE)

## status: Show status
status:
	minikube status --profile $(PROFILE) || true

## ip: Show minikube IP
ip:
	minikube ip --profile $(PROFILE)

## addons: Enable addons ($(ADDONS))
addons:
	@echo "Enabling addons on profile '$(PROFILE)': $(ADDONS)"
	@for a in $(ADDONS); do \
	  echo "-> $$a"; \
	  minikube addons enable $$a --profile $(PROFILE); \
	done

## wait: Wait for nodes (and ingress if enabled) to be ready
wait:
	@echo "Waiting for nodes to be Ready..." 
	kubectl wait --for=condition=Ready node --all --timeout=180s
	@if minikube addons list --profile $(PROFILE) | grep -qE 'ingress[[:space:]]+.*enabled'; then \
	  echo "Waiting for ingress-nginx controller..."; \
	  kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller --timeout=180s; \
	fi
	@echo "Ready ✅"
