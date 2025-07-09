# 🧠 JetBrains AI Proxy

A local proxy that forwards JetBrains AI Assistant requests—perfect for Neovim integration or custom tooling using your personal tokens.

---

## ⚙️ Prerequisites

- JetBrains IDE with AI Assistant enabled
- Your own JWT from JetBrains (see below)
- TMUX
- Docker **or** Podman
- Python 3.7+ (for config validation / generator)
- [mitmproxy](https://mitmproxy.org/) (optional, for token discovery)

---

## 🚀 Quickstart

```bash
make bootstrap
```

That validates your `config.yaml`, builds the container, and starts the proxy.

___

# 🔐 Getting Your JetBrains Tokens

1. Open your IDE and trigger an AI action *(e.g., “Explain Code”)*
2. Route the IDE through `mitmproxy`:
  - Configure `Settings → HTTP Proxy`: host `localhost`, port `8081`
  - Start `mitmproxy` by running `make mitmproxy`
3. Inspect the POST request to `/llm/chat/stream/v5`
4. Copy the `grazie-authenticate-jwt` header and save as:
```yaml
# config.yaml
tokens:
  - jwt: "your-jwt-token-here"
    bearer: ""
```

___

# 📁 File Overview

```bash
proxy/
├── Dockerfile
├── Makefile
├── config.yaml
├── config.example.yaml
└── scripts/
    └── env-to-config.py
    └── verify-build-ready.py
```

## 🛠 Folder Guide

| Folder      | Purpose                                 |
|-------------|-----------------------------------------|
| `proxy/`    | Contains Dockerfile, config, and Makefile |
| `proxy/scripts/` | Tools to help generate config.yaml from .env |
| `dev/`      | Helper scripts, traffic logs, bootstrap launcher |
| `docs/`     | Dev onboarding docs, usage instructions |

---

## 💡 Pro Tips

- Want to refresh your token? Just run `make mitmproxy`, open your IDE, and capture again.
- You can safely run this behind a firewall—it's a local dev proxy only.

---

# 🧪 Additional Commands

| Task | Command |
| ----- | ---- |
| Build container | `make build` |
| Run proxy | `make run` |
| Validate config | `make check-config` |
| Verify build ready | `make verify` |
| Convert from .env | `make gen-config` |
| Clean image | `make clean` |

___

# 🛡 Security

Never commit `config.yaml`. It's already in `.gitignore`, but double-check before pushing. Keep your tokens secret and personal.

___

# 🙌 Contributing

Pull requests are welcome for:
- Better UI for token setup
- Support for rotating token stores
- IDE-native token fetchers

___

# ✨ Inspiration

💫 Built with love for Neovim + JetBrains. Powered by curiosity, mitmproxy, and really good YAML.

---
