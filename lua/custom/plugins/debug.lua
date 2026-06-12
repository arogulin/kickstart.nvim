-- nvim-dap: Debug Adapter Protocol client for Neovim.
--
-- Adapted from https://tamerlan.dev/a-guide-to-debugging-applications-in-neovim/
-- to this config's `vim.pack` setup (kickstart no longer uses lazy.nvim) and to
-- Python via mason's debugpy.
--
-- This file lives in ~/.config/nvim/lua/custom/plugins/ and is `require`d by
-- that directory's init.lua loader. Because the base config uses `vim.pack`
-- rather than lazy.nvim, it installs and configures everything imperatively
-- here instead of returning a lazy spec table.

local function gh(repo) return 'https://github.com/' .. repo end

-- `vim.pack` does not resolve dependencies, so list every repo explicitly.
-- mason-nvim-dap (used by the guide) is intentionally omitted: debugpy is
-- already installed by mason-tool-installer (see `ensure_installed` in
-- init.lua), and nvim-dap-python wires that debugpy in directly.
vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'rcarriga/nvim-dap-ui',
  gh 'nvim-neotest/nvim-nio',
  gh 'theHamsta/nvim-dap-virtual-text',
  gh 'mfussenegger/nvim-dap-python',
}

local dap = require 'dap'
local dapui = require 'dapui'

-- Inline variable values as virtual text while stepping.
require('nvim-dap-virtual-text').setup {}

dapui.setup()

-- Gutter signs. The ladybug breakpoint marker is from the guide; DapStopped
-- marks the current line and is an addition (remove if undesired).
vim.fn.sign_define('DapBreakpoint', { text = '🐞' })
vim.fn.sign_define('DapStopped', { text = '→', texthl = 'DiagnosticWarn', linehl = 'Visual' })

-- Open the UI when a session starts, close it when the session ends.
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

-- Python adapter via mason's debugpy. nvim-dap-python auto-detects the
-- project's virtualenv (.venv/venv or $VIRTUAL_ENV) for the program it debugs.
local debugpy_python = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
require('dap-python').setup(debugpy_python)

-- Label the <leader>d prefix in which-key (already set up earlier in init.lua).
require('which-key').add { { '<leader>d', group = '[D]ebug' } }

-- Keymaps, all under the <leader>d prefix (from the guide).
local function map(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end
map('<leader>dt', dap.toggle_breakpoint, 'Toggle Breakpoint')
map('<leader>dT', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, 'Conditional Breakpoint')
map('<leader>dc', dap.continue, 'Continue')
map('<leader>di', dap.step_into, 'Step Into')
map('<leader>do', dap.step_over, 'Step Over')
map('<leader>du', dap.step_out, 'Step Out')
map('<leader>dr', dap.repl.open, 'Open REPL')
map('<leader>dl', dap.run_last, 'Run Last')
map('<leader>db', dap.list_breakpoints, 'List Breakpoints')
map('<leader>de', function() dap.set_exception_breakpoints { 'all' } end, 'Exception Breakpoints')
map('<leader>dq', function()
  dap.terminate()
  dapui.close()
end, 'Terminate')
