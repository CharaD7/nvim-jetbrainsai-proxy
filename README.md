[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Neovim Plugin](https://img.shields.io/badge/built%20for-Neovim-57a143?logo=neovim)](https://neovim.io)
[![Stars](https://img.shields.io/github/stars/CharaD7/nvim-jetbrainsai-proxy.svg?style=social)](https://github.com/yourgithub/nvim-jetbrainsai-proxy)

# 🧠 nvim-jetbrainsai-proxy

A blazing-fast, JetBrains AI-compatible Neovim plugin—powered via a secure local proxy. Insert AI-generated code, preview file changes, approve diffs, and elevate your development flow from your favorite keyboard-first editor.

---

## 🚀 Features

- 💬 Chat with JetBrains AI directly in Neovim
- 📁 Preview and accept file suggestions from the AI
- 🔐 Store your tokens securely with encrypted local storage
- 🌐 Connect via a local Docker proxy with user-owned tokens
- 🎨 Beautiful UI powered by [Noice.nvim](https://github.com/folke/noice.nvim)
- 🧪 Built-in `:checkhealth` diagnostics
- ✅ GitHub-friendly repo: secure, compliant, and community-driven

---

# 🔧 Install (Lazy.nvim)

```lua
{
  "CharaD7/nvim-jetbrainsai-proxy",
  dependencies = {
    "folke/noice.nvim",
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("jetbrainsai").setup({
      -- Optional: Disable auto token prompt
      auto_prompt = true,
    })
  end
}
```

___

# 🧑‍💻 Setup

During setup, you'll be prompted to enter your:

- `JetBrains JWT` token

- `JetBrains Bearer` token

- _(Optional)_ Encryption passphrase to securely store these credentials

> 🛡️ You are solely responsible for providing your own tokens. This plugin does not bypass or spoof any licensing or authentication.

To retrieve your valid tokens, you'll need to run the proxy locally, authenticated with your JetBrains session.

___ 
## 🐳 Running the Proxy (To Acquire Tokens)

Jetbrains AI credentials must be extracted from your own session using the official IDE. This plugin does not ship with authentication,
and you will need your own tokens to connect.

__Step 1:__ Clone the repo and navigate to the proxy directory.

```bash
git clone https://github.com/CharaD7/nvim-jetbrainsai-proxy.git

cd nvim-jetbrainsai-proxy/proxy
```

__Step 2:__ Copy the env file `cp .env.example .env`

__Step 3:__ Open any Jetbrains IDE and initiate the AI chat.

__Step 4:__ Use browser DevTools to inspect a network request to `ai-chat.jetbrains.com`

__Step 5:__ Extract the key information:

- `Authorization: Bearer ...`
- `jb-access-token: ...`

__Step 6:__ Fill in the `.env` like so:

```bash
JETBRAINS_BEARER=<your_authorization_token>
JETBRAINS_JWT=<your_jwt_here>
PORT=8080
```


__Step 7:__ Start the proxy

```bash
docker build -t jetbrains-proxy .
docker run -p 8080:8080 --env-file .env jetbrains-proxy
```

___

## 🔐 Encrypted Token Setup and Storage

You can securely store your JetBrains AI tokens using AES-256 encryption.

1. Run `:JetbrainsAISetup`
2. When prompted, enter a 
  - JWT token
  - Bearer token
  - (Optional) passphrase to encrypt your tokens
3. Tokens are stored at `~/.cache/nvim-jetbrainsai/tokens.enc`

> ⚠️ If you skip encryption, tokens are stored in memory only and will not persist.

### 🧠 Smart Token Loading

If you’ve saved encrypted tokens before, the plugin will:

- Detect the token file on startup
- Prompt you once to enter your passphrase (optional)
- Skip completely if no token is saved or prompt is canceled

You’ll never be blocked by required input during startup.

### 🔐 Ergonomic Token Loading

This plugin will check for encrypted tokens on startup only if:

- You've previously stored them via `:JetbrainsAISetup`
- `auto_prompt = true` (default)

Otherwise, it stays silent and clean.

You can disable token auto-load entirely:

```lua
require("jetbrainsai").setup({
  auto_prompt = false
})
```

You may also logout via: `:JetbrainsAILogout`
___

# 💻 Keybindings

| Mode | Mapping | Action |
|----|----|----|
| `n` | `<leader>jc` | Start chat prompt |
| `n` | `<leader>js` | Setup tokens (store or encrypt) |
| `n` | `<leader>jl` | Logout (clear memory-stored tokens) |

___

## 🩺 Health Check

To validate setup, run:

```vim
:checkhealth nvim-jetbrainsai-proxy
```

The plugin will check:

- 🔐 Token presence or encryption status

- 🌐 Proxy availability

- 🧰 Required dependencies (curl, openssl)

- 🧠 Neovim version & runtime paths

___

# 🛡 Legal Compliance

This plugin does not bundle any JetBrains source code, credentials, or assets. Users must authenticate with their own valid tokens and license. No usage data is transmitted or stored.
  > ⚠️ Use of the JetBrains API via proxy is for educational and non-commercial use only. We recommend this plugin be run locally and by licensed users.

- All API calls use your local, user-authenticated proxy
- Tokens are never transmitted to third parties or stored by this plugin
- Users are expected to comply with Jetbrains' [Terms of Use](https://www.jetbrains.com/legal/terms/) and [Privacy Policy](https://www.jetbrains.com/legal/privacy-policy/)

___

# ✨ Roadmap

View ongoing work and feature proposals under the [Discussions](https://github.com/CharaD7/nvim-jetbrainsai-proxy/discussions) tab.
- [x] Chat with JetBrains AI via proxy

- [x] File write approval workflow

- [x] Token storage with optional encryption

- [ ] Custom UI options per theme

- [ ] Direct connection to JetBrains Gateway or MCP (optional)

___

# 🤝 Contributing
To contribute to this repo, please read [CONTRIBUTING](CONTRIBUTING.md)

___

# 📜 License
This project uses the [MIT LICENSE](LICENSE)
