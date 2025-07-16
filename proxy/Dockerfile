FROM alpine:3.18

RUN apk add --no-cache \
	bash curl git make gcc musl-dev unzip \
	lua5.3 lua5.3-dev python3 python3-dev py3-pip \
	build-base libffi-dev openssl-dev \
	cargo rust

# Test for python headers
RUN test -f /usr/include/python3.11/Python.h && echo "✅ Python headers found"

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

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
	source $HOME/.cargo/env && \
	rustup update stable && \
	rustup default stable

# Add Rust binaries to PATH
ENV PATH="/root/.cargo/bin:$PATH"

RUN pip install mitmproxy

EXPOSE 8084

CMD ["mitmproxy", "--mode", "regular", "--listen-port", "8084"]
