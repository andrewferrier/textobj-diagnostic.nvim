local set_lines = function(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local check_lines = function(lines)
    assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
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

    it("can delete simple diagnostic", function()
        vim.fn.cursor({ 1, 1 })
        vim.cmd("normal dig")
        check_lines({
            "test1",
            "",
            "test3",
            "test4",
            "test5",
        })
    end)

    it("can delete diagnostic when sitting on it", function()
        vim.fn.cursor({ 2, 1 })
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
        vim.fn.cursor({ 2, 1 })
        vim.cmd("normal d]g")
        check_lines({
            "test1",
            "test2",
            "",
            "test4",
            "test5",
        })
    end)

    it("can delete prev diagnostic when sitting on another", function()
        vim.fn.cursor({ 3, 1 })
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
