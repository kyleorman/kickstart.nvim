-- lua/custom/plugins/lsp.lua
-- Extra LSP, Treesitter, formatter and diagnostics helpers for kickstart.nvim
return {
  ---------------------------------------------------------------------------
  -- Mason-Lspconfig ---------------------------------------------------------
  ---------------------------------------------------------------------------
  {
    'williamboman/mason-lspconfig.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- Add your servers to the list
      local add = { 'svls', 'vhdl_ls', 'yamlls', 'marksman' }
      local present = {}
      for _, s in ipairs(opts.ensure_installed or {}) do
        present[s] = true
      end
      for _, s in ipairs(add) do
        if not present[s] then
          table.insert(opts.ensure_installed, s)
        end
      end
    end,
  },

  ---------------------------------------------------------------------------
  -- nvim-lspconfig ----------------------------------------------------------
  ---------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    -- The opts table defines your server-specific settings.
    opts = {
      servers = {
        -- SystemVerilog
        svls = {
          settings = {
            systemverilog = {
              includeIndexing = { '**/*.{sv,svh}' },
              excludeIndexing = { 'test/**/*' },
              defines = {},
              launchConfiguration = 'verilator --sv', -- keep it simple
              lintOnUnsaved = true,
              lintConfig = {
                rules = {
                  case_default = true,
                  multi_driven = true,
                  enum_with_type = true,
                  unique_case = true,
                  module_name_style = 'lower_snake_case',
                  parameter_name_style = 'UPPER_SNAKE_CASE',
                  variable_name_style = 'lower_snake_case',
                  style_indent = false,
                  style_textwidth = false,
                  re_required_copyright = false,
                  re_required_header = false,
                  blocking_assignment_in_always_ff = false,
                  non_blocking_assignment_in_always_comb = false,
                },
              },
            },
          },
          root_dir = function(fname)
            local util = require 'lspconfig.util'
            return util.root_pattern('.git', '.svls.toml', 'hdl.tcl')(fname)
              or util.root_pattern('Makefile', 'meson.build')(fname)
          end,
        },

        -- VHDL
        vhdl_ls = {
          settings = {
            vhdl_ls = {},
          },
        },

        -- YAML
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              validate = true,
              format = { enable = true },
              schemaStore = { enable = false, url = '' },
            },
          },
        },

        -- Markdown
        marksman = {},
      },
    },
    -- This config function ensures the servers are started correctly
    -- with the necessary completion capabilities.
    config = function(_, opts)
      local lspconfig = require 'lspconfig'
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      for server_name, server_opts in pairs(opts.servers) do
        -- Ensure capabilities are merged, not overwritten
        server_opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_opts.capabilities or {})
        -- Start the server
        lspconfig[server_name].setup(server_opts)
      end
    end,
  },

  ---------------------------------------------------------------------------
  -- Conform – formatter manager --------------------------------------------
  ---------------------------------------------------------------------------
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend('force', opts.formatters_by_ft or {}, {
        markdown = { 'markdownlint' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        yaml = { 'yamlfmt' },
        -- Uncomment when you actually have Verible installed:
        -- systemverilog  = { 'verible_verilog_format' },
        -- verilog        = { 'verible_verilog_format' },
      })

      opts.format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        return ft ~= '' and opts.formatters_by_ft[ft] ~= nil
      end

      return opts
    end,
  },

  ---------------------------------------------------------------------------
  -- Treesitter --------------------------------------------------------------
  ---------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local extra = { 'verilog', 'vhdl' } -- Verilog parser covers SystemVerilog
      vim.list_extend(opts.ensure_installed, extra)
    end,
  },

  ---------------------------------------------------------------------------
  -- Trouble.nvim ------------------------------------------------------------
  ---------------------------------------------------------------------------
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      use_diagnostic_signs = true,
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
