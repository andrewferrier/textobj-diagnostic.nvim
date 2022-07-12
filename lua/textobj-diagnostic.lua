local M = {}

local opts

local function select_diagnostic(diagnostic)
    vim.fn.setcursorcharpos(diagnostic.lnum + 1, diagnostic.col + 1)
    vim.cmd("normal! v")
    vim.fn.setcursorcharpos(diagnostic.end_lnum + 1, diagnostic.end_col)
end

_G.diagnostic_textobj = function(local_opts)
    vim.notify(
        "_G.diagnostic_textobj() is deprecated, "
            .. "please use require('textobj-diagnostic').next_diag_inclusive() instead.",
        vim.log.levels.WARN
    )

    M.next_diag_inclusive(local_opts)
end

M.next_diag_inclusive = function(local_opts)
    local diagnostics = vim.diagnostic.get(0, local_opts or {})

    if vim.tbl_count(diagnostics) == 0 then
        return
    end

    local current_line = vim.fn.line(".")
    local current_column = vim.fn.getpos(".")[3]

    local closest_so_far = nil

    for _, v in pairs(diagnostics) do
        if
            (
                closest_so_far == nil
                or (v.lnum + 1 < closest_so_far.lnum + 1)
                or (
                    (v.lnum + 1 == closest_so_far.lnum + 1)
                    and (v.col + 1 < closest_so_far.col + 1)
                )
            )
            and (
                v.lnum + 1 > current_line
                or (v.lnum + 1 == current_line and v.end_col >= current_column)
            )
        then
            closest_so_far = v
        end
    end

    if closest_so_far == nil then
        closest_so_far = diagnostics[1]
    end

    select_diagnostic(closest_so_far)
end

M.next_diag = function(local_opts)
    local next = vim.diagnostic.get_next(local_opts)

    if next ~= nil then
        select_diagnostic(next)
    end
end

M.prev_diag = function(local_opts)
    local prev = vim.diagnostic.get_prev(local_opts)

    if prev ~= nil then
        select_diagnostic(prev)
    end
end

M.setup = function(o)
    opts =
        vim.tbl_deep_extend("force", { create_default_keymaps = true }, o or {})

    if opts.create_default_keymaps then
        vim.keymap.set(
            { "x", "o" },
            "ig",
            ":<C-U>lua require('textobj-diagnostic').next_diag_inclusive()<CR>",
            { silent = true }
        )

        vim.keymap.set(
            { "x", "o" },
            "]g",
            ":<C-U>lua require('textobj-diagnostic').next_diag()<CR>",
            { silent = true }
        )

        vim.keymap.set(
            { "x", "o" },
            "[g",
            ":<C-U>lua require('textobj-diagnostic').prev_diag()<CR>",
            { silent = true }
        )
    end
end

return M
