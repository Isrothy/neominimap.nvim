local M = {}

local api = vim.api

---@type table<integer, integer>
local winid_to_mwinid = {}

--- The winid of the minimap attached to the given window
---@param winid integer
---@return integer?
M.get_minimap_winid = function(winid)
    local mwinid = winid_to_mwinid[winid]
    if mwinid ~= nil and not api.nvim_win_is_valid(mwinid) then
        winid_to_mwinid[winid] = nil
        return nil
    end
    return mwinid
end

---@param mwinid integer
---@return integer?
M.get_parent_winid = function(mwinid)
    for winid, mwinid_ in pairs(winid_to_mwinid) do
        if mwinid_ == mwinid then
            return winid
        end
    end
    return nil
end

--- Set the winid of the minimap attached to the given window
---@param winid integer
---@param mwinid integer?
M.set_minimap_winid = function(winid, mwinid)
    winid_to_mwinid[winid] = mwinid
end

--- Return the list of windows that one minimap is attached to
--- @return integer[]
M.list_windows = function()
    return vim.tbl_keys(winid_to_mwinid)
end

---@param mwinid integer
---@return boolean
M.is_minimap_window = function(mwinid)
    return M.get_parent_winid(mwinid) ~= nil
end

return M
