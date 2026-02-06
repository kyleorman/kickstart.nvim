-- ~/.config/nvim/lua/custom/plugins/avante.lua
return {
  'yetone/avante.nvim',
  build = (vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1) and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
    or 'make BUILD_FROM_SOURCE=false',
  event = 'VeryLazy',
  version = false,
  opts = {
    provider = 'copilot',
    providers = {
      gemini = {
        -- if you’ve set AVANTE_GEMINI_API_KEY in your env, this is all you need:
        -- (Avante’s built-in gemini provider will pick up the env var automatically)
        model = 'gemini-2.5-pro',
        timeout = 30000,
      },
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-sonnet-4-20250514',
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
      moonshot = {
        endpoint = 'https://api.moonshot.ai/v1',
        model = 'kimi-k2-0711-preview',
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
        },
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'echasnovski/mini.pick',
    'nvim-telescope/telescope.nvim',
    'ibhagwan/fzf-lua',
    'stevearc/dressing.nvim',
    'folke/snacks.nvim',
    'nvim-tree/nvim-web-devicons',
    'zbirenbaum/copilot.lua',
    {
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      ft = { 'markdown', 'Avante' },
      opts = { file_types = { 'markdown', 'Avante' } },
    },
  },
}
