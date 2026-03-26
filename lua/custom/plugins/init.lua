vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = '[Y]ank to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = '[P]aste from clipboard' })

-- Sourcing helpers
vim.keymap.set('n', '<leader>xf', '<cmd>source %<CR>', { desc = 'Source [F]ile' })
vim.keymap.set('n', '<leader>xx', ':.lua<CR>', { desc = 'Source current line' })
vim.keymap.set('v', '<leader>x', ':lua<CR>', { desc = 'Source lines' })

-- Delete word backward insert mode
vim.keymap.set('i', '<C-H>', '<C-W>', { desc = 'Delete backward insert mode' })

-- Telescope
local function git_status_select_current()
  local builtin = require 'telescope.builtin'
  local utils = require 'telescope.utils'
  -- Get git root
  local git_root, ret = utils.get_os_command_output { 'git', 'rev-parse', '--show-toplevel' }
  if ret ~= 0 or not git_root[1] then
    builtin.git_status()
    return
  end
  -- Get current buffer path relative to git root
  local bufpath = vim.fn.expand '%:p'
  local relpath = vim.fn.fnamemodify(bufpath, ':.' .. git_root[1])
  -- More reliable: use a plain relative path calculation
  local root = git_root[1] .. '/'
  if bufpath:sub(1, #root) == root then
    relpath = bufpath:sub(#root + 1)
  end
  -- Get git status output (same order telescope will show)
  local status_files, ret2 = utils.get_os_command_output({ 'git', 'status', '-s', '--porcelain=v1' }, git_root[1])
  local idx = nil
  if ret2 == 0 then
    for i, line in ipairs(status_files) do
      -- porcelain format: "XY filename" (3-char prefix)
      local file = line:sub(4)
      -- Handle renames: "XY old -> new"
      local arrow = file:find ' -> '
      if arrow then
        file = file:sub(arrow + 4)
      end
      if file == relpath then
        idx = i
        break
      end
    end
  end
  builtin.git_status {
    default_selection_index = idx or 1,
  }
end

vim.keymap.set('n', '<leader>ss', git_status_select_current, { desc = '[S]earch Git[S]tatus' })

return {}
