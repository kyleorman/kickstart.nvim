return {
	{
		"RRethy/base16-nvim",
		priority = 1001,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#141218',
				base01 = '#141218',
				base02 = '#9d99a5',
				base03 = '#9d99a5',
				base04 = '#f4efff',
				base05 = '#faf8ff',
				base06 = '#faf8ff',
				base07 = '#faf8ff',
				base08 = '#ff9fb2',
				base09 = '#ff9fb2',
				base0A = '#d7c6ff',
				base0B = '#a5ffb8',
				base0C = '#e9e0ff',
				base0D = '#d7c6ff',
				base0E = '#ded0ff',
				base0F = '#ded0ff',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#9d99a5',
				fg = '#faf8ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#d7c6ff',
				fg = '#141218',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#9d99a5' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#e9e0ff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#ded0ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#d7c6ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#d7c6ff',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#e9e0ff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#a5ffb8',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#f4efff' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#f4efff' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#9d99a5',
				italic = true
			})

			vim.g.colors_name = 'dankcolors'

			local current_file_path = debug.getinfo(1, "S").source:sub(2)
			if not _G._dankcolors_watcher then
				local uv = vim.uv or vim.loop
				_G._dankcolors_watcher = uv.new_fs_event()
				_G._dankcolors_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local ok, new_spec = pcall(dofile, current_file_path)
					if not ok then
						vim.notify('dankcolors: reload error: ' .. tostring(new_spec), vim.log.levels.WARN)
						return
					end
					if new_spec and new_spec[1] and new_spec[1].config then
						local config_ok, config_err = pcall(new_spec[1].config)
						if not config_ok then
							vim.notify('dankcolors: apply error: ' .. tostring(config_err), vim.log.levels.WARN)
							return
						end
						vim.notify('dankcolors: theme reloaded', vim.log.levels.INFO)
					end
				end))
			end
		end
	}
}
