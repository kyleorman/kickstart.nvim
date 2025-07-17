-- lua/custom/plugins/cmp.lua
return {
  'hrsh7th/nvim-cmp',
  -- This dependency list is complete and correct
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'saadparwaiz1/cmp_luasnip',
  },
  -- We use config() for full control over the setup process
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    cmp.setup {
      -- The sources list is correct
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
      }, {
        { name = 'buffer' },
      }),

      -- Define all keymaps EXCEPT the Enter key here
      mapping = {
        ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
        ['<C-j>'] = cmp.mapping.select_next_item({ behavior = 'select' }),
        ['<C-Space>'] = cmp.mapping.complete(),

        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          -- ✅ THIS IS THE FIX: Check that fallback is a function before calling it
          elseif type(fallback) == 'function' then
            fallback()
          end
        end, { 'i', 's' }),

        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          -- ✅ THIS IS THE FIX: Check that fallback is a function before calling it
          elseif type(fallback) == 'function' then
            fallback()
          end
        end, { 'i', 's' }),
      },
    }

    -- Force the Enter key mapping using Neovim's core API
    vim.keymap.set('i', '<CR>', cmp.mapping.confirm { select = true })
  end,
}
