-- lua/custom/plugins/sv-snippets.lua
return {
  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = 'v2.*',
    build = 'make install_js',
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_lua').lazy_load { paths = { './lua/custom/snippets' } }
    end,
  },
}
