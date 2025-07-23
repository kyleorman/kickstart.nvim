-- in ~/.config/nvim/lua/custom/plugins/copilot.lua
return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot', -- lazy‑load on the :Copilot commands
  event = 'VeryLazy', -- or whatever you prefer
  opts = {
    suggestion = { enabled = true, auto_trigger = true },
    panel = { enabled = false },
    filetypes = {
      -- disable in certain filetypes if you want:
      yaml = false,
      markdown = false,
    },
  },
  config = function(_, opts)
    require('copilot').setup(opts)
  end,
}
