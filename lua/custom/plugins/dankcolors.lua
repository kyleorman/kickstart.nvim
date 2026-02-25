-- Theme options - uncomment ONE block to activate it.
-- Active default: Gruvbox.
--
-- Alternatives:
--   Option B: Catppuccin Mocha
--   Option C: Kanagawa
--   Option D: Rose Pine Moon

return {
	-- Option A: Gruvbox (ACTIVE)
	{
		'ellisonleao/gruvbox.nvim',
		priority = 1001,
		config = function()
			require('gruvbox').setup {
				contrast = 'hard', -- 'hard' | 'medium' | 'soft'
				italic = {
					strings = true,
					comments = true,
					operators = false,
					folds = true,
				},
				bold = true,
			}

			vim.o.background = 'dark'
			vim.cmd.colorscheme 'gruvbox'
		end,
	},

	-- Option B: Catppuccin Mocha
	-- {
	-- 	'catppuccin/nvim',
	-- 	name = 'catppuccin',
	-- 	priority = 1001,
	-- 	config = function()
	-- 		require('catppuccin').setup { flavour = 'mocha' }
	-- 		vim.cmd.colorscheme 'catppuccin'
	-- 	end,
	-- },

	-- Option C: Kanagawa
	-- {
	-- 	'rebelot/kanagawa.nvim',
	-- 	priority = 1001,
	-- 	config = function()
	-- 		require('kanagawa').setup { theme = 'wave' }
	-- 		vim.cmd.colorscheme 'kanagawa'
	-- 	end,
	-- },

	-- Option D: Rose Pine Moon
	-- {
	-- 	'rose-pine/neovim',
	-- 	name = 'rose-pine',
	-- 	priority = 1001,
	-- 	config = function()
	-- 		require('rose-pine').setup { variant = 'moon' }
	-- 		vim.cmd.colorscheme 'rose-pine'
	-- 	end,
	-- },
}
