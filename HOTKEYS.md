# Neovim Hotkeys Quick Reference

This document lists the custom hotkeys configured in this Neovim setup.

Leader key:

```text
<leader> = Space
```

Example:

```text
<leader>f = Space, then f
```

Leader mappings only trigger in the mode where they are defined. They do not trigger while typing normal text in insert mode.

---

## General / LSP

Managed in:

```text
lua/vim-options.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<C-n>` | Normal | Reveal current file in Neo-tree |
| `<C-k>` | Normal | Show LSP hover documentation |
| `<C-d>` | Normal | Go to LSP definition |
| `<C-a>` | Normal / Visual | Show LSP code actions |

---

## Config Health

Managed in:

```text
lua/health.lua
lua/vim-options.lua
```

| Command | Action |
|---|---|
| `:ConfigHealth` | Run custom Neovim environment health check |
| `:lua require('health').check()` | Run custom health check manually |

No hotkey is currently assigned.

---

## Formatting

Managed in:

```text
lua/plugins/formatting.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<leader>f` | Normal / Visual | Format current file or selected range with conform.nvim |

---

## Linting

Managed in:

```text
lua/plugins/linting.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<leader>l` | Normal | Trigger linting for current file |

Automatic linting also runs on:

```text
BufEnter
BufWritePost
InsertLeave
```

---

## Telescope

Managed in:

```text
lua/plugins/telescope.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<C-p>` | Normal | Find files |
| `<C-g>` | Normal | Live grep |
| `<C-b>` | Normal | List open buffers |
| `<C-h>` | Normal | Search help tags |

Related commands:

```vim
:Telescope find_files
:Telescope live_grep
:Telescope buffers
:Telescope help_tags
```

---

## Markdown Preview

Managed in:

```text
lua/plugins/markdown-preview.lua
lua/vim-options.lua
```

Recommended mappings:

| Key | Mode | Action |
|---|---:|---|
| `<leader>ms` | Normal | Start Markdown Preview |
| `<leader>mx` | Normal | Stop Markdown Preview |
| `<leader>mp` | Normal | Toggle Markdown Preview |

Related commands:

```vim
:MarkdownPreview
:MarkdownPreviewStop
:MarkdownPreviewToggle
```

---

## Neo-tree

Managed in:

```text
lua/plugins/neotree.lua
lua/vim-options.lua
```

### Global Mapping

| Key | Mode | Action |
|---|---:|---|
| `<C-n>` | Normal | Reveal current file in Neo-tree |

### Neo-tree Window Mappings

These apply while the Neo-tree window is focused.

| Key | Action |
|---|---|
| `o` | Open file or directory |
| `<Enter>` | Open file or directory |
| `s` | Open in horizontal split |
| `v` | Open in vertical split |
| `t` | Open in new tab |
| `C` | Close node |
| `z` | Close all nodes |
| `R` | Refresh |
| `a` | Add file or directory |
| `d` | Delete |
| `r` | Rename |
| `y` | Copy to clipboard |
| `x` | Cut to clipboard |
| `p` | Paste from clipboard |
| `q` | Close Neo-tree window |

---

## Debugging / DAP

Managed in:

```text
lua/plugins/debug.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<F5>` | Normal | Debug start / continue |
| `<F1>` | Normal | Debug step into |
| `<F2>` | Normal | Debug step over |
| `<F3>` | Normal | Debug step out |
| `<leader>db` | Normal | Toggle breakpoint |
| `<leader>dB` | Normal | Set conditional breakpoint |
| `<leader>du` | Normal | Toggle DAP UI |
| `<leader>dr` | Normal | Open DAP REPL |
| `<leader>dl` | Normal | Run last debug session |
| `<leader>dt` | Normal | Terminate debug session |

---

## Git / Gitsigns

Managed in:

```text
lua/plugins/gitsigns.lua
```

