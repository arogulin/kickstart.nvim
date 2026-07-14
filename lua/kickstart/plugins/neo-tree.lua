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
        ['Y'] = 'copy_absolute_path',
        ['gy'] = 'copy_relative_path',
        ['yn'] = 'copy_filename',
      },
    },
  },
  commands = {
    copy_absolute_path = function(state)
      local path = state.tree:get_node():get_id()
      vim.fn.setreg('+', path)
      vim.notify('Copied: ' .. path)
    end,
    copy_relative_path = function(state)
      local path = vim.fn.fnamemodify(state.tree:get_node():get_id(), ':.')
      vim.fn.setreg('+', path)
      vim.notify('Copied: ' .. path)
    end,
    copy_filename = function(state)
      local name = state.tree:get_node().name
      vim.fn.setreg('+', name)
      vim.notify('Copied: ' .. name)
    end,
  },
}
