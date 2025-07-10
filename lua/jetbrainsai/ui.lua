local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local chat = require("jetbrainsai.chat")
local secure = require("jetbrainsai.secure")
local threads = require("jetbrainsai.threads")
local edits = require("jetbrainsai.edits")

local M = {}

local last_response = ""

-- Highlight groups
vim.api.nvim_set_hl(0, "JetBrainsTitle", { fg = "#aaaaff", bold = true })
vim.api.nvim_set_hl(0, "JetBrainsAccept", { fg = "#00FF00", bold = true })
vim.api.nvim_set_hl(0, "JetBrainsDeny", { fg = "#FF4444", bold = true })

function M.chat_prompt()
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.bo[bufnr].filetype = "jetbrainsai"
  vim.bo[bufnr].modifiable = true
  -- After creating window and buffer:
  vim.bo[bufnr].wrap = true
  vim.bo[bufnr].syntax = "markdown"
  vim.api.nvim_win_set_cursor(win, {input_row + 1, 2})
  vim.highlight.range(bufnr, ns, "JetBrainsPrompt", {input_row, 0}, {input_row, -1})

  local lines = {
    "🧠 Model: " .. (config.model or "gpt-4"),
    "📊 Quota: " .. (config.quota or "untracked"),
    "────────────────────────────────────────────",
    "[ Send ]    [ Accept ]    [ Deny ]",
    "",
    "💬 Prompt:",
    "",
    "> ", -- Prompt input line (editable!)
    "",
    "🧠 Response:",
  }

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Highlights using modern API
  local ns = vim.api.nvim_create_namespace("jetbrainsai-ui")
  vim.highlight.range(bufnr, ns, "JetBrainsTitle", { 0, 0 }, { 0, -1 })
  vim.highlight.range(bufnr, ns, "JetBrainsAccept", { 3, 13 }, { 3, 22 })
  vim.highlight.range(bufnr, ns, "JetBrainsDeny", { 3, 27 }, { 3, 34 })

  -- Track where prompt input lives
  local input_row = 7

  local function send_prompt()
    local line = vim.api.nvim_buf_get_lines(bufnr, input_row, input_row + 1, false)[1]
    local prompt = line:gsub("^%s*>%s*", "")
    if prompt == "" then
      return
    end

    chat.send(prompt, function(reply)
      last_response = reply
      local response_lines = vim.split(reply, "\n")
      local start_line = input_row + 3
      vim.api.nvim_buf_set_lines(bufnr, start_line, -1, false, response_lines)
    end)
  end

  local function accept()
    if last_response ~= "" then
      edits.inject_response(last_response)
      vim.notify("✅ Accepted", vim.log.levels.INFO)
    end
  end

  local function deny()
    edits.reject()
    vim.api.nvim_buf_set_lines(bufnr, input_row + 3, -1, false, {})
  end

  -- Keymap: <CR> sends prompt in normal & insert mode
  vim.keymap.set("n", "<CR>", send_prompt, { buffer = bufnr })
  vim.keymap.set("i", "<CR>", function()
    vim.api.nvim_input("<Esc>")
    vim.schedule(send_prompt)
  end, { buffer = bufnr })

  -- Accept/Deny via keymap
  vim.keymap.set("n", "<leader>ja", accept, { buffer = bufnr })
  vim.keymap.set("n", "<leader>jd", deny, { buffer = bufnr })
end

function M.setup_tokens()
  vim.ui.input({ prompt = "Enter JWT Token:" }, function(jwt)
    vim.ui.input({ prompt = "Enter Bearer Token:" }, function(bearer)
      vim.ui.input({ prompt = "Encrypt with passphrase (optional):" }, function(pass)
        if pass and #pass > 0 then
          secure.encrypt_and_store(jwt, bearer, pass)
          vim.notify("🔐 Tokens encrypted", vim.log.levels.INFO)
        else
          proxy.set_tokens(jwt, bearer)
          vim.notify("⚠️ Tokens stored in memory", vim.log.levels.WARN)
        end
      end)
    end)
  end)
end

function M.logout_tokens()
  config.jwt = nil
  config.bearer = nil
  threads.clear()
  vim.notify("🔒 Tokens cleared", vim.log.levels.INFO)
end

function M.init()
  vim.keymap.set("n", config.chat_key, M.chat_prompt, { desc = "JetBrains AI: Chat Split" })
  vim.keymap.set("n", config.setup_key, M.setup_tokens, { desc = "Setup Tokens" })
  vim.keymap.set("n", config.logout_key, M.logout_tokens, { desc = "Clear Tokens" })

  vim.api.nvim_create_user_command("JetbrainsAIHistory", function()
    require("jetbrainsai.history_view").open()
  end, {})
end

return M
