local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local chat = require("jetbrainsai.chat")
local secure = require("jetbrainsai.secure")
local threads = require("jetbrainsai.threads")
local edits = require("jetbrainsai.edits")

local M = {}
local last_response = ""
local ns = vim.api.nvim_create_namespace("jetbrainsai-ui")

local spinner = { "🌕", "🌖", "🌗", "🌘", "🌑", "🌒", "🌓", "🌔" }

vim.api.nvim_set_hl(0, "JBHeader", { fg = "#89b4fa", bold = true })
vim.api.nvim_set_hl(0, "JBAction", { fg = "#a6e3a1", italic = true })
vim.api.nvim_set_hl(0, "JBPrompt", { fg = "#f9e2af", italic = true })
vim.api.nvim_set_hl(0, "JBStream", { fg = "#cba6f7" })
vim.api.nvim_set_hl(0, "JBBorder", { fg = "#313244" })

local model = config.model or "GPT-4.0"
local codebase = true

local function toggle_model(bufnr)
  vim.ui.select({ "GPT-4.0", "GPT-3.5", "GPT-4-turbo" }, { prompt = "Choose Model:" }, function(choice)
    if choice then
      model = choice
      vim.api.nvim_buf_set_lines(bufnr, 2, 3, false, { "📦 Model: [" .. model .. "]   [Codebase]" })
    end
  end)
end

local function toggle_codebase(bufnr)
  codebase = not codebase
  local label = codebase and "[Codebase ✅]" or "[Codebase ❌]"
  vim.api.nvim_buf_set_lines(bufnr, 2, 3, false, { "📦 Model: [" .. model .. "]   " .. label })
end

local function stream_response(bufnr, start_row, prompt, reply)
  local lines = vim.split(reply, "\n")
  local i, frame = 0, 1
  local timer = vim.loop.new_timer()
  timer:start(0, 60, vim.schedule_wrap(function()
    if i >= #lines then
      timer:stop()
      timer:close()
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {
        "",
        "🔮 Suggestions:",
        "💡 Expand this",
        "🧠 Explain that",
        "🛠 Improve code",
        "",
        "✅ Done!"
      })
      return
    end
    local line = spinner[frame] .. " " .. lines[i + 1]
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { line })
    vim.api.nvim_buf_add_highlight(bufnr, ns, "JBStream", start_row + i, 0, -1)
    i = i + 1
    frame = (frame % #spinner) + 1
  end))
end

function M.chat_prompt()
  vim.cmd("vsplit")
  vim.cmd("vertical resize 60")
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, bufnr)

  vim.wo[win].wrap = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.bo[bufnr].buftype = ""
  vim.bo[bufnr].filetype = "jetbrainsai"
  vim.bo[bufnr].modifiable = true

  local input_row = 14
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    "💬 JetBrains AI Chat Interface",
    "────────────────────────────────────────────",
    "📦 Model: [" .. model .. "]   [Codebase]",
    "",
    "🧠 Chat History:",
    "",
    "• Hello there! 👋",
    "",
    "────────────────────────────────────────────",
    "🔲 Ask AI Assistant...",
    "┌────────────────────────────────────────────",
    "> Ask AI Assistant...",
    "└────────────────────────────────────────────",
    "",
    "[Chat]   [Accept]   [Deny]"
  })

  vim.highlight.range(bufnr, ns, "JBHeader", {0, 0}, {0, -1})
  vim.highlight.range(bufnr, ns, "JBPrompt", {10, 0}, {10, -1})
  vim.highlight.range(bufnr, ns, "JBBorder", {11, 0}, {11, -1})
  vim.highlight.range(bufnr, ns, "JBBorder", {13, 0}, {13, -1})
  vim.highlight.range(bufnr, ns, "JBAction", {14, 0}, {14, -1})
  vim.api.nvim_win_set_cursor(win, {12, 2})

  local function send()
    local line = vim.api.nvim_buf_get_lines(bufnr, 12, 13, false)[1] or ""
    local prompt = line:gsub("^%s*>%s*", "")
    if prompt == "" or prompt == "Ask AI Assistant..." then return end

    local tokens = proxy.get_tokens and proxy.get_tokens() or { jwt = config.jwt, bearer = config.bearer }
    if not tokens or not tokens.jwt or not tokens.bearer then
      vim.notify("🔑 Tokens not loaded. Please run :JetbrainsAISetup", vim.log.levels.ERROR)
      return
    end

    proxy.find_proxy()

    if codebase then
      local context = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
      prompt = prompt .. "\n\n[Codebase Context]\n" .. context
    end

    chat.send(prompt, function(reply)
      last_response = reply
      threads.append(prompt, reply)
      vim.bo[bufnr].syntax = "markdown"
      vim.api.nvim_buf_set_lines(bufnr, 6, 6, false, { "• " .. prompt })
      stream_response(bufnr, 7, prompt, reply)
      vim.api.nvim_buf_set_lines(bufnr, 12, 13, false, { "> Ask AI Assistant..." })
      vim.api.nvim_win_set_cursor(win, {12, 2})
    end)
  end

  local function accept()
    if last_response ~= "" then
      edits.inject_response(last_response)
      vim.notify("✅ Accepted!", vim.log.levels.INFO)
    end
  end

  local function deny()
    edits.reject()
    vim.api.nvim_buf_set_lines(bufnr, 7, -1, false, { "❌ Response cleared." })
  end

  vim.keymap.set("n", "<CR>", send, { buffer = bufnr })
  vim.keymap.set("i", "<C-s>", function()
    vim.api.nvim_input("<Esc>")
    vim.schedule(send)
  end, { buffer = bufnr })

  vim.keymap.set("n", "<leader>ja", accept, { buffer = bufnr })
  vim.keymap.set("n", "<leader>jd", deny, { buffer = bufnr })
  vim.keymap.set("n", "<leader>jm", function() toggle_model(bufnr) end, { buffer = bufnr })
  vim.keymap.set("n", "<leader>jc", function() toggle_codebase(bufnr) end, { buffer = bufnr })
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
  vim.keymap.set("n", config.chat_key, M.chat_prompt, { desc = "JetBrains AI Chat Split" })
  vim.keymap.set("n", config.setup_key, M.setup_tokens, { desc = "Setup Tokens" })
  vim.keymap.set("n", config.logout_key, M.logout_tokens, { desc = "Clear Tokens" })

  vim.api.nvim_create_user_command("JetbrainsAIHistory", function()
    require("jetbrainsai.history_view").open()
  end, {})
end

return M

