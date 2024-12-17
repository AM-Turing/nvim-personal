return {
  -- Treesitter Plugin
      "nvim-treesitter/nvim-treesitter",
      build = ':TSUpdate',  -- Ensure parsers are installed
      config = function()
        require'nvim-treesitter.configs'.setup {
          ensure_installed = { "lua", "python", "javascript", "go", "c", "html", "css", "rust", "zig", "typescript", "json", "bash" },  -- Install wanted parsers
          sync_install = false,  -- Install parsers synchronously (recommended: false)
          auto_install = true,  -- Automatically install missing parsers
          highlight = {
            enable = true,  -- Enable Tree-sitter highlighting
            additional_vim_regex_highlighting = false,  -- Disable regex highlighting (recommended)
          },
          indent = {
            enable = true,  -- Enable Tree-sitter indentation
          },
          textobjects = {
            enable = true,  -- Enable text objects for navigating code
            select = {
              enable = true,
              lookahead = true,  -- Automatically jump to text objects
            },
          },
        }
        -- Optional: You can manually enable Tree-sitter features for specific languages
        -- require'nvim-treesitter.install'.prefer_git = true  -- Prefer GitHub over the official repository for faster parser installation
    end
}
 
