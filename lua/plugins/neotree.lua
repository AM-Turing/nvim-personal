return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',

    -- Optional image support for preview windows.
    -- Remove this dependency if image.nvim causes issues in a VM or terminal-only setup.
    '3rd/image.nvim',
  },
  config = function()
    require('neo-tree').setup {
      close_if_last_window = false,
      popup_border_style = 'rounded',
      enable_git_status = true,
      enable_diagnostics = true,

      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = false,
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },

      window = {
        position = 'left',
        width = 35,
        mappings = {
          ['<space>'] = 'none',
          ['o'] = 'open',
          ['<cr>'] = 'open',
          ['s'] = 'open_split',
          ['v'] = 'open_vsplit',
          ['t'] = 'open_tabnew',
          ['C'] = 'close_node',
          ['z'] = 'close_all_nodes',
          ['R'] = 'refresh',
          ['a'] = {
            'add',
            config = {
              show_path = 'relative',
            },
          },
          ['d'] = 'delete',
          ['r'] = 'rename',
          ['y'] = 'copy_to_clipboard',
          ['x'] = 'cut_to_clipboard',
          ['p'] = 'paste_from_clipboard',
          ['q'] = 'close_window',
        },
      },
    }
  end,
}
