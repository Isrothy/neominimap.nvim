vim.g.testing = true
local assert = require("luassert")
local plenary = require("plenary")
local text = require("neominimap.map.text")

describe("text", function()
    describe("str_to_visible_codepoints", function()
        it("should handle simple ASCII characters", function()
            local str = "abc"
            local expected = { 1, 2, 3 }
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)

        it("should handle tabs correctly", function()
            local str = "a\tb"
            local expected = { 1, 5 } -- assuming tab width of 4
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)

        it("should handle spaces correctly", function()
            local str = "a b c"
            local expected = { 1, 3, 5 }
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)

        it("should handle fullwidth characters", function()
            local str = "a汉b"
            local expected = { 1, 2, 3, 4 }
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)

        it("should handle combining characters", function()
            local str = "áb" -- 'a' with combining acute accent
            local expected = { 1, 2 }
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)

        it("should handle mixed characters", function()
            local str = "a\t 汉 áb"
            local expected = { 1, 6, 7, 9, 10 }
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)

        it("should handle empty string", function()
            local str = ""
            local expected = {}
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)

        it("should handle string with only white spaces", function()
            local str = "  \t  \n"
            local expected = {}
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)

        it("should handle string with tabs at various positions", function()
            local str = "\ta\t"
            local expected = { 5 }
            assert.are.same(expected, text.str_to_visible_codepoints(str, 4))
        end)
    end)
    describe("codepoints_pos", function()
        it("should handle simple ASCII characters", function()
            local str = "hello"
            local tabwidth = 4
            local expected = { 1, 2, 3, 4, 5 }
            assert.are.same(expected, text.codepoints_pos(str, tabwidth))
        end)

        it("should handle string with tabs", function()
            local str = "hello\tworld"
            local tabwidth = 4
            local expected = { 1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13 }
            assert.are.same(expected, text.codepoints_pos(str, tabwidth))
        end)

        it("should handle string with full-width characters", function()
            local str = "ｈｅｌｌｏ"
            local tabwidth = 4
            local expected = { 1, 3, 5, 7, 9 }
            assert.are.same(expected, text.codepoints_pos(str, tabwidth))
        end)

        it("should handle string with combining characters", function()
            local str = "á"
            local tabwidth = 4
            local expected = { 1, 1 }
            assert.are.same(expected, text.codepoints_pos(str, tabwidth))
        end)

        it("should handle mixed string", function()
            local str = "héllo\tｗorld"
            local tabwidth = 4
            local expected = { 1, 2, 2, 3, 4, 5, 6, 9, 11, 12, 13, 14 }
            assert.are.same(expected, text.codepoints_pos(str, tabwidth))
        end)
    end)
end)

vim.g.testing = false
