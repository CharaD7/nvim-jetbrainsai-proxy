local M = {}

function M.setup(opts)
  local config = require("jetbrainsai.config")
  local proxy = require("jetbrainsai.proxy")
  local ui = require("jetbrainsai.ui")
  local secure = require("jetbrainsai.secure")

  config.load(opts)

  -- 🔐 Ergonomic: only ask if encrypted token file exists
  vim.defer_fn(function()
    local path = vim.fn.stdpath("cache") .. "/nvim-jetbrainsai/tokens.enc"
    if vim.fn.filereadable(path) == 1 then
      vim.ui.input({ prompt = "🔐 Unlock JetBrains AI (optional):" }, function(pass)
        if pass and #pass > 0 then
          local tokens = secure.load_tokens(pass)
          if tokens then
            proxy.set_tokens(tokens.jwt, tokens.bearer)
            vim.notify("🔓 Tokens unlocked", vim.log.levels.INFO)
          else
            vim.notify("❌ Invalid passphrase", vim.log.levels.ERROR)
          end
        else
          vim.notify("⏭️ Skip: Tokens not loaded", vim.log.levels.WARN)
        end
      end)
    end
  end, 300) -- short delay for smooth UI experience

  proxy.check_proxy()
  ui.init()
end

return M

