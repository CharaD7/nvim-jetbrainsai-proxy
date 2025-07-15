FROM alpine:3.18

LABEL maintainer="Joy"
LABEL description="Lua 5.1 + LuaRocks base for Neovim proxy tools"

RUN apk add --no-cache \
	bash curl git make gcc musl-dev \
	lua5.1 lua5.1-dev

# Validate headers
RUN test -f /usr/include/lua.h && echo "✅ Lua headers found"

# Install LuaRocks
RUN curl -L https://luarocks.org/releases/luarocks-3.9.2.tar.gz | tar zx && \
	cd luarocks-3.9.2 && \
	./configure --with-lua-include=/usr/include && \
	make && make install && \
	cd .. && rm -rf luarocks-3.9.2

# Optional: Luacheck
RUN luarocks install luacheck

CMD ["lua"]

