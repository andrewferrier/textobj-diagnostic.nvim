# textobj-diagnostic.nvim

This NeoVim plugin provides a standard Vim text object for NeoVim diagnostics
(such as those produced by the [LSP](https://neovim.io/doc/user/lsp.html),
[null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim), etc.). It enables
the user to type commands like `cig` to jump to the next diagnostic,
delete the highlighted text, and enter insert mode.

## Installation

**Requires NeoVim 0.7+.**

This is a standard NeoVim plugin.

Example for `packer.nvim`:

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

By default, the keymapping `ig` is defined as an operator-pending and visual
keymapping for the next diagnostic after the cursor position. Examples of use:

*   `cig` - jump to the next diagnostic and CHANGE it (delete the text and enter
    insert mode)

*   `vig` - visually select the next diagnostic

If you don't like this keymapping, or want to control which diagnostics are
selected, you can disable the default keymapping:

```lua
use({
    "andrewferrier/textobj-diagnostic.nvim",
    config = function()
        require("textobj-diagnostic").setup({create_default_keymaps = false})
    end,
})
```

Then, you can map your own. Any key/value you pass into the second parameter of
`diagnostic_textobj` is passed to
[`vim.diagnostic.get`](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.get\(\)),
which means it can be used to control the namespace or severity of the errors
being selected. For example:

```lua
local td = require("textobj-diagnostic")

vim.keymap.set(
    "x",
    "ig",
    ":<C-U>lua _G.diagnostic_textobj({ severity = { "
        .. "min = vim.diagnostic.severity.WARN, "
        .. "max = vim.diagnostic.severity.ERROR }})<CR>",
    { silent = true }
)

vim.keymap.set(
    "o",
    "ig",
    ":<C-U>lua _G.diagnostic_textobj({ severity = { "
        .. "min = vim.diagnostic.severity.WARN, "
        .. "max = vim.diagnostic.severity.ERROR }})<CR>",
    { silent = true }
)
```

## Limitations

Note that for now you have to use a VimL callout to Lua in your custom keymaps
in order for visual selection to work. [I'm investigating
why](https://github.com/andrewferrier/textobj-diagnostic.nvim/issues/4).

For now, this plugin only supports finding the *next* diagnostic after the
cursor position. If there is interest in extending this capability to find
*previous* diagnostics (i.e. searching backwards), please [open an
issue](https://github.com/andrewferrier/textobj-diagnostic.nvim/issues/new).
