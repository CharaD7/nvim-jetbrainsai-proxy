local M = {}

M.init = function(opts)
  local config_mod = require("jetbrainsai.config")
  local proxy = require("jetbrainsai.proxy")
  local ui = require("jetbrainsai.ui")
  local secure = require("jetbrainsai.secure")
  local commands = require("jetbrainsai.commands")

  config_mod.load(opts)
  local config = config_mod.get()

  -- 🔐 Optional secure token loader if enabled and encrypted token file exists
  vim.defer_fn(function()
    if not config.auto_prompt then return end
    local token_path = vim.fn.stdpath("cache") .. "/nvim-jetbrainsai/tokens.enc"
    if vim.fn.filereadable(token_path) == 1 then
      vim.ui.input({ prompt = "🔐 Unlock JetBrains AI tokens:" }, function(pass)
        if pass and #pass > 0 then
          local tokens = secure.load_tokens(pass)
          if tokens then
            proxy.set_tokens(tokens.jwt, tokens.bearer)
            config.status = "🔓"
            vim.notify("🔓 Tokens decrypted and loaded", vim.log.levels.INFO)
          else
            config.status = "❌"
            vim.notify("❌ Decryption failed — passphrase may be incorrect", vim.log.levels.ERROR)
          end
        else
          vim.notify("⏭️ Skipped token unlock", vim.log.levels.WARN)
        end
      end)
    end
  end, 300)

  proxy.find_proxy()
  ui.init()
  commands.register()
end

return M

