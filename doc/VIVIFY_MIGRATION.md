# Vivify Migration Notes

## Why switch

`markdown-preview.nvim` is removed from this configuration and replaced with Vivify.

Vivify is a standalone browser-based viewer. The Neovim plugin is only the editor integration layer.

Vivify binaries expected in PATH:

```text
viv
vivify-server
```

You said both are installed in:

```text
~/.local/bin/
```

Verify:

```bash
which viv
which vivify-server
viv --help
vivify-server --help
```

## File changes

### 1. Remove old Markdown Preview plugin file

```bash
rm -f ~/.config/nvim/lua/plugins/markdown-preview.lua
```

### 2. Add Vivify plugin file

Place `vivify.lua` at:

```text
~/.config/nvim/lua/plugins/vivify.lua
```

### 3. Remove old plugin checkout

```bash
rm -rf ~/.local/share/nvim/lazy/markdown-preview.nvim
rm -rf ~/.cache/nvim
rm -rf ~/.local/state/nvim
```

### 4. Sync plugins

```bash
nvim --headless "+Lazy sync" +qa
```

## Keymap

Add this to `lua/vim-options.lua` after your `map()` helper is defined:

```lua
map('n', '<leader>mp', '<cmd>Vivify<CR>', 'Open Vivify Markdown preview')
```

## Health check

Update `lua/health.lua`:

1. Add the `check_vivify()` function from `health-vivify-snippet.lua`.
2. Call it inside `M.check()` near your other external tool checks:

```lua
check_vivify()
```

## Test

```bash
nvim README.md
```

Inside Neovim:

```vim
:set filetype?
:Vivify
:messages
```

Expected:

```text
filetype=markdown
```

If Vivify does not open a browser automatically, check `:messages` and make sure the VM has browser access or copy any displayed URL into a browser.
