return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required by nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Debug adapter management
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Go debugging support
    'leoluz/nvim-dap-go',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start or continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step out',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set conditional breakpoint',
    },
    {
      '<leader>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle DAP UI',
    },
    {
      '<leader>dr',
      function()
        require('dap').repl.open()
      end,
      desc = 'Debug: Open REPL',
    },
    {
      '<leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'Debug: Run last session',
    },
    {
      '<leader>dt',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: Terminate session',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'delve',
        'debugpy',
      },
    }

    dapui.setup {
      icons = {
        expanded = '▾',
        collapsed = '▸',
        current_frame = '*',
      },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Open and close DAP UI automatically with debug sessions.
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Go debugging support through delve.
    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- Python debugging support through debugpy.
    dap.adapters.python = {
      type = 'executable',
      command = vim.fn.expand '~/.local/share/nvim/python/venv/bin/python',
      args = {
        '-m',
        'debugpy.adapter',
      },
    }

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch current file',
        program = '${file}',
        pythonPath = function()
          local cwd = vim.fn.getcwd()
          local project_venv = cwd .. '/.venv/bin/python'

          if vim.fn.executable(project_venv) == 1 then
            return project_venv
          end

          return vim.fn.expand '~/.local/share/nvim/python/venv/bin/python'
        end,
      },
    }
  end,
}
