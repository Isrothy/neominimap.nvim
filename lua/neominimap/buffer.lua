local M = {}

local api = vim.api

---@type table<integer, integer>
local bufnr_to_mbufnr = {}

--- The winid of the minimap attached to the given window
---@param bufnr integer
---@return integer?
M.get_minimap_bufnr = function(bufnr)
	return bufnr_to_mbufnr[bufnr]
end

--- Set the winid of the minimap attached to the given window
---@param bufnr integer
---@param mbufnr integer?
M.set_minimap_bufnr = function(bufnr, mbufnr)
	bufnr_to_mbufnr[bufnr] = mbufnr
end

--- Return the list of minimap windows
--- @return integer[]
M.list_minimap_buffers = function()
	return vim.tbl_values(bufnr_to_mbufnr)
end

---@param bufnr integer
---@return boolean
M.should_generate_minimap = function(bufnr)
	local config = require("neominimap.config").get()
	local filetype = vim.bo[bufnr].filetype
	local buftype = vim.bo[bufnr].buftype

	if vim.tbl_contains(config.exclude_buftypes, buftype) then
		return false
	end
	if vim.tbl_contains(config.exclude_filetypes, filetype) then
		return false
	end
	if config.max_lines and api.nvim_buf_line_count(bufnr) > config.max_lines then
		return false
	end

	return true
end

--- Create the minimap attached to the given buffer if possible
--- Remove minimap buffer if there is already one
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if created, nil otherwise
M.create_minimap_buffer = function(bufnr)
	local util = require("neominimap.util")
	local ret = util.noautocmd(function()
		if not api.nvim_buf_is_valid(bufnr) or not M.should_generate_minimap(bufnr) then
			return nil
		end
		if M.get_minimap_bufnr(bufnr) then
			M.remove_minimap_buffer(bufnr)
		end
		local mbufnr = api.nvim_create_buf(false, true)
		M.set_minimap_bufnr(bufnr, mbufnr)

		vim.bo[bufnr].modifiable = false
		vim.bo[bufnr].buftype = "nofile"
		vim.bo[bufnr].swapfile = false
		vim.bo[bufnr].bufhidden = "wipe"
		return bufnr
	end)()
	return ret
end

--- Remove the minimap attached to the given buffer
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if successfully removed, nil otherwise
M.remove_minimap_buffer = function(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return nil
	end
	local mbufnr = M.get_minimap_bufnr(bufnr)
	if not mbufnr then
		return nil
	end
	local util = require("neominimap.util")
	util.noautocmd(api.nvim_buf_delete)(mbufnr, { force = true })
	bufnr_to_mbufnr[bufnr] = nil
	return bufnr
end

M.create_all_minimap_buffers = function()
	local buffer_list = api.nvim_list_bufs()
	for _, bufnr in buffer_list do
		M.create_minimap_buffer(bufnr)
	end
end

M.remove_all_minimap_buffers = function()
	local buffer_list = M.list_minimap_buffers()
	for _, bufnr in buffer_list do
		M.remove_minimap_buffer(bufnr)
	end
end

return M
