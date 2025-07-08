local M = {}
local token_path = vim.fn.stdpath("cache") .. "/nvim-jetbrainsai/tokens.enc"

function M.encrypt_and_store(jwt, bearer, passphrase)
  local data = vim.fn.json_encode({ jwt = jwt, bearer = bearer })
  local cmd = string.format("echo '%s' | openssl enc -aes-256-cbc -a -salt -pass pass:%s -out %s", data, passphrase, token_path)
  os.execute(cmd)
end

function M.load_tokens(passphrase)
  if vim.fn.filereadable(token_path) == 0 then return nil end
  local cmd = string.format("openssl enc -aes-256-cbc -d -a -in %s -pass pass:%s", token_path, passphrase)
  local result = vim.fn.system(cmd)
  local ok, decoded = pcall(vim.fn.json_decode, result)
  return ok and decoded or nil
end

return M

