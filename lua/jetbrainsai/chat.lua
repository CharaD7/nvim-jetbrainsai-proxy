local M = {}
local config = require("jetbrainsai.config").get()
local threads = require("jetbrainsai.threads")
local history = require("jetbrainsai.history")
local proxy = require("jetbrainsai.proxy")

-- Sends message and invokes callback with response
function M.send(prompt, callback)
  local payload = {
    model = config.model or "gpt-4",
    messages = threads.get(),
  }

  table.insert(payload.messages, { role = "user", content = prompt })

  local curl_cmd = string.format(
    "curl -s -X POST %s/v1/chat/completions -H 'Content-Type: application/json' -d '%s'",
    config.proxy_url,
    vim.fn.json_encode(payload)
  )

  vim.fn.jobstart(curl_cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local response = table.concat(data or {}, "\n")
      callback(response)
      threads.append(prompt, response)
      history.save(prompt, response)
    end,
  })
end

return M

