local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local chat = require("jetbrainsai.chat")
local secure = require("jetbrainsai.secure")

local M = {}

-- 🔹 Trigger: <leader>jc or :JetbrainsAIChat
function M.chat_prompt()
  vim.ui.input({ prompt = "💬 Ask JetBrains AI:" }, function(msg)
    if not msg then return end
    chat.send(msg, function(reply)
      vim.notify(reply, vim.log.levels.INFO, { title = "JetBrains AI" })
    end)
  end)
end

-- 🔹 Trigger: <leader>js or :JetbrainsAISetup
function M.setup_tokens()
  vim.ui.input({ prompt = "Enter JWT Token:" }, function(jwt)
    vim.ui.input({ prompt = "Enter Bearer Token:" }, function(bearer)
      vim.ui.input({ prompt = "Encrypt with passphrase (optional):" }, function(pass)
        if pass and #pass > 0 then
          secure.encrypt_and_store(jwt, bearer, pass)
          vim.notify("🔐 Tokens encrypted and saved", vim.log.levels.INFO)
        else
          proxy.set_tokens(jwt, bearer)
          vim.notify("⚠️ Tokens stored in memory only (not persisted)", vim.log.levels.WARN)
        end
      end)
    end)
  end)
end

-- 🔹 Trigger: <leader>jl or :JetbrainsAILogout
function M.logout_tokens()
  config.jwt = nil
  config.bearer = nil
  config.status = "⚠️"
  vim.notify("🔒 Tokens cleared from memory", vim.log.levels.INFO)
end

-- 🔑 Bind all mappings
function M.init()
  vim.keymap.set("n", config.chat_key, M.chat_prompt, { desc = "JetBrains AI: Chat" })
  vim.keymap.set("n", config.setup_key, M.setup_tokens, { desc = "JetBrains AI: Setup Tokens" })
  vim.keymap.set("n", config.logout_key, M.logout_tokens, { desc = "JetBrains AI: Clear Tokens" })
end

return M

