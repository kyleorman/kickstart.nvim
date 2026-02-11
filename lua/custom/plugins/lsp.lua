-- lua/custom/plugins/lsp.lua
-- Extra formatters, treesitter parsers, and diagnostics helpers for kickstart.nvim.
-- Adds HDL, YAML, Markdown, Python, C/C++, and Rust formatter integration plus Trouble panel.

return {
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      -- Extend formatters_by_ft (preserves init.lua's format_on_save function)
      opts.formatters_by_ft = vim.tbl_deep_extend('force', opts.formatters_by_ft or {}, {
        markdown = { 'markdownlint' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        yaml = { 'yamlfmt' },
        systemverilog = { 'verible_sv' },
        verilog = { 'verible_sv' },
        python = { 'isort', 'black' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        rust = { 'rustfmt' },
      })

      -- Declare the custom Verible formatter wrapper
      opts.formatters = vim.tbl_deep_extend('force', opts.formatters or {}, {
        verible_sv = {
          command = 'verible-verilog-format',
          args = {
            '--indentation_spaces',
            '2',
            '--column_limit',
            '120',
            '-', -- stdin
          },
          stdin = true,
          condition = function()
            return vim.fn.executable 'verible-verilog-format' == 1
          end,
        },
      })

      return opts
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'verilog', 'vhdl' })
    end,
  },

  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      auto_close = true,
    },
    keys = {
      { '<leader>td', '<cmd>Trouble diagnostics toggle<cr>', desc = '[T]rouble: [D]iagnostics' },
      { '<leader>tb', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = '[T]rouble: Buffer' },
      { '<leader>ts', '<cmd>Trouble symbols toggle focus=false<cr>', desc = '[T]rouble: [S]ymbols' },
      { '<leader>tl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = '[T]rouble: LS' },
      { '<leader>tL', '<cmd>Trouble loclist toggle<cr>', desc = '[T]rouble: [L]oclist' },
      { '<leader>tq', '<cmd>Trouble qflist toggle<cr>', desc = '[T]rouble: [Q]uickfix' },
    },
  },
}
