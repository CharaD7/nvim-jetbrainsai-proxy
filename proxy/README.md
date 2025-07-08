# JetBrains AI Proxy

This proxy allows Neovim to connect to JetBrains AI through user-provided session tokens.

## Setup

1. Clone: `git clone https://github.com/zouyq/jetbrains-ai-proxy`
2. Get your tokens:
   - Open JetBrains IDE and inspect requests to `ai-chat.jetbrains.com`
   - Copy `Authorization: Bearer ...` and `jb-access-token: ...`
3. Add to `.env`:


