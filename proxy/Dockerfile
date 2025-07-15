FROM docker.io/library/golang:1.24-alpine

WORKDIR /app

RUN apk add --no-cache git && \
	git clone https://github.com/zouyq/jetbrains-ai-proxy.git . && \
	go build -o jetbrains-ai-proxy main.go

# Base tools
RUN apk add --no-cache bash curl git make gcc musl-dev findutils

# Check if Lua exists, else install 5.1.5
RUN if ! command -v lua >/dev/null 2>&1; then \
		echo "🔍 Lua not found. Installing Lua 5.1.5..." && \
		apk add --no-cache lua5.1 lua5.1-dev; \
	else \
		echo "✅ Lua already installed: $(lua -v)"; \
	fi

# Detect Lua include path
RUN LUA_INCLUDE=$(find /usr/include -type d -name "lua*" | grep -E 'lua[0-9\.]*$' | head -n 1) && \
	echo "📦 Detected Lua include path: $LUA_INCLUDE" && \
	curl -L https://luarocks.org/releases/luarocks-3.9.2.tar.gz | tar zx && \
	cd luarocks-3.9.2 && \
	./configure --with-lua-include=$LUA_INCLUDE && \
	make && make install && \
	cd .. && rm -rf luarocks-3.9.2

# Optional: Install Luacheck
RUN luarocks install luacheck

COPY config.yaml ./config.yaml

EXPOSE 8080

CMD ["./jetbrains-ai-proxy", "--config", "./config.yaml"]


