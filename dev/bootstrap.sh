#!/usr/bin/env bash

set -e

CONFIG_FILE="proxy/config.yaml"
MITMPROXY_PORT=8081
PROXY_PORT=8080

echo "🔍 Checking environment..."

# Prefer podman if available
if command -v podman &> /dev/null; then
  CONTAINER_ENGINE="podman"
else
  CONTAINER_ENGINE="docker"
fi
echo "🛠 Using $CONTAINER_ENGINE for container engine."

# Step 1: Validate config.yaml exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ $CONFIG_FILE not found. Please create it or run 'make gen-config'."
  exit 1
fi

echo "✅ Found $CONFIG_FILE"

# Step 2: Run validator
echo "🔍 Verifying configuration..."
python3 proxy/scripts/verify-build-ready.py

# Step 3: Start mitmproxy in background if not already running
if ! lsof -i :$MITMPROXY_PORT >/dev/null; then
  echo "🕵️ Starting mitmproxy on port $MITMPROXY_PORT..."
  tmux new-session -d -s mitm "mitmproxy --mode regular --listen-port $MITMPROXY_PORT --set flow_detail=3"
  echo "📡 mitmproxy running in tmux session 'mitm'"
else
  echo "⚠️ mitmproxy already running on port $MITMPROXY_PORT"
fi

# Step 4: Build container
echo "📦 Building Docker image..."
cd proxy
make build

# Step 5: Run container
echo "🚀 Launching proxy on port $PROXY_PORT..."
make run

