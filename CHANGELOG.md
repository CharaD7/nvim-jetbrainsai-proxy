# 📦 Changelog

All notable changes to this project will be documented here.

## [1.0.0] - 2025-07-08
### Added
- Initial release with proxy-based JetBrains AI support
- Noice UI with chat + confirmation workflow
- Token injection commands & Docker proxy guide

___

## [1.0.1] - 2025-07-09
### Added
- Full proxy build pipeline with Makefile + Docker
- MITM token discovery flow
- JWT config validator with CI integration
- Automated PR commenting on config failures
- Extended dev tools: bootstrap script, test harness

### Changed
- CI now enforces config.yaml formatting before builds

### Security
- Tokens are never stored in version control
- Encouraged token rotation and local `.env` pattern

[1.0.1]: https://github.com/CharaD7/nvim-jetbrainsai-proxy/releases/tag/v1.0.1
