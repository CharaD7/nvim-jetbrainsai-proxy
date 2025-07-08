[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Neovim Plugin](https://img.shields.io/badge/built%20for-Neovim-57a143?logo=neovim)](https://neovim.io)
[![Stars](https://img.shields.io/github/stars/CharaD7/nvim-jetbrainsai-proxy.svg?style=social)](https://github.com/yourgithub/nvim-jetbrainsai-proxy)

# 🧠 nvim-jetbrainsai-proxy

A blazing-fast, JetBrains AI-compatible Neovim plugin—powered via a secure local proxy. Insert AI-generated code, preview file changes, approve diffs, and elevate your development flow from your favorite keyboard-first editor.

---

## 🚀 Features

- 💬 Interactive JetBrains AI chat in Neovim
- 📁 Confirmable file and directory creation
- 🧠 OpenAI-compatible proxy with your JB session
- 🌈 Catppuccin-themed UI (via Noice)
- ✅ Token setup UI & visual usage tier display
- 🔐 Compliant, secure, and community-focused

---

## 🔧 Install (Lazy.nvim)

```lua
{
  "yourgithub/nvim-jetbrainsai-proxy",
  dependencies = {
    "folke/noice.nvim",
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("jetbrainsai").setup()
  end
}
```

___

# 🧑‍💻 Setup
Run the Proxy

Open Neovim and run `:JetbrainsAISetup`

Start chatting with `<leader>jc`

All actions are available via keymaps and commands

___

# 🐳 Run the Proxy

```bash
cd proxy
cp .env.example .env
docker build -t jetbrains-proxy .
docker run -p 8080:8080 --env-file .env jetbrains-proxy
```

___

# 🛡 Legal Compliance
This plugin does not bundle any JetBrains source code, credentials, or assets. Users must authenticate with their own valid tokens and license. No usage data is transmitted or stored.

  > ⚠️ Use of the JetBrains API via proxy is for educational and non-commercial use only. We recommend this plugin be run locally and by licensed users.

___

# ✨ Roadmap
[x] Chat with JetBrains AI via proxy

[x] File write approval workflow

[ ] Token storage with optional encryption

[ ] Custom UI options per theme

[ ] Direct connection to JetBrains Gateway or MCP (optional)

___

# 🤝 Contributing
Please read CONTRIBUTING.md

___

# 📜 License
MIT – See LICENSE
