vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = '[Y]ank to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = '[P]aste from clipboard' })

-- Sourceing helpers
vim.keymap.set('n', '<leader>xf', '<cmd>source %<CR>', { desc = 'Source [F]ile' })
vim.keymap.set('n', '<leader>xx', ':.lua<CR>', { desc = 'Source current line' })
vim.keymap.set('v', '<leader>x', ':lua<CR>', { desc = 'Source lines' })

return {}
