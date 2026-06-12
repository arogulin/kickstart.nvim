-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  filesystem = {
    filtered_items = {
      visible = true, -- show filtered (hidden) items by default rather than dimming them out
      hide_dotfiles = false, -- show .dotfiles
      hide_gitignored = false, -- show gitignored files too
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
