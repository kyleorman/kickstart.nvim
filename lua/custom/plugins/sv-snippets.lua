-- lua/custom/plugins/sv-snippets.lua
-- Loads friendly-snippets (VSCode snippets) and custom Lua snippets into
-- the LuaSnip instance that blink.cmp already manages in init.lua.
--
-- We do NOT re-declare L3MON4D3/LuaSnip here to avoid conflicting with
-- the spec in init.lua (under blink.cmp dependencies).

return {
  'rafamadriz/friendly-snippets',
  config = function()
    -- Load VSCode-style snippets from friendly-snippets
    require('luasnip.loaders.from_vscode').lazy_load()
    -- Load custom Lua snippets (create files in lua/custom/snippets/)
    require('luasnip.loaders.from_lua').lazy_load { paths = { './lua/custom/snippets' } }
  end,
}
