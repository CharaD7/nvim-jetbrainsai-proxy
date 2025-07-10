local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local chat = require("jetbrainsai.chat")
local secure = require("jetbrainsai.secure")
local threads = require("jetbrainsai.threads")
local edits = require("jetbrainsai.edits")

local M = {}
local last_response = ""

-- Highlights
vim.api.nvim_set_hl(0, "JBHeader", { fg = "#89b4fa", bold = true })
vim.api.nvim_set_hl(0, "JBAction", { fg = "#a6e3a1", italic = true })
vim.api.nvim_set_hl(0, "JBPrompt", { fg = "#f9e2af", italic = true })
vim.api.nvim_set_hl(0, "JBStream", { fg = "#cba6f7" })

-- Emoji spinner
local spinner_frames = { "🌕", "🌖", "🌗", "🌘", "🌑", "🌒", "🌓", "🌔" }

function M.chat_prompt()
  vim.cmd("vsplit")
  vim.cmd("vertical resize 40")

  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.wo[win].wrap = true
  vim.bo[bufnr].filetype = "jetbrainsai"

  local lines = {
    "💡 JetBrains AI Assistant 🚀",
    "────────────────────────────────────",
    "📦 Model: " .. (config.model or "gpt-4"),
    "📊 Quota: " .. (config.quota or "untracked"),
    "",
    "🧠 [Send]   ✅ [Accept]   ❌ [Deny]",
    "",
    "💬 Prompt:",
    "",
    "> ", -- editable line
    "",
    "🧠 Response:"
  }

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  local ns = vim.api.nvim_create_namespace("jb-ai")
  vim.highlight.range(bufnr, ns, "JBHeader", {0, 0}, {0, -1})
  vim.highlight.range(bufnr, ns, "JBAction", {5, 0}, {5, -1})
  vim.highlight.range(bufnr, ns, "JBPrompt", {9, 0}, {9, -1})

  local input_row = 9
  vim.api.nvim_win_set_cursor(win, {input_row + 1, 2})

  local function stream_response(bufnr, start, data)
    local lines = vim.split(data, "\n")
    local i = 0
    local frame = 1

    local timer = vim.loop.new_timer()
    timer:start(0, 60, vim.schedule_wrap(function()
      if i >= #lines then
        timer:stop()
        timer:close()
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "🔔 All done! 🎯" })
        return
      end

      local prefix = spinner_frames[frame]
      local line = prefix .. " " .. lines[i + 1]
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { line })
      vim.api.nvim_buf_add_highlight(bufnr, ns, "JBStream", start + i, 0, -1)

      i = i + 1
      frame = (frame % #spinner_frames) + 1
    end))
  end

  local function send_prompt()
    local line = vim.api.nvim_buf_get_lines(bufnr, input_row + 1, input_row + 2, false)[1] or ""
    local prompt = line:gsub("^%s*>%s*", "")
    if prompt == "" then return end

    chat.send(prompt, function(reply)
      last_response = reply
      threads.append(prompt, reply)

      local start_line = input_row + 3
      vim.api.nvim_buf_set_lines(bufnr, start_line, -1, false, { "⏳ Thinking..." })
      stream_response(bufnr, start_line, reply)

      -- Clear input
      vim.api.nvim_buf_set_lines(bufnr, input_row + 1, input_row + 2, false, { "> " })
      vim.api.nvim_win_set_cursor(win, {input_row + 1, 2})
    end)
  end

  local function accept()
    if last_response ~= "" then
      edits.inject_response(last_response)
      vim.notify("✅ Accepted and inserted!", vim.log.levels.INFO)
    end
  end

  local function deny()
    edits.reject()
    vim.api.nvim_buf_set_lines(bufnr, input_row + 3, -1, false, { "❌ Response cleared." })
  end

  -- 🎛 Keymaps
  vim.keymap.set("n", "<CR>", send_prompt, { buffer = bufnr })
  vim.keymap.set("i", "<C-s>", function()
    vim.api.nvim_input("<Esc>")
    vim.schedule(send_prompt)
  end, { buffer = bufnr })

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
          vim.notify("⚠️ Stored in memory only", vim.log.levels.WARN)
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
  vim.keymap.set("n", config.chat_key, M.chat_prompt, { desc = "JetBrains AI Chat Split" })
  vim.keymap.set("n", config.setup_key, M.setup_tokens, { desc = "Setup Tokens" })
  vim.keymap.set("n", config.logout_key, M.logout_tokens, { desc = "Clear Tokens" })

  vim.api.nvim_create_user_command("JetbrainsAIHistory", function()
    require("jetbrainsai.history_view").open()
  end, {})
end

return M

