
---

### `CONTRIBUTING.md`

```markdown
# 🤝 Contributing

Thanks for your interest in contributing! Here's how to get started:

## 📁 Project Structure

- `lua/jetbrainsai/`: Lua plugin code
- `proxy/`: Local proxy server (Docker-based)
- `plugin/jetbrainsai.lua`: Loader

## 🧪 Running Locally

1. Clone repo
2. Run proxy: `docker-compose up` or `docker build && docker run ...`
3. Install plugin in Neovim with packer/lazy

## ✅ Making a Pull Request

- Follow [Conventional Commits](https://www.conventionalcommits.org)
- Create feature branches from `main`
- Add test cases or demo usage where applicable
- Run `luacheck` for linting (optional)

## 🐛 Reporting Issues

Use the GitHub issue templates for:

- Bug reports
- Feature requests

## 💬 Questions?

Open a Discussion or ping @joyancek!

