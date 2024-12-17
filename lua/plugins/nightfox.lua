return {
  -- Nightfox Theme
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function()
      require('nightfox').setup({
        options = {
          colorblind = {
            enable = true,
            severity = {
              protan = 0.8,
              deutan = 0.2,
              tritan = 0.0,
            }
          }
        }
      })
      vim.cmd('colorscheme nightfox')
    end
  }
}
