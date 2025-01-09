return {
  {
    {
      "iamcco/markdown-preview.nvim",
      lazy = false,
      ft = "markdown",
      -- build = "cd app && yarn install",
      build = ":call mkdp#util#install()",
    },
  },
}
