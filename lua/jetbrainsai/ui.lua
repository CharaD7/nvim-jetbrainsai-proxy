local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local chat = require("jetbrainsai.chat")
local secure = require("jetbrainsai.secure")

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
      vim.ui.input({ prompt = "Encrypt with passphrase (leave blank to skip):" }, function(pass)
        if pass and #pass > 0 then
          secure.encrypt_and_store(jwt, bearer, pass)
          vim.notify("🔐 Tokens encrypted and saved", vim.log.levels.INFO)
        else
          proxy.set_tokens(jwt, bearer)
          vim.notify("⚠️ Tokens stored in memory only", vim.log.levels.WARN)
        end
      end)
    end)
  end)
end

function M.init()
  vim.keymap.set("n", config.chat_key, chat_prompt, { desc = "JetBrains AI Chat" })
  vim.keymap.set("n", config.setup_key, setup_tokens, { desc = "JetBrains AI Token Setup" })
end

return M

