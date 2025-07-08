local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local chat = require("jetbrainsai.chat")

local M = {}

local function chat_prompt()
  vim.ui.input({ prompt = "Ask JetBrains AI:" }, function(msg)
    if not msg then return end
    chat.send(msg, function(reply)
      vim.notify(reply, vim.log.levels.INFO, { title = "JetBrains AI" })
    end)
  end)
end

local function setup_tokens()
  vim.ui.input({ prompt = "Enter JWT Token:" }, function(jwt)
    vim.ui.input({ prompt = "Enter Bearer Token:" }, function(bearer)
      proxy.set_tokens(jwt, bearer)
      vim.notify("✅ Tokens set", vim.log.levels.INFO)
    end)
  end)
end

function M.init()
  vim.keymap.set("n", config.chat_key, chat_prompt, { desc = "JetBrains AI Chat" })
  vim.keymap.set("n", config.setup_key, setup_tokens, { desc = "JetBrains AI Token Setup" })
end

return M

