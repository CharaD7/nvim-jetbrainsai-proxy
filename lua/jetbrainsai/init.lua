local M = {}

function M.setup(opts)
  require("jetbrainsai.config").load(opts)
  require("jetbrainsai.proxy").check_proxy()
  require("jetbrainsai.ui").init()
  require("jetbrainsai.commands").init()
end

return M

