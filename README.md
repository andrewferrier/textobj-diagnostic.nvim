# textobj-diagnostic.nvim

**⚠️  NO LONGER ACTIVELY DEVELOPED: This plugin is now archived; personally I have
replaced it with [this
plugin](https://github.com/chrisgrieser/nvim-various-textobjs).**

This NeoVim plugin provides a standard Vim text object for NeoVim diagnostics
(such as those produced by the [LSP](https://neovim.io/doc/user/lsp.html),
[null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim), etc.). It enables
the user to type commands like `cig` to jump to the next diagnostic,
delete the highlighted text, and enter insert mode.

## Demo

![Demo Video](https://user-images.githubusercontent.com/107015/184540175-d40871db-aed7-4990-9a2f-546570cbe008.gif)

## Installation

**Requires NeoVim 0.7+.**

This is a standard NeoVim plugin.

Example for [`packer.nvim`](https://github.com/wbthomason/packer.nvim):

```lua
packer.startup(function(use)

    ...

    use({
        "andrewferrier/textobj-diagnostic.nvim",
        config = function()
            require("textobj-diagnostic").setup()
        end,
    })

    ...

end)
```

## Mappings

By default, the following keymappings are defined in the operator-pending and
visual modes (as well as other functions not mapped to keys by default):

| keymapping            | function                                              | purpose                                                                                                                       |
| -                     | -                                                     | -                                                                                                                             |
| `ig`                  | `require('textobj-diagnostic').next_diag_inclusive()` | finds the diagnostic under or after the cursor (including any diagnostic the cursor is sitting on)                            |
| `]g`                  | `require('textobj-diagnostic').next_diag()`           | finds the diagnostic after the cursor (excluding any diagnostic the cursor is sitting on)                                     |
| `[g`                  | `require('textobj-diagnostic').prev_diag()`           | finds the diagnostic before the cursor (excluding any diagnostic the cursor is sitting on)                                    |
| No mapping by default | `require('textobj-diagnostic').nearest_diag()`        | find the diagnostic nearest to the cursor, under, before, or after, taking into account both vertical and horizontal distance |

Examples of use:

*   `cig` - jump to the next diagnostic (or the one under the cursor) and CHANGE
    it (delete the text and enter insert mode)

*   `v[g` - visually select the previous diagnostic

*   `d]g` - delete the next diagnostic text (excluding any diagnostic under the
    cursor)

If you don't like the default keymappings in the table above, or want to limit
which diagnostics are selected by them, you can disable the default keymappings:

```lua
use({
    "andrewferrier/textobj-diagnostic.nvim",
    config = function()
        require("textobj-diagnostic").setup({create_default_keymaps = false})
    end,
})
```

Then, you can map your own. (note: the previous restrictions around using VimL
here rather than Lua have been resolved). For example, to create a keymapping
for the diagnostic item under the cursor (or the next one) of `id`:

```lua
vim.keymap.set({ "x", "o" }, "id", function()
    require("textobj-diagnostic").next_diag_inclusive()
end, { silent = true })
```

To map to the next diagnostic item after the cursor (excluding where the cursor
is):

```lua
vim.keymap.set({ "x", "o" }, "]d", function()
    require("textobj-diagnostic").next_diag()
end, { silent = true })
```

Any key/value you pass into the first parameter of any of the functions is
passed to
[`vim.diagnostic.get`](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.get\(\)),
which means it can be used to control the namespace or severity of the errors
being selected. For example:

```lua
vim.keymap.set({ "x", "o" }, "ig", function()
    require("textobj-diagnostic").next_diag_inclusive({
        severity = {
            min = vim.diagnostic.severity.WARN,
            max = vim.diagnostic.severity.ERROR,
        },
    })
end, { silent = true })
```
