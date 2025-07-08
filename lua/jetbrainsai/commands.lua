local M = {}

function M.init()
  vim.api.nvim_create_user_command("JetbrainsAIChat", function()
    require("jetbrainsai.ui").chat()
  end, { desc = "Open AI chat prompt" })

  vim.api.nvim_create_user_command("JetbrainsAISetup", function()
    require("jetbrainsai.ui").setup_tokens()
  end, { desc = "Set JetBrains AI tokens" })

  vim.api.nvim_create_user_command("JetbrainsAIUsage", function()
    require("jetbrainsai.usage").show_plan()
  end, { desc = "Show usage or plan" })

  vim.api.nvim_create_user_command("JetbrainsAILogout", function()
    local config = require("jetbrainsai.config").get()
    config.jwt = nil
    config.bearer = nil
    config.status = "⚠️"
    vim.notify("🔒 Tokens cleared from memory", vim.log.levels.INFO)
  end, { desc = "Clear JetBrains AI tokens from memory" })
end

return M
