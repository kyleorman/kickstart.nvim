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
      return
    end

    if vim.fn.executable 'node' ~= 1 then
      vim.notify_once('[copilot] Node.js not found in PATH. Copilot disabled.', vim.log.levels.INFO)
      return
    end

    local setup_ok, err = pcall(copilot.setup, opts)
    if not setup_ok then
      vim.notify_once('[copilot] Setup failed: ' .. tostring(err), vim.log.levels.WARN)
    end
  end,
}
