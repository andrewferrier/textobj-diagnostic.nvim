local M = {}

local opts

local function select_diagnostic(diagnostic)
    local mode = vim.fn.mode():lower()

    if mode == "v" or mode == "vs" or mode == "ctrl-v" or mode == "ctrl-vs" then
        vim.cmd("normal! v")
    end

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
    local cursor = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor[1] - 1
    local current_column = cursor[2]

    local ext_opts = local_opts or {}
    local next = vim.diagnostic.get_next(ext_opts)
    if next == nil then
        return
    end
    -- set the cursor on next diagnostic because
    -- when sitting on a diagnostic we can't get it by get_next() or get_prev()
    ext_opts.cursor_position = { next.lnum + 1, next.col }
    local prev = vim.diagnostic.get_prev(ext_opts)

    local closest = next

    if prev and current_line >= prev.lnum and current_line <= prev.end_lnum and current_column < prev.end_col then
        closest = prev
    end

    if closest ~= nil then
        select_diagnostic(closest)
    end
end

M.nearest_diag = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor[1] - 1
    local current_column = cursor[2]

    local next = vim.diagnostic.get_next({ cursor_position = { current_line, current_column } })
    local prev = vim.diagnostic.get_prev({ cursor_position = { current_line, current_column } })
    local select_nearest = function()
        if next == prev then
            return next
        end

        if math.abs(next.lnum - current_line) == math.abs(prev.lnum - current_line) then
            if math.abs(next.col - current_column) < math.abs(prev.col - current_column) then
                return next
            end
        elseif math.abs(next.lnum - current_line) < math.abs(prev.lnum - current_line) then
            return next
        end
        return prev
    end

    local closest = select_nearest()

    if closest ~= nil then
        select_diagnostic(closest)
    end
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
        vim.keymap.set({ "x", "o" }, "ig", function()
            M.next_diag_inclusive()
        end, { silent = true })

        vim.keymap.set({ "x", "o" }, "ng", function()
            M.nearest_diag()
        end, { silent = true })

        vim.keymap.set({ "x", "o" }, "]g", function()
            M.next_diag()
        end, { silent = true })

        vim.keymap.set({ "x", "o" }, "[g", function()
            M.prev_diag()
        end, { silent = true })
    end
end

return M
