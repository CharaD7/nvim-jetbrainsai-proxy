local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local chat = require("jetbrainsai.chat")
local secure = require("jetbrainsai.secure")
local threads = require("jetbrainsai.threads")
local edits = require("jetbrainsai.edits")

local M = {}
local last_response = ""

vim.api.nvim_set_hl(0, "JBHeader", { fg = "#89b4fa", bold = true })
vim.api.nvim_set_hl(0, "JBAction", { fg = "#a6e3a1", italic = true })
vim.api.nvim_set_hl(0, "JBPrompt", { fg = "#f9e2af", italic = true })
vim.api.nvim_set_hl(0, "JBStream", { fg = "#cba6f7" })

local ns = vim.api.nvim_create_namespace("jetbrainsai-ui")

function M.chat_prompt()
  vim.cmd("vsplit")
  vim.cmd("vertical resize 40")

  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, bufnr)

  -- 📼 Buffer options
  vim.wo[win].wrap = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.bo[bufnr].buftype = ""           -- make sure it's writable
  vim.bo[bufnr].filetype = "jetbrainsai"
  vim.bo[bufnr].modifiable = true

  local input_row = 9
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    "💡 JetBrains AI Assistant ✨",
    "──────────────────────────────────",
    "📦 Model: " .. (config.model or "gpt-4"),
    "📊 Quota: " .. (config.quota or "untracked"),
    "",
    "[Send]   [Accept]   [Deny]",
    "",
    "💬 Prompt:",
    "",
    "> ", -- prompt input
    "",
    "🧠 Response:"
  })

  vim.highlight.range(bufnr, ns, "JBHeader", {0, 0}, {0, -1})
  vim.highlight.range(bufnr, ns, "JBAction", {5, 0}, {5, -1})
  vim.highlight.range(bufnr, ns, "JBPrompt", {9, 0}, {9, -1})

  vim.api.nvim_win_set_cursor(win, {input_row + 1, 2})

  local function stream_response(data, prompt)
    local lines = vim.split(data, "\n")
    local i, frame = 0, 1
    local spinner = { "🌕", "🌖", "🌗", "🌘", "🌑", "🌒", "🌓", "🌔" }

    local timer = vim.loop.new_timer()
    timer:start(0, 60, vim.schedule_wrap(function()
      if i >= #lines then
        timer:stop()
        timer:close()
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {
          "", "🔮 Suggestions:", "💡 Expand this", "🧠 Explain that", "🛠 Improve code", "", "✅ Done!"
        })
        return
      end

      local line = spinner[frame] .. " " .. lines[i + 1]
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { line })
      vim.api.nvim_buf_add_highlight(bufnr, ns, "JBStream", input_row + 3 + i, 0, -1)
      i = i + 1
      frame = (frame % #spinner) + 1
    end))
  end

local function send_prompt()
  local line = vim.api.nvim_buf_get_lines(bufnr, input_row + 1, input_row + 2, false)[1] or ""
  local prompt = line:gsub("^%s*>%s*", "")
  if prompt == "" then return end

  local tokens = proxy.get_tokens and proxy.get_tokens() or { jwt = config.jwt, bearer = config.bearer }
  if not tokens or not tokens.jwt or not tokens.bearer then
    vim.notify("🔑 Tokens not loaded. Please run :JetbrainsAISetup", vim.log.levels.ERROR)
    return
  end

  proxy.find_proxy() -- ensures proxy_url is valid

  chat.send(prompt, function(reply)
    last_response = reply
    threads.append(prompt, reply)
    vim.bo[bufnr].syntax = "markdown"

    vim.api.nvim_buf_set_lines(bufnr, input_row + 3, -1, false, { "⏳ Thinking..." })
    stream_response(reply, prompt)

    vim.api.nvim_buf_set_lines(bufnr, input_row + 1, input_row + 2, false, { "> " })
    vim.api.nvim_win_set_cursor(win, {input_row + 1, 2})
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
    vim.api.nvim_buf_set_lines(bufnr, input_row + 3, -1, false, { "❌ Response cleared." })
  end

  -- ⌨️ Keymaps
  vim.keymap.set("n", "<CR>", send_prompt, { buffer = bufnr })
  vim.keymap.set("i", "<C-s>", function()
    vim.api.nvim_input("<Esc>")
    vim.schedule(send_prompt)
  end, { buffer = bufnr })

  -- 🧠 Hover on label + <CR>
  vim.keymap.set("n", "<CR>", function()
    local row = vim.fn.line('.') - 1
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
    if line:match("%[Send%]") then send_prompt()
    elseif line:match("%[Accept%]") then accept()
    elseif line:match("%[Deny%]") then deny()
    else send_prompt() end
  end, { buffer = bufnr })
end

-- unchanged setup/logout/init functions here...

return M

