local config = require("jetbrainsai.config").get()
local M = {}

function M.send(msg, callback)
  local payload = vim.fn.json_encode({
    messages = {{ role = "user", content = msg }},
    model = "gpt-4"
  })

  local cmd = string.format(
    'curl -s -H "Content-Type: application/json" -H "Authorization: Bearer %s" -H "jb-access-token: %s" -d \'%s\' %s',
    config.bearer or "", config.jwt or "", payload, config.proxy_url
  )

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, output)
      local raw = table.concat(output, "")
      local ok, res = pcall(vim.fn.json_decode, raw)
      if ok and res and res.choices then
        callback(res.choices[1].message.content)
      else
        vim.notify("JetBrains AI failed: invalid response", vim.log.levels.ERROR)
      end
    end
  })
end

return M

