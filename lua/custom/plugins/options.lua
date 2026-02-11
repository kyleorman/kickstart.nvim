-- ~/.config/nvim/lua/custom/plugins/options.lua
return {
  {
    'nvim-lua/plenary.nvim', -- any already‑installed plugin works as a stub
    name = 'core-options',
    lazy = false, -- load immediately at startup

    init = function()
      -----------------------------------------------------------------------
      -- Global defaults: 4‑space, expand tabs everywhere
      -----------------------------------------------------------------------
      vim.opt.expandtab = true
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.softtabstop = 4

      -----------------------------------------------------------------------
      -- HDL ⇒ 2‑space indent (runs on every matching buffer)
      -----------------------------------------------------------------------
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'systemverilog', 'verilog', 'vhdl' },
        callback = function()
          vim.bo.tabstop = 2
          vim.bo.shiftwidth = 2
          vim.bo.softtabstop = 2
        end,
      })
    end,
  },
}
