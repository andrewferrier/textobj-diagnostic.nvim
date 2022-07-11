local M = {}

local opts

_G.diagnostic_textobj = function(local_opts)
    local diagnostics = vim.diagnostic.get(0, local_opts or {})

    if vim.tbl_count(diagnostics) == 0 then
        return
    end

    local current_line = vim.fn.line(".")
    local current_column = vim.fn.getpos(".")[3]

    local closest_so_far = nil

    for _, v in pairs(diagnostics) do
        if
            (closest_so_far == nil or v.lnum + 1 < closest_so_far.lnum + 1)
            and v.lnum + 1 >= current_line
        then
            closest_so_far = v
        end
    end

    if closest_so_far == nil then
        closest_so_far = diagnostics[1]
    end

    vim.fn.setcursorcharpos(closest_so_far.lnum + 1, closest_so_far.col + 1)
    vim.cmd('normal! v')
    vim.fn.setcursorcharpos(closest_so_far.end_lnum + 1, closest_so_far.end_col)
end

M.setup = function(o)
    opts =
        vim.tbl_deep_extend("force", { create_default_keymaps = true }, o or {})

    if opts.create_default_keymaps then
        for _, mode in ipairs({ "x", "o" }) do
            vim.keymap.set(
                mode,
                "ig",
                ":<C-U>lua _G.diagnostic_textobj()<CR>",
                { silent = true }
            )
        end
    end
end

return M
