local M = {}
local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local usage = require("jetbrainsai.usage")
local ui = require("jetbrainsai.ui")

function M.register()
  vim.api.nvim_create_user_command("JetbrainsAIChat", function()
    ui.chat_prompt()
  end, { desc = "Open AI chat prompt" })

  vim.api.nvim_create_user_command("JetbrainsAISetup", function()
    ui.setup_tokens()
  end, { desc = "Set or encrypt JetBrains AI tokens" })

  vim.api.nvim_create_user_command("JetbrainsAIUsage", function()
    usage.show_plan()
  end, { desc = "Show plan info or proxy quota hint" })

  vim.api.nvim_create_user_command("JetbrainsAILogout", function()
    config.jwt = nil
    config.bearer = nil
    config.status = "⚠️"
    vim.notify("🔒 JetBrains AI tokens cleared from memory", vim.log.levels.INFO)
  end, { desc = "Remove in-memory tokens during this session" })

  vim.api.nvim_create_user_command("JetbrainsAIHistory", function()
    require("jetbrainsai.history_view").open()
  end, { desc = "Open chat history" })
end

return M

