local M = {}

-- Store messages between turns
M.messages = {}

function M.clear()
  M.messages = {}
end

function M.append(user_msg, ai_msg)
  table.insert(M.messages, { role = "user", content = user_msg })
  table.insert(M.messages, { role = "assistant", content = ai_msg })
end

function M.get()
  return vim.deepcopy(M.messages)
end

return M

