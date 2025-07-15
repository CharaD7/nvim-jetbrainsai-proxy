# Detect container engine: prefer podman, fallback to docker
CONTAINER_ENGINE := $(shell command -v podman 2>/dev/null || echo docker)

IMAGE_NAME := jetbrains-proxy
PORT := 8080
CONFIG := config.yaml
TABS := check-makefile-tabs.sh

.PHONY: build run clean logs check-config check-tabs mitmproxy verify bootstrap gen-config

build:
  @echo "📦 Building $(IMAGE_NAME) with $(CONTAINER_ENGINE)..."
  $(CONTAINER_ENGINE) build -t $(IMAGE_NAME) .

run:
  @echo "🚀 Running $(IMAGE_NAME) on port $(PORT) with $(CONTAINER_ENGINE)..."
  $(CONTAINER_ENGINE) run -it --rm -p $(PORT):$(PORT) $(IMAGE_NAME)

clean:
  @echo "🧼 Cleaning image $(IMAGE_NAME)..."
  -$(CONTAINER_ENGINE) rmi -f $(IMAGE_NAME)

logs:
  @echo "📋 Tailing logs for $(IMAGE_NAME)..."
  $(CONTAINER_ENGINE) logs -f $$( $(CONTAINER_ENGINE) ps -q -f ancestor=$(IMAGE_NAME) )

check-config:
  @echo "🔍 Validating $(CONFIG)..."
  @python3 -c 'import yaml,sys; f=open("$(CONFIG)"); d=yaml.safe_load(f); assert "tokens" in d and isinstance(d["tokens"], list) and "jwt" in d["tokens"][0]; print("✅ Config is valid.")' || echo "❌ $(CONFIG) is missing or malformed."

check-tabs:
  @echo "🔍 Validating $(TABS)..."
  @scripts/$(TABS) || echo "❌ Makefile contains spaces instead of tabs.")

mitmproxy:
  @echo "🕵️ Starting mitmproxy on port 8081..."
  mitmproxy --mode regular --listen-port 8081 --set flow_detail=3

verify:
  @python3 scripts/verify-build-ready.py

gen-config:
  @echo "📄 Generating $(CONFIG) from .env..."
  @python3 scripts/env-to-config.py

bootstrap: check-config build run

