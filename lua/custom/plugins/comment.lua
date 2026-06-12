-- Comment.nvim.
--
-- Kept despite Neovim 0.10+ built-in commenting: only this plugin provides
-- `gb`/`gbc` blockwise toggle, which wraps a region in a single `<!-- ... -->`
-- instead of per-line comments.
--
-- Lives in ~/.config/nvim/lua/custom/plugins/ and is `require`d by that
-- directory's init.lua loader. Because the base config uses `vim.pack` rather
-- than lazy.nvim, install and configure imperatively here instead of returning
-- a lazy spec table.

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'numToStr/Comment.nvim' }
require('Comment').setup()
