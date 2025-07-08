# JetBrains AI Proxy

This proxy allows Neovim to connect to JetBrains AI through user-provided session tokens.

## Setup

1. Clone: `git clone https://github.com/zouyq/jetbrains-ai-proxy`
2. Get your tokens:
   - Open JetBrains IDE and inspect requests to `ai-chat.jetbrains.com`
   - Copy `Authorization: Bearer ...` and `jb-access-token: ...`
3. Add to `.env`:
   - JETBRAINS_BEARER=your-token-here
   - JETBRAINS_JWT=your-jwt-token-here
4. Build and run:
```bash
docker build -t jbproxy .
docker run -p 8080:8080 --env-file .env jbproxy
```

---

