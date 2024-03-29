local M = {}

local opts

local function select_diagnostic(diagnostic)
    if diagnostic ~= nil then
        local mode = vim.fn.mode():lower()

        if mode:find("^v") or mode:find("^ctrl-v") then
            vim.cmd("normal! v")
        end

        vim.fn.setcursorcharpos(diagnostic.lnum + 1, diagnostic.col + 1)
        vim.cmd("normal! v")
        vim.fn.setcursorcharpos(diagnostic.end_lnum + 1, diagnostic.end_col)
    end
end

local function sort_diagnostics(diagnostics)
    local copy = vim.deepcopy(diagnostics)

    table.sort(copy, function(a, b)
        if a.lnum < b.lnum then
            return true
        elseif a.lnum > b.lnum then
            return false
        elseif a.col < b.col then
            return true
        else
            return false
        end
    end)

    return copy
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
    local diagnostics =
        sort_diagnostics(vim.diagnostic.get(0, local_opts or {}))

    if vim.tbl_count(diagnostics) == 0 then
        return
    end

    local current_line = vim.fn.line(".")
    local current_column = vim.fn.getpos(".")[3]

    -- If none match, default to the first in the buffer as it means our cursor
    -- is further out than any of the existing diagnostics, so 'wrap'.
    local closest = diagnostics[1]

    for i = #diagnostics, 1, -1 do
        local v = diagnostics[i]

        if v.lnum + 1 >= current_line then
            if v.lnum + 1 == current_line then
                if v.end_col >= current_column then
                    closest = v
                end
            else
                closest = v
            end
        end
    end

    select_diagnostic(closest)
end

M.nearest_diag = function(local_opts)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor[1] - 1
    local current_column = cursor[2]
    local ext_opts = local_opts or {}
    local next = vim.diagnostic.get_next(ext_opts)

    if next == nil then
        return
    end

    ext_opts.cursor_position = { next.lnum + 1, next.col }

    local prev = vim.diagnostic.get_prev(ext_opts)
    local select_nearest = prev

    if
        math.abs(next.lnum - current_line) == math.abs(prev.lnum - current_line)
    then
        if
            math.abs(next.col - current_column)
            < math.abs(prev.col - current_column)
        then
            select_nearest = next
        end
    elseif
        math.abs(next.lnum - current_line) < math.abs(prev.lnum - current_line)
    then
        select_nearest = next
    end

    select_diagnostic(select_nearest)
end

M.next_diag = function(local_opts)
    select_diagnostic(vim.diagnostic.get_next(local_opts))
end

M.prev_diag = function(local_opts)
    select_diagnostic(vim.diagnostic.get_prev(local_opts))
end

M.setup = function(o)
    opts =
        vim.tbl_deep_extend("force", { create_default_keymaps = true }, o or {})

    vim.validate({
        create_default_keymaps = { opts.create_default_keymaps, "boolean" },
    })

    if opts.create_default_keymaps then
        vim.keymap.set({ "x", "o" }, "ig", function()
            M.next_diag_inclusive()
        end, {
            silent = true,
        })

        vim.keymap.set({ "x", "o" }, "]g", function()
            M.next_diag()
        end, {
            silent = true,
        })

        vim.keymap.set({ "x", "o" }, "[g", function()
            M.prev_diag()
        end, {
            silent = true,
        })
    end
end

return M
