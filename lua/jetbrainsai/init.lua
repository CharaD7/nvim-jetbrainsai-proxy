local M = {}

function M.setup(opts)
  local config = require("jetbrainsai.config")
  local proxy = require("jetbrainsai.proxy")
  local ui = require("jetbrainsai.ui")

  config.load(opts)

  -- 🔐 Attempt to unlock encrypted tokens (optional on boot)
  vim.defer_fn(function()
    vim.ui.input({ prompt = "🔐 Enter passphrase to unlock JetBrains AI tokens:" }, function(pass)
      if pass and #pass > 0 then
        local secure = require("jetbrainsai.secure")
        local tokens = secure.load_tokens(pass)
        if tokens then
          proxy.set_tokens(tokens.jwt, tokens.bearer)
          vim.notify("✅ Encrypted tokens loaded", vim.log.levels.INFO)
        else
          vim.notify("❌ Could not decrypt stored tokens", vim.log.levels.ERROR)
        end
      else
        vim.notify("⚠️ No passphrase entered: tokens not loaded", vim.log.levels.WARN)
      end
    end)
  end, 500) -- slight delay after startup for smoother UX

  proxy.check_proxy()
  ui.init()
end

return M

