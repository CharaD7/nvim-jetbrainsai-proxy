local config = {
  proxy_url = "http://localhost:8080/v1/chat/completions",
  chat_key = "<leader>jc",
  setup_key = "<leader>js",
  logout_key = "<leader>jl",
  theme = "catppuccin",
  ui_style = "minimal",
  auto_prompt = true, -- ⛳️ Toggle encrypted token loading on startup
  jwt = nil,
  bearer = nil,
  status = "⚠️", -- Will be updated when tokens are loaded
}

local cache_file = vim.fn.stdpath("data") .. "/jetbrainsai_proxy.json"

function config.load_cached_proxy()
  if vim.fn.filereadable(cache_file) == 1 then
    local data = vim.fn.json_decode(vim.fn.readfile(cache_file))
    if data and data.proxy_url then
      config.proxy_url = data.proxy_url
    end
  end
end

function config.save_proxy(proxy_url)
  vim.fn.writefile({ vim.fn.json_encode({ proxy_url = proxy_url }) }, cache_file)
end

return {
  load = function(user_opts)
    config = vim.tbl_deep_extend("force", config, user_opts or {})
    vim.g.jetbrainsai_config = config
  end,
  get = function() return config end
}

