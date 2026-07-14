-- Diffview: a git diff / PR review view. Reads changes as a file-tree plus a
-- side-by-side diff in native nvim buffers, so jdtls stays attached and all the
-- usual LSP navigation (go-to-def, references, hover) works while reading the
-- changed Java. No commenting/approval layer; use `gh pr checkout <n>` to fetch
-- the branch, then review the diff against the merge-base.
--
-- Typical flow:
--   :Gh <n>            fetch + checkout the PR branch (see gh() cmd below)
--   <leader>gr         open the PR's diff vs its merge-base with the trunk
--   <leader>gh         browse per-file history of the current file
--   <tab> / <s-tab>    next / prev changed file within the diff view
--   <leader>gq         close the diff view
--
-- Lives in ~/.config/nvim/lua/custom/plugins/ and is `require`d by that
-- directory's init.lua loader.

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'nvim-lua/plenary.nvim', gh 'sindrets/diffview.nvim' }

require('diffview').setup {
  -- No nvim-web-devicons (have_nerd_font = false), so disable filetype glyphs
  -- to suppress the "nvim-web-devicons is required" nag and render a plain,
  -- readable file tree. ASCII fold/status signs avoid tofu boxes too.
  use_icons = false,
  signs = { fold_closed = '+', fold_open = '-', done = 'x' },
  icons = { folder_closed = '', folder_open = '' },
  enhanced_diff_hl = true,
  view = {
    -- Merge-tool style not needed; default 2-pane diff is what PR review wants.
    default = { layout = 'diff2_horizontal' },
  },
}

-- Detect the repo's trunk (main/master) so `<leader>gr` diffs the checked-out
-- PR branch against its merge-base with trunk, showing exactly the PR's changes
-- rather than every commit since branch creation.
local function trunk()
  for _, name in ipairs { 'origin/main', 'origin/master', 'main', 'master' } do
    if vim.fn.system('git rev-parse --verify --quiet ' .. name) ~= '' then return name end
  end
  return 'HEAD~1'
end

vim.keymap.set('n', '<leader>gr', function()
  vim.cmd('DiffviewOpen ' .. trunk() .. '...HEAD')
end, { desc = '[G]it: [R]eview PR diff vs trunk merge-base' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', { desc = '[G]it: file [H]istory' })
vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<cr>', { desc = '[G]it: [Q]uit diff view' })

-- :Gh <n> — checkout a GitHub PR by number via the gh CLI, into a detached
-- local branch, so `<leader>gr` can then diff it. Requires the `gh` CLI on PATH.
vim.api.nvim_create_user_command('Gh', function(opts)
  vim.cmd('!gh pr checkout ' .. opts.args)
end, { nargs = 1, desc = 'Checkout a GitHub PR by number (gh pr checkout)' })
