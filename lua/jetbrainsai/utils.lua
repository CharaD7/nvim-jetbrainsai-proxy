local M = {}

-- Checks if a path exists
function M.exists(path)
  return vim.fn.empty(vim.fn.glob(path)) == 0
end

-- Securely write temporary data (if needed later)
function M.write_temp(path, data)
  local f = io.open(path, "w")
  if f then
    f:write(data)
    f:close()
    return true
  end
  return false
end

-- Normalize token for preview output
function M.truncate(str, max)
  max = max or 100
  return #str > max and str:sub(1, max) .. "…" or str
end

return M

