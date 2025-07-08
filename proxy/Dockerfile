FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache git && \
    git clone https://github.com/zouyq/jetbrains-ai-proxy.git . && \
    npm install

COPY .env .env

CMD ["npm", "run", "start"]

