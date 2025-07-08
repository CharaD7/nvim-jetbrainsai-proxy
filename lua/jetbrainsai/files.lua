local M = {}
local Path = require("plenary.path")

-- Preview + confirm user before writing
function M.prompt_create(filepath, content)
  vim.ui.select({ "Accept", "Reject" }, {
    prompt = "JetBrains AI wants to create " .. filepath,
  }, function(choice)
    if choice == "Accept" then
      M.create(filepath, content)
    end
  end)
end

function M.create(path, data)
  local file = Path:new(path)
  file:write(data, "w")
  vim.notify("📁 File created: " .. path, vim.log.levels.INFO)
end

return M

