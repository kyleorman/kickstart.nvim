-- lua/custom/plugins/lint.lua
-- Linting helpers for HDL, Python, and VHDL

return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      local function has(cmd)
        return vim.fn.executable(cmd) == 1
      end

      lint.linters_by_ft = lint.linters_by_ft or {}
      lint.linters_by_ft.python = has 'ruff' and { 'ruff' } or nil
      lint.linters_by_ft.systemverilog = has 'verilator' and { 'verilator' } or nil
      lint.linters_by_ft.verilog = has 'verilator' and { 'verilator' } or nil
      lint.linters_by_ft.vhdl = has 'ghdl' and { 'ghdl' } or nil

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
