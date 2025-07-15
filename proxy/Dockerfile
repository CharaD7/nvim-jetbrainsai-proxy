# Stage 1: Build Go proxy
FROM golang:1.24-alpine AS builder

WORKDIR /app
RUN apk add --no-cache git
RUN git clone https://github.com/zouyq/jetbrains-ai-proxy.git . && \
	go build -o jetbrains-ai-proxy main.go

# Stage 2: Runtime with Lua tools
FROM lua-base:5.3

WORKDIR /app
COPY --from=builder /app/jetbrains-ai-proxy .
COPY config.yaml .

EXPOSE 8080
CMD ["./jetbrains-ai-proxy", "--config", "./config.yaml"]

