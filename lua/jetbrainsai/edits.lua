local M = {}

function M.inject_response(reply)
  local lines = vim.split(reply, "\n")
  vim.api.nvim_buf_set_lines(0, vim.fn.line("."), vim.fn.line("."), false, lines)
  vim.notify("💡 AI response inserted into buffer", vim.log.levels.INFO)
end

function M.reject()
  vim.notify("🚫 Response discarded.", vim.log.levels.WARN)
end

return M

