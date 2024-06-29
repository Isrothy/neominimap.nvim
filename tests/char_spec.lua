vim.g.testing = true
local assert = require("luassert")
local char = require("neominimap.char")

describe("char", function()
    describe("is_white_space", function()
        it("should return true for white space characters", function()
            assert.is_true(char.is_white_space(0x20)) -- space
            assert.is_true(char.is_white_space(0x09)) -- tab
            assert.is_true(char.is_white_space(0x0A)) -- newline
            assert.is_true(char.is_white_space(0x0D)) -- carriage return
        end)

        it("should return false for non-white space characters", function()
            assert.is_false(char.is_white_space(0x41)) -- 'A'
            assert.is_false(char.is_white_space(0x61)) -- 'a'
        end)
    end)

    describe("is_tab", function()
        it("should return true for tab character", function()
            assert.is_true(char.is_tab(0x09)) -- tab
        end)

        it("should return false for non-tab characters", function()
            assert.is_false(char.is_tab(0x20)) -- space
            assert.is_false(char.is_tab(0x41)) -- 'A'
        end)
    end)

    describe("is_fullwidth", function()
        it("should return true for fullwidth characters", function()
            assert.is_true(char.is_fullwidth(0x4E00)) -- CJK Unified Ideographs
            assert.is_true(char.is_fullwidth(0x9FFF))
            assert.is_true(char.is_fullwidth(0x3400))
            assert.is_true(char.is_fullwidth(0x4DBF))
            assert.is_true(char.is_fullwidth(0xF900))
            assert.is_true(char.is_fullwidth(0xFAFF))
            assert.is_true(char.is_fullwidth(0xFF00))
            assert.is_true(char.is_fullwidth(0xFFEF))
            assert.is_true(char.is_fullwidth(0xAC00)) -- Hangul Syllables
            assert.is_true(char.is_fullwidth(0xD7AF))
        end)

        it("should return false for non-fullwidth characters", function()
            assert.is_false(char.is_fullwidth(0x20)) -- space
            assert.is_false(char.is_fullwidth(0x41)) -- 'A'
        end)
    end)

    describe("is_combining_character", function()
        it("should return true for combining characters", function()
            assert.is_true(char.is_combining_character(0x0300)) -- Combining Grave Accent
            assert.is_true(char.is_combining_character(0x036F))
            assert.is_true(char.is_combining_character(0x1DC0))
            assert.is_true(char.is_combining_character(0x1DFF))
            assert.is_true(char.is_combining_character(0x20D0))
            assert.is_true(char.is_combining_character(0x20FF))
            assert.is_true(char.is_combining_character(0xFE20))
            assert.is_true(char.is_combining_character(0xFE2F))
        end)

        it("should return false for non-combining characters", function()
            assert.is_false(char.is_combining_character(0x20)) -- space
            assert.is_false(char.is_combining_character(0x41)) -- 'A'
        end)
    end)
end)

vim.g.testing = false
