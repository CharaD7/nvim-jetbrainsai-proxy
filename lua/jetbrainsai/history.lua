local M = {}
local history_path = vim.fn.stdpath("data") .. "/jetbrainsai_history.json"

function M.save(prompt, response)
  local entry = {
    time = os.date("%Y-%m-%d %H:%M:%S"),
    prompt = prompt,
    response = response,
  }

  local data = {}
  if vim.fn.filereadable(history_path) == 1 then
    data = vim.fn.json_decode(vim.fn.readfile(history_path))
  end

  table.insert(data, entry)
  vim.fn.writefile({ vim.fn.json_encode(data) }, history_path)
end

function M.load()
  if vim.fn.filereadable(history_path) == 0 then return {} end
  return vim.fn.json_decode(vim.fn.readfile(history_path))
end

return M

