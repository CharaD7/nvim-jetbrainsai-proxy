local NuiPopup = require("nui.popup")
local history = require("jetbrainsai.history")

local M = {}

function M.open()
  local entries = history.load()
  local popup = NuiPopup({
    enter = true,
    focusable = true,
    position = "50%",
    size = {
      width = 60,
      height = 20,
    },
    border = {
      style = "rounded",
      text = {
        top = " Chat History ",
        top_align = "center",
      },
    },
    buf_options = {
      filetype = "jetbrainsai-history",
    },
  })

  popup:mount()
  local bufnr = popup.bufnr
  local lines = {}

  for _, entry in ipairs(entries) do
    table.insert(lines, "📅 " .. entry.time)
    table.insert(lines, "💬 Prompt: " .. entry.prompt)
    table.insert(lines, "🧠 Response: ")
    for _, line in ipairs(vim.split(entry.response, "\n")) do
      table.insert(lines, "  " .. line)
    end
    table.insert(lines, "───────────────────────────────────────────────")
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

end

return M

