function M.setup(opts)
  local config_mod = require("jetbrainsai.config")
  local proxy = require("jetbrainsai.proxy")
  local ui = require("jetbrainsai.ui")
  local secure = require("jetbrainsai.secure")

  config_mod.load(opts)
  local config = config_mod.get()

  vim.defer_fn(function()
    local path = vim.fn.stdpath("cache") .. "/nvim-jetbrainsai/tokens.enc"
    if config.auto_prompt and vim.fn.filereadable(path) == 1 then
      vim.ui.input({ prompt = "🔐 Unlock JetBrains AI tokens:" }, function(pass)
        if pass and #pass > 0 then
          local tokens = secure.load_tokens(pass)
          if tokens then
            proxy.set_tokens(tokens.jwt, tokens.bearer)
            config.status = "🔓"
            vim.notify("🔓 Encrypted tokens loaded", vim.log.levels.INFO)
          else
            config.status = "❌"
            vim.notify("❌ Invalid passphrase", vim.log.levels.ERROR)
          end
        else
          vim.notify("⏭️ Skipped token unlock", vim.log.levels.WARN)
        end
      end)
    end
  end, 300)

  proxy.check_proxy()
  ui.init()
end

