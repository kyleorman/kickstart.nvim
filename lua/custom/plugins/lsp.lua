return {
	{
		-- Mason core: installs external binaries like LSP servers and formatters
		'williamboman/mason.nvim',
		build = ':MasonUpdate',
		config = function()
			require('mason').setup()
		end,
	},

	{
		-- LSP bridge between Mason and lspconfig (no setup_handlers)
		'williamboman/mason-lspconfig.nvim',
		dependencies = {
			'williamboman/mason.nvim',
			'neovim/nvim-lspconfig',
			'VonHeikemen/lsp-zero.nvim',
		},
		config = function()
			local mason_lspconfig = require('mason-lspconfig')
			local lspconfig       = require('lspconfig')
			local lsp_zero        = require('lsp-zero')

			--- 1) Install & ensure servers
			local servers         = {
				'pyright', -- Python
				'clangd', -- C/C++
				'bashls', -- Bash
				'marksman', -- Markdown
				'svls', -- SystemVerilog
				'verible', -- Verilog (format/lint)
				'vhdl_ls', -- VHDL
			}

			mason_lspconfig.setup({
				ensure_installed = servers,
			})

			--- 2) Prepare lsp-zero defaults
			lsp_zero.extend_lspconfig()

			--- 3) Manually setup each server
			for _, name in ipairs(servers) do
				lspconfig[name].setup({})
			end
		end,
	},

	{
		-- Formatter/Linter integration with Mason
		'jay-babu/mason-null-ls.nvim',
		dependencies = {
			'williamboman/mason.nvim',
			'nvimtools/none-ls.nvim', -- maintained fork of null-ls
		},
		config = function()
			require('mason-null-ls').setup({
				ensure_installed = {
					-- Python
					'black',
					'isort',
					'flake8',
					'autopep8',
					-- C/C++
					'clang-format',
					-- Shell
					'shfmt',
					-- Markdown
					'markdownlint',
					-- HDL
					'verible-verilog-format',
				},
				automatic_installation = true,
			})
		end,
	},

	{
		-- Formatter engine with LSP fallback
		'stevearc/conform.nvim',
		config = function()
			require('conform').setup({
				format_on_save = {
					timeout_ms = 2000,
					lsp_fallback = true,
				},
			})
		end,
	},
}
