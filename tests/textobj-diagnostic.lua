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
            {
                bufnr = BUFFER_NUMBER,
                lnum = 3,
                end_lnum = 3,
                col = 1,
                end_col = 4,
                severity = vim.diagnostic.severity.ERROR,
                message = "test4 failed",
            },
        })
    end)

    vim.keymap.set({ "x", "o" }, "ng", function()
        require("textobj-diagnostic").nearest_diag()
    end, { silent = true })

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

    it("can change diagnostic when sitting at the end", function()
        vim.api.nvim_win_set_cursor(0, { 1, 4 })
        vim.cmd("normal cighello")
        check_lines({
            "test1",
            "hello",
            "test3",
            "test4",
            "test5",
        })
    end)

    it("can accurately change diagnostic not covering whole line, col = ^", function()
        vim.api.nvim_win_set_cursor(0, { 4, 1 })
        vim.cmd("normal cighello")
        check_lines({
            "test1",
            "test2",
            "test3",
            "thello4",
            "test5",
        })
    end)

    it("can accurately change diagnostic not covering whole line, col = beg", function()
        vim.api.nvim_win_set_cursor(0, { 4, 2 })
        vim.cmd("normal cighello")
        check_lines({
            "test1",
            "test2",
            "test3",
            "thello4",
            "test5",
        })
    end)

    it("can accurately change diagnostic not covering whole line, col = end", function()
        vim.api.nvim_win_set_cursor(0, { 4, 3 })
        vim.cmd("normal cighello")
        check_lines({
            "test1",
            "test2",
            "test3",
            "thello4",
            "test5",
        })
    end)

    it("can accurately change first diagnostic not covering whole line, col = $", function()
        vim.api.nvim_win_set_cursor(0, { 4, 4 })
        vim.cmd("normal cighello")
        check_lines({
            "test1",
            "hello",
            "test3",
            "test4",
            "test5",
        })
    end)

    it("can change nearest diagnostic - row 1", function()
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        vim.cmd("normal cnghello")
        check_lines({
            "test1",
            "hello",
            "test3",
            "test4",
            "test5",
        })
    end)

    it("can change nearest diagnostic - row 2", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        vim.cmd("normal cnghello")
        check_lines({
            "test1",
            "hello",
            "test3",
            "test4",
            "test5",
        })
    end)

    it("can change nearest diagnostic - row 3", function()
        vim.api.nvim_win_set_cursor(0, { 3, 0 })
        vim.cmd("normal cnghello")
        check_lines({
            "test1",
            "test2",
            "hello",
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

    it("can delete nearest diagnostic", function()
        vim.api.nvim_win_set_cursor(0, { 1, 1 })
        vim.cmd("normal dng")
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

    it("can visually select nearest diagnostic", function()
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        feedkeys("vngv")
        check_visual(2, 0, 2, 4)
    end)

    it("can visually select nearest diagnostic when sitting on it", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        feedkeys("vngv")
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

    it("can delete nearest diagnostic when sitting on it", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        vim.cmd("normal dng")
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

        vim.keymap.set({ "x", "o" }, "ig", function()
            require("textobj-diagnostic").next_diag_inclusive({
                severity = {
                    min = vim.diagnostic.severity.WARN,
                    max = vim.diagnostic.severity.ERROR,
                },
            })
        end, { silent = true })

        vim.keymap.set({ "x", "o" }, "]g", function()
            require("textobj-diagnostic").next_diag({
                severity = {
                    min = vim.diagnostic.severity.WARN,
                    max = vim.diagnostic.severity.ERROR,
                },
            })
        end, { silent = true })

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

    it("can delete simple diagnostic inclusively", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        vim.cmd("normal dig")
        check_lines({
            "test1",
            "test2",
            "",
        })
    end)

    it("can delete simple diagnostic exclusively", function()
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        vim.cmd("normal d]g")
        check_lines({
            "test1",
            "test2",
            "",
        })
    end)
end)

TEST_NAMESPACE = 2
BUFFER_NUMBER = 1

describe("nearest diagnostics", function()
    before_each(function()
        require("textobj-diagnostic").setup({})

        set_lines({
            "test1",
            "test2",
            "test3",
            "testA    testB",
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
            {
                bufnr = BUFFER_NUMBER,
                lnum = 3,
                end_lnum = 3,
                col = 1,
                end_col = 4,
                severity = vim.diagnostic.severity.ERROR,
                message = "test4 failed",
            },
            {
                bufnr = BUFFER_NUMBER,
                lnum = 4,
                end_lnum = 4,
                col = 0,
                end_col = 5,
                severity = vim.diagnostic.severity.ERROR,
                message = "testA failed",
            },
            {
                bufnr = BUFFER_NUMBER,
                lnum = 4,
                end_lnum = 4,
                col = 9,
                end_col = 13,
                severity = vim.diagnostic.severity.ERROR,
                message = "testB failed",
            },
        })
    end)

    vim.keymap.set({ "x", "o" }, "ng", function()
        require("textobj-diagnostic").nearest_diag()
    end, { silent = true })

    it("can change nearest diagnostic - row 1", function()
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        vim.cmd("normal cnghello")
        check_lines({
            "test1",
            "hello",
            "test3",
            "testA    testB",
        })
    end)

    it("can change nearest diagnostic - row 2", function()
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        vim.cmd("normal cnghello")
        check_lines({
            "test1",
            "hello",
            "test3",
            "testA    testB",
        })
    end)

    it("can change nearest diagnostic - row 3", function()
        vim.api.nvim_win_set_cursor(0, { 3, 0 })
        vim.cmd("normal cnghello")
        check_lines({
            "test1",
            "test2",
            "hello",
            "testA    testB",
        })
    end)

    it("can change nearest diagnostic - row 4, A", function()
        vim.api.nvim_win_set_cursor(0, { 4, 0 })
        vim.cmd("normal cnghello")
        check_lines({
            "test1",
            "test2",
            "test3",
            "hello    testB",
        })
    end)

    it("can change nearest diagnostic - row 4, B", function()
        vim.api.nvim_win_set_cursor(0, { 4, 9 })
        vim.cmd("normal cnghello")
        check_lines({
            "test1",
            "test2",
            "test3",
            "testA    helloB",
        })
    end)
end)
