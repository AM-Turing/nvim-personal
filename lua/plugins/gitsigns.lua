return {
  'lewis6991/gitsigns.nvim',
  event = {
    'BufReadPre',
    'BufNewFile',
  },
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require 'gitsigns'

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
          buffer = bufnr,
          desc = desc,
        })
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
          return
        end

        gitsigns.nav_hunk 'next'
      end, 'Git: Jump to next change')

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
          return
        end

        gitsigns.nav_hunk 'prev'
      end, 'Git: Jump to previous change')

      -- Hunk actions
      map('n', '<leader>gs', gitsigns.stage_hunk, 'Git: Stage hunk')
      map('n', '<leader>gr', gitsigns.reset_hunk, 'Git: Reset hunk')
      map('v', '<leader>gs', function()
        gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Git: Stage selected hunk')
      map('v', '<leader>gr', function()
        gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Git: Reset selected hunk')

      -- Buffer actions
      map('n', '<leader>gS', gitsigns.stage_buffer, 'Git: Stage buffer')
      map('n', '<leader>gR', gitsigns.reset_buffer, 'Git: Reset buffer')
      map('n', '<leader>gu', gitsigns.undo_stage_hunk, 'Git: Undo stage hunk')

      -- Preview / blame / diff
      map('n', '<leader>gp', gitsigns.preview_hunk, 'Git: Preview hunk')
      map('n', '<leader>gb', gitsigns.blame_line, 'Git: Blame line')
      map('n', '<leader>gd', gitsigns.diffthis, 'Git: Diff against index')
      map('n', '<leader>gD', function()
        gitsigns.diffthis '@'
      end, 'Git: Diff against last commit')

      -- Toggles
      map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, 'Git: Toggle current line blame')
      map('n', '<leader>gtd', gitsigns.toggle_deleted, 'Git: Toggle deleted lines')
    end,
  },
}
