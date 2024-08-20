---A map between tabs and minimap windows
local M = {}

local api = vim.api

---@type table<integer, integer>
local tabid_to_mwinid = {}

---@type table<integer, integer>
local tabid_to_swinid = {}

--- The winid of the minimap attached in the tab
---@param tabid integer
---@return integer?
M.get_minimap_winid = function(tabid)
    local mwinid = tabid_to_mwinid[tabid]
    if mwinid ~= nil and not api.nvim_win_is_valid(mwinid) then
        tabid_to_mwinid[tabid] = nil
        return nil
    end
    return mwinid
end

--- Set the winid of the minimap attached to the given window
---@param tabid integer
---@param mwinid integer?
M.set_minimap_winid = function(tabid, mwinid)
    tabid_to_mwinid[tabid] = mwinid
end

--- The winid of the source window in the tab
---@param tabid integer
---@return integer?
M.get_source_winid = function(tabid)
    local swinid = tabid_to_swinid[tabid]
    if swinid ~= nil and not api.nvim_win_is_valid(swinid) then
        tabid_to_swinid[tabid] = nil
        return nil
    end
    return swinid
end

--- Set the winid of the source window in the tab
---@param tabid integer
---@param swinid integer?
M.set_source_winid = function(tabid, swinid)
    tabid_to_swinid[tabid] = swinid
end

---@param tabid integer
---@param mwinid integer
---@return boolean
M.is_minimap_window = function(tabid, mwinid)
    return mwinid ~= nil and tabid_to_mwinid[tabid] == mwinid
end

return M
