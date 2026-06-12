-- Extra LSP keymaps, bound buffer-locally when a language server attaches.
--
-- Lives in ~/.config/nvim/lua/custom/plugins/ and is `require`d by that
-- directory's init.lua loader. Unlike the other overrides this installs no
-- plugin; it just registers an autocmd when the module is loaded.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('custom-lsp-keymaps', { clear = true }),
  callback = function(event)
    vim.keymap.set({ 'n', 'i' }, '<C-s>', vim.lsp.buf.signature_help,
      { buffer = event.buf, desc = 'LSP: Signature Help' })
  end,
})
