-- :Zfmt - save the current file and format it with the `zfmt` CLI, then reload.
-- (User commands must start with an uppercase letter, so this is :Zfmt, not :zfmt.)

vim.api.nvim_create_user_command('Zfmt', function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('Zfmt: current buffer has no file name', vim.log.levels.ERROR)
    return
  end

  -- Save first (no-op if unmodified) so zfmt formats the on-disk contents.
  vim.cmd 'silent noautocmd update'

  local result = vim.system({ 'zfmt', file }, { text = true }):wait()
  if result.code ~= 0 then
    local msg = (result.stderr or '') .. (result.stdout or '')
    vim.notify('zfmt failed (exit ' .. result.code .. '):\n' .. msg, vim.log.levels.ERROR)
    return
  end

  -- zfmt edits in place; reload the buffer to pick up the formatting.
  vim.cmd 'edit'
  vim.notify('Zfmt: formatted ' .. vim.fn.fnamemodify(file, ':t'))
end, { desc = 'Save and run zfmt on the current file' })

vim.keymap.set('n', '<leader>zf', '<Cmd>Zfmt<CR>', { desc = '[Z]fmt current file' })
