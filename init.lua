vim.cmd('set expandtab')
vim.cmd('set tabstop=2')
vim.cmd('set softtabstop=2')
vim.cmd('set shiftwidth=2')

-- Setup Lazy Bootloader
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	{ "EdenEast/nightfox.nvim", name = nightfox, priority = 1000 }
}
local opts = {}

require("lazy").setup(plugins, opts)
require("nightfox").setup({
  options = {
    colorblind = {
      enable = true,
      severity = {
        protan = 0.3,
        deutan = 0.3,
        tritan = 0.3,
      },
    },
  },
})
vim.cmd('colorscheme nightfox')
