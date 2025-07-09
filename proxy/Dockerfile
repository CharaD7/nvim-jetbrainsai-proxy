FROM docker.io/library/golang:1.24-alpine

WORKDIR /app

RUN apk add --no-cache git && \
    git clone https://github.com/zouyq/jetbrains-ai-proxy.git . && \
    go build -o jetbrains-ai-proxy main.go

COPY config.yaml ./config.yaml

EXPOSE 8080

CMD ["./jetbrains-ai-proxy", "--config", "./config.yaml"]


