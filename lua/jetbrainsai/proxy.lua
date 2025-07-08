local M = {}
local config = require("jetbrainsai.config").get()

function M.set_tokens(jwt, bearer)
  config.jwt = jwt
  config.bearer = bearer
end

function M.check_proxy()
  vim.fn.jobstart("curl -s " .. config.proxy_url, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 then
        vim.notify("⚠️ JetBrains Proxy may be offline", vim.log.levels.WARN)
      else
        vim.notify("✅ JetBrains Proxy detected", vim.log.levels.INFO)
      end
    end
  })
end

return M

