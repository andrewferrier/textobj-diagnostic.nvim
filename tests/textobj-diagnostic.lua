-- nvim_buf_get_mark: rows 1-indexed, cols 0-indexed
-- vim.diagnostic.get/set: rows 0-indexed, cols 0-indexed
-- vim.api.nvim_win_set_cursor: rows 1-indexed, cols 0-indexed

local set_lines = function(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local check_lines = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

local check_visual = function(row1, col1, row2, col2)
    assert.are.same({ row1, col1 }, vim.api.nvim_buf_get_mark(0, "<"))
    assert.are.same({ row2, col2 }, vim.api.nvim_buf_get_mark(0, ">"))
end

local feedkeys = function(keys)
    keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(keys, "mtx", false)
end

local TEST_NAMESPACE = 1
local BUFFER_NUMBER = 0

describe("out-of-the-box keymappings", function()
    before_each(function()
        require("textobj-diagnostic").setup({})

        set_lines({
            "test1",
            "test2",
            "test3",
            "test4",
            "test5",
        })

        vim.diagnostic.set(TEST_NAMESPACE, 0, {
            {
                bufnr = BUFFER_NUMBER,
                lnum = 1,
                end_lnum = 1,
                col = 0,
                end_col = 5,
                severity = vim.diagnostic.severity.ERROR,
                message = "test2 failed",
            },
            {
                bufnr = BUFFER_NUMBER,
                lnum = 2,
                end_lnum = 2,
                col = 0,
                end_col = 5,
                severity = vim.diagnostic.severity.ERROR,
                message = "test3 failed",
            },
        })
    end)

    it("can change diagnostic", function()
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        vim.cmd("normal cighello")
        check_lines({
            "test1",
            "hello",
            "test3",
            "test4",
            "test5",
        })
    end)

    it("can delete diagnostic", function()
        vim.api.nvim_win_set_cursor(0, { 1, 1 })
        vim.cmd("normal dig")
        check_lines({
            "test1",
            "",
            "test3",
            "test4",
            "test5",
        })
    end)

    it("can visually select diagnostic", function()
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("vigv")
        check_visual(2, 0, 2, 4)
    end)

    it("can visually select diagnostic when sitting on it", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        feedkeys("vigv")
        check_visual(2, 0, 2, 4)
    end)

    it("can delete diagnostic when sitting on it", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        vim.cmd("normal dig")
        check_lines({
            "test1",
            "",
            "test3",
            "test4",
            "test5",
        })
    end)

    it("can delete next diagnostic when sitting on another", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        vim.cmd("normal d]g")
        check_lines({
            "test1",
            "test2",
            "",
            "test4",
            "test5",
        })
    end)

    it("can visually select next diagnostic when sitting on another", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        feedkeys("v]gv")
        check_visual(3, 0, 3, 4)
    end)

    it("can delete prev diagnostic when sitting on another", function()
        vim.api.nvim_win_set_cursor(0, { 3, 0 })
        vim.cmd("normal d[g")
        check_lines({
            "test1",
            "",
            "test3",
            "test4",
            "test5",
        })
    end)
end)

describe("limit severity", function()
    before_each(function()
        require("textobj-diagnostic").setup({ create_default_keymaps = false })

        vim.keymap.set(
            { "x", "o" },
            "ig",
            ":<C-U>lua require('textobj-diagnostic').next_diag_inclusive({ severity = { "
                .. "min = vim.diagnostic.severity.WARN, "
                .. "max = vim.diagnostic.severity.ERROR }})<CR>",
            { silent = true }
        )

        set_lines({
            "test1",
            "test2",
            "test3",
        })

        vim.diagnostic.set(TEST_NAMESPACE, 0, {
            {
                bufnr = BUFFER_NUMBER,
                lnum = 1,
                end_lnum = 1,
                col = 0,
                end_col = 5,
                severity = vim.diagnostic.severity.HINT,
                message = "test2 failed",
            },
            {
                bufnr = BUFFER_NUMBER,
                lnum = 2,
                end_lnum = 2,
                col = 0,
                end_col = 5,
                severity = vim.diagnostic.severity.ERROR,
                message = "test3 failed",
            },
        })
    end)

    it("can delete simple diagnostic", function()
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        vim.cmd("normal dig")
        check_lines({
            "test1",
            "test2",
            "",
        })
    end)
end)
