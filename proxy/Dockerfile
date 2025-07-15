FROM docker.io/library/golang:1.24-alpine

WORKDIR /app

RUN apk add --no-cache git && \
		git clone https://github.com/zouyq/jetbrains-ai-proxy.git . && \
		go build -o jetbrains-ai-proxy main.go

# Install Lua and LuaRocks dependencies
RUN apk add --no-cache \
	lua5.1 lua5.1-dev \
	gcc make musl-dev \
	curl unzip git

# Install LuaRocks
RUN curl -L https://luarocks.org/releases/luarocks-3.9.2.tar.gz | tar zx && \
	cd luarocks-3.9.2 && \
	./configure --with-lua-include=/usr/include/lua5.1 && \
	make && make install && \
	cd .. && rm -rf luarocks-3.9.2

# Install Luacheck
RUN luarocks install luacheck

COPY config.yaml ./config.yaml

EXPOSE 8080

CMD ["./jetbrains-ai-proxy", "--config", "./config.yaml"]


