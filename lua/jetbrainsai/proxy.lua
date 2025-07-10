local M = {}
local config = require("jetbrainsai.config").get()

function M.set_tokens(jwt, bearer)
  config.jwt = jwt
  config.bearer = bearer
end

function M.find_proxy()
  config.load_cached_proxy()

  local base = "http://localhost:"
  local ports = { 8080, 8081, 8082, 8083, 8084, 8085 }
  for _, port in ipairs(ports) do
    local url = base .. port .. "/v1/chat/completions"
    local code = vim.fn.system({ "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", url })
    if code == "200" or code == "400" or code == "401" then
      local full_url = base .. port .. "/v1/chat/completions"
      config.proxy_url = full_url
      config.save_proxy(full_url)
      vim.notify("🌐 JetBrains AI proxy detected: " .. full_url, vim.log.levels.INFO)
      return full_url
    end
  end

  -- Neutral fallback (customizable endpoint)
  config.proxy_url = "http://localhost:8080/v1/chat/completions"
  vim.notify("⚠️ No proxy detected. Using fallback: " .. config.proxy_url, vim.log.levels.WARN)
  return config.proxy_url
end

function M.check_proxy()
  local url = config.proxy_url or M.find_proxy()
  if not url then return end

  vim.fn.jobstart({ "curl", "-s", url }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 then
        vim.notify("⚠️ JetBrains Proxy may be offline", vim.log.levels.WARN)
      else
        vim.notify("✅ JetBrains Proxy reachable", vim.log.levels.INFO)
      end
    end
  })
end

return M

