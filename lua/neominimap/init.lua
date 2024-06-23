local M = {}

local api = vim.api

M.enabled = false

function M.open_minimap()
	if M.enabled then
		return
	end
	M.enabled = true
	local window = require("neominimap.window")
	local buffer = require("neominimap.buffer")
	buffer.create_all_minimap_buffers()
	window.create_all_minimaps()
	window.refresh_all_minimaps()
end

function M.close_minimap()
	if not M.enabled then
		return
	end
	M.enabled = false
	local window = require("neominimap.window")
	local buffer = require("neominimap.buffer")
	window.close_all_minimaps()
	buffer.remove_all_minimap_buffers()
end

function M.toggle_minimap()
	if M.enabled then
		M.close_minimap()
	else
		M.open_minimap()
	end
end

M.setup = function()
	local ns = api.nvim_create_namespace("neominimap")
	api.nvim_set_hl(ns, "NeominimapBackground", { link = "Normal", default = true })
	api.nvim_set_hl(ns, "NeominimapBorder", { link = "FloatBorder", default = true })

	local gid = api.nvim_create_augroup("Neominimap", { clear = true })
	api.nvim_create_autocmd({ "BufRead", "BufNew" }, {
		group = gid,
		callback = vim.schedule_wrap(function()
			if M.enabled then
				local buffer = require("neominimap.buffer")
				local bufnr = api.nvim_get_current_buf()
				buffer.create_minimap_buffer(bufnr)
			end
		end),
	})
	api.nvim_create_autocmd("BufDelete", {
		group = gid,
		callback = vim.schedule_wrap(function()
			local buffer = require("neominimap.buffer")
			local bufnr = api.nvim_get_current_buf()
			buffer.remove_minimap_buffer(bufnr)
		end),
	})
	api.nvim_create_autocmd("WinNew", {
		group = gid,
		callback = vim.schedule_wrap(function()
			if M.enabled then
				local window = require("neominimap.window")
				local winid = api.nvim_get_current_win()
				window.create_minimap_window(winid)
				window.refresh_code_minimap(winid)
			end
		end),
	})
	api.nvim_create_autocmd("WinClosed", {
		group = gid,
		callback = vim.schedule_wrap(function()
			local window = require("neominimap.window")
			local winid = api.nvim_get_current_win()
			window.close_minimap_window(winid)
		end),
	})
	api.nvim_create_autocmd("TabEnter", {
		group = gid,
		callback = vim.schedule_wrap(function()
			local window = require("neominimap.window")
			local tid = api.nvim_get_current_tabpage()
			window.refresh_minimaps_in_tab(tid)
		end),
	})
	api.nvim_create_autocmd("WinResized", {
		group = gid,
		callback = function(event)
			local win_list = {}
			for winid, _ in pairs(event) do
				if type(winid) == "number" then
					win_list[#win_list + 1] = winid
				end
			end
			vim.schedule_wrap(function()
				if M.enabled then
					local window = require("neominimap.window")
					for _, winid in ipairs(win_list) do
						window.create_minimap_window(winid)
					end
				end
			end)
		end,
	})
	api.nvim_create_autocmd("WinScrolled", {
		group = gid,
		callback = function(event)
			local win_list = {}
			for winid, _ in pairs(event) do
				if type(winid) == "number" then
					win_list[#win_list + 1] = winid
				end
			end
			vim.schedule_wrap(function()
				if M.enabled then
					local window = require("neominimap.window")
					for _, winid in ipairs(win_list) do
						window.refresh_code_minimap(winid)
					end
				end
			end)
		end,
	})
end

return M
