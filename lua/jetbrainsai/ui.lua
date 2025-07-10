local config = require("jetbrainsai.config").get()
local proxy = require("jetbrainsai.proxy")
local chat = require("jetbrainsai.chat")
local secure = require("jetbrainsai.secure")
local threads = require("jetbrainsai.threads")
local edits = require("jetbrainsai.edits")
local NuiPopup = require("nui.popup")
local NuiInput = require("nui.input")
local NuiMenu = require("nui.menu")
local NuiLine = require("nui.line")
local event = require("nui.utils.autocmd")

local M = {}

vim.api.nvim_set_hl(0, "JetBrainsAccept", { fg = "#00FF00", bold = true })
vim.api.nvim_set_hl(0, "JetBrainsDeny", { fg = "#FF4444", bold = true })
vim.api.nvim_set_hl(0, "JetBrainsTitle", { fg = "#aaaaff", italic = true })

local last_response = ""

local function animate(bufnr, lines)
  local delay = 30
  local i = 0
  local timer = vim.loop.new_timer()
  timer:start(0, delay, vim.schedule_wrap(function()
    if i >= #lines then
      timer:stop()
      timer:close()
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "", "🟢 Response complete." })
      return
    end
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { lines[i + 1] })
    i = i + 1
  end))
end

local function open_model_menu(update_model)
  local menu = NuiMenu({
    position = "50%",
    size = { width = 30, height = 5 },
    border = { style = "single", text = { top = " Choose Model ", top_align = "center" } },
  }, {
    lines = {
      NuiMenu.item("gpt-4"),
      NuiMenu.item("gpt-3.5"),
      NuiMenu.item("code-llm"),
    },
    on_submit = function(item)
      config.model = item.text
      update_model(item.text)
    end,
  })
  menu:mount()
end

function M.chat_prompt()
  local popup = NuiPopup({
    enter = true,
    focusable = true,
    position = "50%",
    size = { width = "50%", height = "100%" },
    border = { style = "rounded", text = { top = " JetBrains AI ", top_align = "center" } },
    buf_options = { filetype = "jetbrainsai" },
  })

  popup:mount()
  local bufnr = popup.bufnr

  local header = NuiLine()
  header:append("🧠 Model: ", "JetBrainsTitle")
  header:append(config.model or "gpt-4", "Identifier")
  header:append("    📊 Quota: ", "JetBrainsTitle")
  header:append(config.quota or "untracked", "Identifier")
  popup:render_line(0, header)

  vim.api.nvim_buf_set_lines(bufnr, 1, 4, false, {
    "──────────────────────────────",
    "[ Select Model ]",
    "",
    "[🟩 Accept]    [🟥 Deny]",
    "",
    "💬 Prompt ↓"
  })

  vim.api.nvim_buf_add_highlight(bufnr, -1, "JetBrainsAccept", 4, 0, 9)
  vim.api.nvim_buf_add_highlight(bufnr, -1, "JetBrainsDeny", 4, 15, 23)

  local input = NuiInput({
    position = { row = 6, col = 2 },
    size = { width = 40 },
    border = { style = "single", text = { top = " Prompt ", top_align = "left" } },
  }, {
    prompt = "> ",
    default_value = "",
    on_submit = function(msg)
      if msg == "" then return end
      chat.send(msg, function(reply)
        last_response = reply
        local lines = vim.split(reply, "\n")
        vim.api.nvim_buf_set_lines(bufnr, 8, -1, false, { "", "🧠 Response:" })
        animate(bufnr, lines)
      end)
    end,
  })
  input:mount()

  -- Dynamic model selector
  vim.keymap.set("n", "m", function()
    open_model_menu(function(new_model)
      local line = NuiLine()
      line:append("🧠 Model: ", "JetBrainsTitle")
      line:append(new_model, "Identifier")
      popup:render_line(0, line)
    end)
  end, { buffer = bufnr })

  -- Accept/Inject response
  vim.keymap.set("n", "<CR>", function()
    if last_response ~= "" then edits.inject_response(last_response) end
    popup:unmount()
  end, { buffer = bufnr })

  -- Reject
  vim.keymap.set("n", "q", function()
    edits.reject()
    popup:unmount()
  end, { buffer = bufnr })

  -- Auto close on buffer leave
  event.on("BufLeave", bufnr, function() popup:unmount() end)
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
  vim.keymap.set("n", config.chat_key, M.chat_prompt, { desc = "JetBrains AI Chat Pane" })
  vim.keymap.set("n", config.setup_key, M.setup_tokens, { desc = "Setup Tokens" })
  vim.keymap.set("n", config.logout_key, M.logout_tokens, { desc = "Clear Tokens" })

  vim.api.nvim_create_user_command("JetbrainsAIHistory", function()
    require("jetbrainsai.history_view").open()
  end, {})
end

return M

