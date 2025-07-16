FROM alpine:3.18

RUN apk add --no-cache \
  bash curl git make gcc musl-dev unzip \
  lua5.3 lua5.3-dev

# Copy local LuaRocks server
COPY docker/luarocks-server /luarocks-server

# Install LuaRocks
RUN curl -L https://luarocks.org/releases/luarocks-3.12.2.tar.gz | tar zx && \
  cd luarocks-3.12.2 && \
  ./configure --with-lua-include=/usr/include/lua5.3 && \
  make && make install && \
  cd .. && rm -rf luarocks-3.12.2

# Install Luacheck from local server
RUN luarocks install luacheck \
  --server=/luarocks-server \
  --lua-version=5.3

