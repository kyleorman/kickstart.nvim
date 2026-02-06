-- lua/custom/plugins/lsp.lua
-- Extra LSP, Treesitter, formatter and diagnostics helpers for kickstart.nvim
-- Fully tested with kickstart.nvim 2025-07-23.
-- ✔  SVLS for IDE features (formatting disabled)
-- ✔  Verible LSP optional (formatting disabled)
-- ✔  Conform.nvim calls verible-verilog-format on save for *.sv/*.svh/*.v
-- ✔  Mason installs both LSPs *and* the Verible binaries.

-- NOTE (nvim 0.11+):
-- Avoid `require('lspconfig')` and `require('lspconfig.util')` (deprecated framework path).
-- Use `vim.lsp.config()` + `vim.lsp.enable()` and `vim.lsp.util.root_pattern()` instead.

-----------------------------------------------------------------------------
-- Helper --------------------------------------------------------------------
-----------------------------------------------------------------------------
local function disable_formatting(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

-----------------------------------------------------------------------------
-- Plugin spec ---------------------------------------------------------------
-----------------------------------------------------------------------------
return {
  ---------------------------------------------------------------------------
  -- Mason-lspconfig ---------------------------------------------------------
  ---------------------------------------------------------------------------
  {
    'williamboman/mason-lspconfig.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local add = { 'svls', 'verible', 'vhdl_ls', 'yamlls', 'marksman' }
      local present = {}
      for _, s in ipairs(opts.ensure_installed) do
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
    opts = {
      servers = {
        ---------------------------------------------------------------------
        -- SystemVerilog LS --------------------------------------------------
        ---------------------------------------------------------------------
        svls = {
          settings = {
            systemverilog = {
              includeIndexing = { '**/*.{sv,svh}' },
              excludeIndexing = { 'test/**/*' },
              defines = {},
              launchConfiguration = 'verilator --sv',
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
          -- Neovim 0.11+: use vim.fs.root for project root detection
          return vim.fs.root(fname, { '.git', '.svls.toml', 'hdl.tcl', 'Makefile', 'meson.build' })
        end,
          on_attach = function(client)
            disable_formatting(client)
          end,
        },

        ---------------------------------------------------------------------
        -- Verible LS (optional diagnostics, formatting disabled) ------------
        ---------------------------------------------------------------------
        verible = {
          init_options = {
            formatting = {
              verible_verilog_format_flags = {
                '--indentation_spaces=2',
                '--column_limit=120',
                '--style=google',
              },
            },
          },
          on_attach = function(client)
            disable_formatting(client)
          end,
        },

        ---------------------------------------------------------------------
        -- VHDL --------------------------------------------------------------
        ---------------------------------------------------------------------
        vhdl_ls = { settings = { vhdl_ls = {} } },

        ---------------------------------------------------------------------
        -- YAML --------------------------------------------------------------
        ---------------------------------------------------------------------
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

        ---------------------------------------------------------------------
        -- Markdown ----------------------------------------------------------
        ---------------------------------------------------------------------
        marksman = {},
      },
    },

    -- Global setup applying our wrapped on_attach and default capabilities
    config = function(_, opts)
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local function wrap_on_attach(user_on_attach)
        return function(client, bufnr)
          if client.name == 'svls' or client.name == 'verible' then
            disable_formatting(client) -- just in case
          end
          if user_on_attach then
            user_on_attach(client, bufnr)
          end
        end
      end

      -- Register configs using the native nvim 0.11+ API
      for name, server_opts in pairs(opts.servers) do
        server_opts.capabilities = vim.tbl_deep_extend('force', capabilities, server_opts.capabilities or {})
        server_opts.on_attach = wrap_on_attach(server_opts.on_attach)
        vim.lsp.config(name, server_opts)
      end

      -- Enable all configured servers
      vim.lsp.enable(vim.tbl_keys(opts.servers))
    end,
  },

  ---------------------------------------------------------------------------
  -- Conform – formatter manager --------------------------------------------
  ---------------------------------------------------------------------------
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      -- ➊ Map filetypes to formatters
      opts.formatters_by_ft = vim.tbl_deep_extend('force', opts.formatters_by_ft or {}, {
        markdown = { 'markdownlint' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        yaml = { 'yamlfmt' },
        systemverilog = { 'verible_sv' },
        verilog = { 'verible_sv' },
      })

      -- ➋ Declare the custom Verible formatter wrapper
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

      -- ➌ Simple on-save table (no function → avoids boolean index bug)
      opts.format_on_save = {
        lsp_fallback = false,
        timeout_ms = 3000,
      }

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
      vim.list_extend(opts.ensure_installed, { 'verilog', 'vhdl' })
    end,
  },

  ---------------------------------------------------------------------------
  -- Trouble.nvim ------------------------------------------------------------
  ---------------------------------------------------------------------------
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { use_diagnostic_signs = true, auto_close = true },
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

