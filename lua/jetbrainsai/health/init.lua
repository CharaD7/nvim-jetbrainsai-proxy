local config = require("jetbrainsai.config").get()

local function check_cmd(name, why)
  if vim.fn.executable(name) == 1 then
    vim.health.ok(name .. " is installed")
  else
    vim.health.error(name .. " is missing — " .. why)
  end
end

return function()
  vim.health.start("nvim-jetbrainsai-proxy")

  -- 🔐 Token Check
  if config.jwt and config.bearer then
    vim.health.ok("Tokens are loaded in memory")
  else
    vim.health.warn("Tokens not loaded. Run :JetbrainsAISetup or decrypt via encrypted store")
  end

  -- 🌐 Proxy Check
  vim.health.info("Checking if JetBrains AI proxy is reachable at " .. config.proxy_url)
  local handle = io.popen("curl -s -o /dev/null -w '%{http_code}' " .. config.proxy_url)
  local code = handle:read("*a"):gsub("%s+", "")
  handle:close()

  if code == "200" or code == "204" then
    vim.health.ok("JetBrains AI proxy is reachable ✅")
  else
    vim.health.error("Proxy unreachable or invalid response (" .. code .. ")")
    vim.health.info("→ Ensure your proxy is running on localhost:8080 or update config.proxy_url")
  end

  -- 🛠 Dependencies
  check_cmd("curl", "required for talking to the proxy")
  check_cmd("openssl", "required for encrypted token storage")

  -- 🌈 Optional Environment Info
  vim.health.info("stdpath('config'): " .. vim.fn.stdpath("config"))
  vim.health.info("stdpath('cache'): " .. vim.fn.stdpath("cache"))

  if vim.fn.has("nvim-0.9") == 1 then
    vim.health.ok("Neovim version is >= 0.9")
  else
    vim.health.warn("Neovim < 0.9 — some features might not render correctly")
  end
end

