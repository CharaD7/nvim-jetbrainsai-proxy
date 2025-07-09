# 📘 DEV Notes

___

# Setup

This [script](bootstrap.sh):
- Converts `.env` (optional)
- Builds the Docker image
- Starts `mitmproxy` in a background `tmux` session
 - Runs the proxy for Neovim use

 Make sure to:
```bash
chmod +x dev/bootstrap.sh
```

You can now run the command below for automated setup
```bash
./dev/bootstrap.sh
```

To inspect mitmproxy, use:
```bash
tmux attach -t mitm
```

___

## Debugging mitmproxy
- Common endpoints to watch: `/llm/chat/stream`
- Look for `grazie-authenticate-jwt` in headers
- `bearer` may be optional for now

## CI Failure Checklist
- Run `make verify`
- Ensure Dockerfile includes `COPY config.yaml`
