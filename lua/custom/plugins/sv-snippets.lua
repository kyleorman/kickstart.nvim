-- lua/custom/plugins/sv-snippets.lua
-- Adds friendly-snippets and custom Lua snippets to the LuaSnip instance
-- already declared by blink.cmp in init.lua.
--
-- NOTE: We do NOT re-declare L3MON4D3/LuaSnip here. Instead we add
-- friendly-snippets as a dependency and use opts to merge configuration.
-- The actual LuaSnip plugin spec (version, build) lives in init.lua under blink.cmp.

return {
  -- Add friendly-snippets and load them into LuaSnip
  {
    'rafamadriz/friendly-snippets',
    lazy = true,
  },
  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function()
      -- Load VSCode-style snippets from friendly-snippets
      require('luasnip.loaders.from_vscode').lazy_load()
      -- Load custom Lua snippets (create files in lua/custom/snippets/)
      require('luasnip.loaders.from_lua').lazy_load { paths = { './lua/custom/snippets' } }
    end,
  },
}
