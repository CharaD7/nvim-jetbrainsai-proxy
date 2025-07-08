# 🔐 Security Policy

## Token Storage

This plugin supports optional encrypted token storage using AES-256. Tokens are never transmitted or stored remotely. Users may opt out and store tokens in memory only.

## Encryption Details

- Algorithm: AES-256-CBC
- Storage path: `~/.cache/nvim-jetbrainsai/tokens.enc`
- Passphrase: User-defined, not stored

## Supported Versions

| Version | Supported |
| ------- | --------- |
| 1.0.0   | ✅         |

## Responsible Use

This plugin is designed for users with **valid JetBrains AI licenses**. You are solely responsible for your use of API tokens, proxy setup, and adherence to JetBrains Terms of Service.

## Reporting a Vulnerability

Please open an issue or email the maintainer privately with details.
