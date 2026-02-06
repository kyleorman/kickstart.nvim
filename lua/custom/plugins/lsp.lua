-- lua/custom/plugins/lsp.lua
-- Extra LSP, formatter and diagnostics helpers for kickstart.nvim
-- Adds HDL (SystemVerilog, Verilog, VHDL), YAML, and Markdown support.
--
-- Architecture:
--   - Servers are added via mason-tool-installer ensure_installed
--   - Server configs use the native nvim 0.11+ vim.lsp.config() / vim.lsp.enable() API
--   - Conform.nvim formatters are extended via opts merging (preserves init.lua format_on_save)
--   - Trouble.nvim v3 for diagnostics panel

-----------------------------------------------------------------------------
-- Helper --------------------------------------------------------------------
-----------------------------------------------------------------------------
local function disable_formatting(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

-----------------------------------------------------------------------------
-- Plugin specs --------------------------------------------------------------
-----------------------------------------------------------------------------
return {
  ---------------------------------------------------------------------------
  -- Mason tool installer — ensure HDL/YAML/Markdown tools are installed ----
  ---------------------------------------------------------------------------
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        'svls',
        'verible',
        'vhdl_ls',
        'yaml-language-server',
        'marksman',
        'shfmt',
        'yamlfmt',
        'markdownlint',
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- LSP server configs (nvim 0.11+ native API) ----------------------------
  ---------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    opts = function()
      -- Register server configs using the native nvim 0.11+ API.
      -- The kickstart init.lua config function handles capabilities (via blink.cmp),
      -- the LspAttach autocmd, and mason-lspconfig handlers for servers in its
      -- `servers` table. For additional servers not in that table, we use
      -- vim.lsp.config() + vim.lsp.enable() which is the recommended 0.11+ approach.

      -- SystemVerilog LS
      vim.lsp.config('svls', {
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
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local root = vim.fs.root(fname, { '.git', '.svls.toml', 'hdl.tcl', 'Makefile', 'meson.build' })
          if root then
            on_dir(root)
          end
        end,
        on_attach = function(client)
          disable_formatting(client)
        end,
      })

      -- Verible LS (diagnostics only, formatting disabled — conform handles formatting)
      vim.lsp.config('verible', {
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
      })

      -- VHDL
      vim.lsp.config('vhdl_ls', {
        settings = { vhdl_ls = {} },
      })

      -- YAML
      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            keyOrdering = false,
            validate = true,
            format = { enable = true },
            schemaStore = { enable = false, url = '' },
          },
        },
      })

      -- Markdown
      vim.lsp.config('marksman', {})

      -- Enable all the servers
      vim.lsp.enable { 'svls', 'verible', 'vhdl_ls', 'yamlls', 'marksman' }
    end,
  },

  ---------------------------------------------------------------------------
  -- Conform — additional formatters (merges with init.lua via opts) --------
  ---------------------------------------------------------------------------
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      -- Extend formatters_by_ft (preserves init.lua's lua/stylua and format_on_save function)
      opts.formatters_by_ft = vim.tbl_deep_extend('force', opts.formatters_by_ft or {}, {
        markdown = { 'markdownlint' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        yaml = { 'yamlfmt' },
        systemverilog = { 'verible_sv' },
        verilog = { 'verible_sv' },
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

      -- NOTE: We intentionally do NOT override opts.format_on_save here.
      -- The function-based format_on_save in init.lua is preserved, which
      -- correctly disables formatting for C/C++ and uses lsp_format = 'fallback'.

      return opts
    end,
  },

  ---------------------------------------------------------------------------
  -- Treesitter — add HDL parsers -------------------------------------------
  ---------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'verilog', 'vhdl' })
    end,
  },

  ---------------------------------------------------------------------------
  -- Trouble.nvim v3 --------------------------------------------------------
  ---------------------------------------------------------------------------
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
