vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>', { desc = '[U]ndotree Toggle' })

return {
  'mbbill/undotree',
  lazy = false,
}
