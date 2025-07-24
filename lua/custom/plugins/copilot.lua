-- in ~/.config/nvim/lua/custom/plugins/copilot.lua
return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'VeryLazy',
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = '<C-l>', -- Accept Copilot suggestion
        -- You can add more keymaps if needed:
        -- next = "<M-]>",
        -- prev = "<M-[>",
        -- dismiss = "<C-]>",
      },
    },
    panel = {
      enabled = false,
    },
    filetypes = {
      yaml = false,
      markdown = false,
      gitcommit = false,
      text = true,
    },
  },
  config = function(_, opts)
    local ok, copilot = pcall(require, 'copilot')
    if not ok then
      vim.notify('Copilot plugin is not installed!', vim.log.levels.ERROR)
      return
    end
    copilot.setup(opts)
  end,
}