| Key | Mode | Action |
|---|---:|---|
| `]c` | Normal | Jump to next Git change |
| `[c` | Normal | Jump to previous Git change |
| `<leader>gs` | Normal | Stage current hunk |
| `<leader>gr` | Normal | Reset current hunk |
| `<leader>gs` | Visual | Stage selected hunk |
| `<leader>gr` | Visual | Reset selected hunk |
| `<leader>gS` | Normal | Stage entire buffer |
| `<leader>gR` | Normal | Reset entire buffer |
| `<leader>gu` | Normal | Undo staged hunk |
| `<leader>gp` | Normal | Preview hunk |
| `<leader>gb` | Normal | Blame current line |
| `<leader>gd` | Normal | Diff against index |
| `<leader>gD` | Normal | Diff against last commit |
| `<leader>gtb` | Normal | Toggle current-line blame |
| `<leader>gtd` | Normal | Toggle deleted lines |

---

## Treesitter Textobjects

Managed in:

```text
lua/plugins/treesitter.lua
```

### Selection

Use these in visual or operator-pending mode.

| Key | Mode | Action |
|---|---:|---|
| `af` | Visual / Operator-pending | Select outer function |
| `if` | Visual / Operator-pending | Select inner function |
| `ac` | Visual / Operator-pending | Select outer class |
| `ic` | Visual / Operator-pending | Select inner class |
| `aa` | Visual / Operator-pending | Select outer parameter |
| `ia` | Visual / Operator-pending | Select inner parameter |

### Movement

Use these in normal mode.

| Key | Mode | Action |
|---|---:|---|
| `]f` | Normal | Go to next function start |
| `]F` | Normal | Go to next function end |
| `[f` | Normal | Go to previous function start |
| `[F` | Normal | Go to previous function end |
| `]c` | Normal | Go to next class start |
| `]C` | Normal | Go to next class end |
| `[c` | Normal | Go to previous class start |
| `[C` | Normal | Go to previous class end |

Note: `]c` and `[c` may overlap conceptually with Gitsigns Git-change navigation. In Git-tracked files, Gitsigns may take precedence.

---

## Autopairs

Managed in:

```text
lua/plugins/autopairs.lua
```

No hotkeys.

Behavior:

```text
(  ->  ()
[  ->  []
{  ->  {}
"  ->  ""
'  ->  ''
```

Also integrates with `nvim-cmp` completion confirmation.

---

## Indent Guides

Managed in:

```text
lua/plugins/indent_line.lua
```

No hotkeys.

Behavior:

```text
Adds indentation guides in code buffers.
Excludes dashboard, Neo-tree, Lazy, Mason, and similar plugin windows.
```

---

## Dashboard

Managed in:

```text
lua/plugins/dashboard.lua
```

No custom hotkeys.

---

## Lualine

Managed in:

```text
lua/plugins/lualine.lua
```

No custom hotkeys.

---

## Nightfox

Managed in:

```text
lua/plugins/nightfox.lua
```

No custom hotkeys.

---

## Completion / Snippets

Managed in:

```text
lua/plugins/completions.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<C-b>` | Insert | Scroll completion documentation up |
| `<C-f>` | Insert | Scroll completion documentation down |
| `<C-Space>` | Insert | Trigger completion menu |
| `<C-e>` | Insert | Abort completion |
| `<Enter>` | Insert | Confirm selected completion |
| `<Tab>` | Insert / Select | Next completion item or jump forward in snippet |
| `<S-Tab>` | Insert / Select | Previous completion item or jump backward in snippet |

---

## Quick Test List

After setup, quickly test:

| Key | Expected Result |
|---|---|
| `<C-p>` | Telescope file picker opens |
| `<C-g>` | Telescope live grep opens |
| `<C-n>` | Neo-tree reveals current file |
| `<leader>f` | File formats |
| `<leader>l` | File lints |
| `<leader>db` | Debug breakpoint toggles |
| `<leader>gs` | Git hunk stages |
| `<leader>mp` | Markdown preview toggles |
