local M = {}

function M.is_nixos()
  return vim.fn.filereadable '/etc/NIXOS' == 1
end

return M
