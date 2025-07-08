local config = {
  proxy_url = "http://localhost:8080/v1/chat/completions",
  chat_key = "<leader>jc",
  setup_key = "<leader>js",
  theme = "catppuccin",
  ui_style = "minimal",
  jwt = nil,
  bearer = nil,
}

return {
  load = function(user_opts)
    config = vim.tbl_deep_extend("force", config, user_opts or {})
    vim.g.jetbrainsai_config = config
  end,
  get = function() return config end
}

