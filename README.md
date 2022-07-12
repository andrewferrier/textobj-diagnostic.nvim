# textobj-diagnostic.nvim

This NeoVim plugin provides a standard Vim text object for NeoVim diagnostics
(such as those produced by the [LSP](https://neovim.io/doc/user/lsp.html),
[null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim), etc.). It enables
the user to type commands like `cig` to jump to the next diagnostic,
delete the highlighted text, and enter insert mode.

## Demo

![](demos/demo1.mkv)

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

By default, the following keymappings are defined in the operator-pending and visual modes:

| keymapping | function                                              | purpose                                                                                            |
| -          | -                                                     | -                                                                                                  |
| `ig`       | `require('textobj-diagnostic').next_diag_inclusive()` | finds the diagnostic under or after the cursor (including any diagnostic the cursor is sitting on) |
| `]g`       | `require('textobj-diagnostic').next_diag()`           | finds the diagnostic after the cursor (excluding any diagnostic the cursor is sitting on)          |
| `[g`       | `require('textobj-diagnostic').prev_diag()`           | finds the diagnostic before the cursor (excluding any diagnostic the cursor is sitting on)         |

Examples of use:

*   `cig` - jump to the next diagnostic (or the one under the cursor) and CHANGE
    it (delete the text and enter insert mode)

*   `v[g` - visually select the previous diagnostic

*   `d]g` - delete the next diagnostic text (excluding any diagnostic under the
    cursor)

If you don't like these keymappings, or want to control which diagnostics are
selected, you can disable the default keymappings:

```lua
use({
    "andrewferrier/textobj-diagnostic.nvim",
    config = function()
        require("textobj-diagnostic").setup({create_default_keymaps = false})
    end,
})
```

Then, you can map your own. (**IMPORTANT NOTE**: For now, this has to be done as Lua embedded in VimL. [I'm investigating
why](https://github.com/andrewferrier/textobj-diagnostic.nvim/issues/4)). For example, to create a keymapping for the
diagnostic item under the cursor (or the next one) of `id`:

```lua
vim.keymap.set(
    { "x", "o" },
    "id",
    ":<C-U>lua require('textobj-diagnostic').next_diag_inclusive()<CR>",
    { silent = true }
)
```

To map to the next diagnostic item after the cursor (excluding where the cursor
is):

```lua
vim.keymap.set(
    { "x", "o" },
    "]d",
    ":<C-U>lua require('textobj-diagnostic').next_diag()<CR>",
    { silent = true }
)
```

Any key/value you pass into the first parameter of `next_diag_inclusive` or any
of the other functions is passed to
[`vim.diagnostic.get`](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.get\(\)),
which means it can be used to control the namespace or severity of the errors
being selected. For example:

```lua
vim.keymap.set(
    { "x", "o" },
    "ig",
    ":<C-U>lua require('textobj-diagnostic').next_diag_inclusive({ severity = { "
        .. "min = vim.diagnostic.severity.WARN, "
        .. "max = vim.diagnostic.severity.ERROR }})<CR>",
    { silent = true }
)
```

## Limitations

Note that for now you have to use a VimL callout to Lua in your custom keymaps
in order for visual selection to work. [I'm investigating
why](https://github.com/andrewferrier/textobj-diagnostic.nvim/issues/4).
