return {
  'Mohammed-Taher/AdvancedNewFile.nvim',
  config = function()
    vim.keymap.set("n", "<leader>hn", "<cmd>AdvancedNewFile<CR>", { desc = "Creates a new file"})
  end
}
