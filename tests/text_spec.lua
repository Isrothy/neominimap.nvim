vim.g.testing = true
local assert = require("luassert")
local plenary = require("plenary")
local text = require("neominimap.text")

describe("text", function()
    describe("is_white_space", function()
        it("should return true for white space characters", function()
            assert.is_true(text.is_white_space(0x20)) -- space
            assert.is_true(text.is_white_space(0x09)) -- tab
            assert.is_true(text.is_white_space(0x0A)) -- newline
            assert.is_true(text.is_white_space(0x0D)) -- carriage return
        end)

        it("should return false for non-white space characters", function()
            assert.is_false(text.is_white_space(0x41)) -- 'A'
            assert.is_false(text.is_white_space(0x61)) -- 'a'
        end)
    end)

    describe("is_tab", function()
        it("should return true for tab character", function()
            assert.is_true(text.is_tab(0x09)) -- tab
        end)

        it("should return false for non-tab characters", function()
            assert.is_false(text.is_tab(0x20)) -- space
            assert.is_false(text.is_tab(0x41)) -- 'A'
        end)
    end)

    describe("is_fullwidth", function()
        it("should return true for fullwidth characters", function()
            assert.is_true(text.is_fullwidth(0x4E00)) -- CJK Unified Ideographs
            assert.is_true(text.is_fullwidth(0x9FFF))
            assert.is_true(text.is_fullwidth(0x3400))
            assert.is_true(text.is_fullwidth(0x4DBF))
            assert.is_true(text.is_fullwidth(0xF900))
            assert.is_true(text.is_fullwidth(0xFAFF))
            assert.is_true(text.is_fullwidth(0xFF00))
            assert.is_true(text.is_fullwidth(0xFFEF))
            assert.is_true(text.is_fullwidth(0xAC00)) -- Hangul Syllables
            assert.is_true(text.is_fullwidth(0xD7AF))
        end)

        it("should return false for non-fullwidth characters", function()
            assert.is_false(text.is_fullwidth(0x20)) -- space
            assert.is_false(text.is_fullwidth(0x41)) -- 'A'
        end)
    end)

    describe("is_combining_character", function()
        it("should return true for combining characters", function()
            assert.is_true(text.is_combining_character(0x0300)) -- Combining Grave Accent
            assert.is_true(text.is_combining_character(0x036F))
            assert.is_true(text.is_combining_character(0x1DC0))
            assert.is_true(text.is_combining_character(0x1DFF))
            assert.is_true(text.is_combining_character(0x20D0))
            assert.is_true(text.is_combining_character(0x20FF))
            assert.is_true(text.is_combining_character(0xFE20))
            assert.is_true(text.is_combining_character(0xFE2F))
        end)

        it("should return false for non-combining characters", function()
            assert.is_false(text.is_combining_character(0x20)) -- space
            assert.is_false(text.is_combining_character(0x41)) -- 'A'
        end)
    end)

    describe("to_view_points", function()
        it("should handle simple ASCII characters", function()
            local str = "abc"
            local expected = { 1, 2, 3 }
            assert.are.same(expected, text.to_view_points(str, 4))
        end)

        it("should handle tabs correctly", function()
            local str = "a\tb"
            local expected = { 1, 5 } -- assuming tab width of 4
            assert.are.same(expected, text.to_view_points(str, 4))
        end)

        it("should handle spaces correctly", function()
            local str = "a b c"
            local expected = { 1, 3, 5 }
            assert.are.same(expected, text.to_view_points(str, 4))
        end)

        it("should handle fullwidth characters", function()
            local str = "a汉b"
            local expected = { 1, 2, 3, 4 }
            assert.are.same(expected, text.to_view_points(str, 4))
        end)

        it("should handle combining characters", function()
            local str = "áb" -- 'a' with combining acute accent
            local expected = { 1, 2 }
            assert.are.same(expected, text.to_view_points(str, 4))
        end)

        it("should handle mixed characters", function()
            local str = "a\t 汉 áb"
            local expected = { 1, 6, 7, 9, 10 }
            assert.are.same(expected, text.to_view_points(str, 4))
        end)

        it("should handle empty string", function()
            local str = ""
            local expected = {}
            assert.are.same(expected, text.to_view_points(str, 4))
        end)

        it("should handle string with only white spaces", function()
            local str = "  \t  \n"
            local expected = {}
            assert.are.same(expected, text.to_view_points(str, 4))
        end)

        it("should handle string with tabs at various positions", function()
            local str = "\ta\t"
            local expected = { 5 }
            assert.are.same(expected, text.to_view_points(str, 4))
        end)
    end)
end)

vim.g.testing = false
