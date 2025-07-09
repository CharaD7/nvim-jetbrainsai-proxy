# 🔐 Security Policy

## Token Storage

This plugin supports optional encrypted token storage using AES-256. Tokens are never transmitted or stored remotely. Users may opt out and store tokens in memory only.

## Token Loading Behavior

- Tokens stored in memory can be cleared via `:JetbrainsAILogout`
- Auto-loading can be toggled in config: `auto_prompt = false`
- User status icons: 
  - 🔐 locked/encrypted
  - 🔓 unlocked
  - ⚠️ not set
  - ❌ error

## Encryption Details

- Algorithm: AES-256-CBC
- Storage path: `~/.cache/nvim-jetbrainsai/tokens.enc`
- Passphrase: User-defined, not stored

## Supported Versions

| Version | Supported |
| ------- | --------- |
| 1.0.0   | ✅         |
| 1.0.1   | ✅         |

## Responsible Use

This plugin is designed for users with **valid JetBrains AI licenses**. You are solely responsible for your use of API tokens, proxy setup, and adherence to JetBrains Terms of Service.

## Reporting a Vulnerability

Please open an issue or email the maintainer privately with details.
## Supported Versions
This project is currently maintained and accepts security patches for the latest `main` branch.

## Reporting a Vulnerability
If you discover a security issue, please contact the maintainers **privately**. Do not open public issues for disclosure.

## Token Safety
- Do not commit your `config.yaml` to version control.
- Use `.env` + `make gen-config` to keep secrets local.
- Rotate `grazie-authenticate-jwt` periodically.
