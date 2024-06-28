local M = {}

local api = vim.api
local config = require("neominimap.config").get()

---@type boolean
M.enabled = false

function M.open_minimap()
    if M.enabled then
        return
    end
    M.enabled = true
    local window = require("neominimap.window")
    local buffer = require("neominimap.buffer")
    local logger = require("neominimap.logger")
    logger.log("Minimap is being opened. Initializing buffers and windows.", vim.log.levels.INFO)
    buffer.refresh_all_minimap_buffers()
    window.refresh_all_minimap_windows()
    logger.log("Minimap has been successfully opened.", vim.log.levels.INFO)
end

function M.close_minimap()
    if not M.enabled then
        return
    end
    M.enabled = false
    local window = require("neominimap.window")
    local buffer = require("neominimap.buffer")
    local logger = require("neominimap.logger")
    logger.log("Minimap is being closed. Cleaning up buffers and windows.", vim.log.levels.INFO)
    window.close_all_minimap_windows()
    buffer.wipe_out_all_minimap_buffers()
    logger.log("Minimap has been successfully closed.", vim.log.levels.INFO)
end

function M.toggle_minimap()
    if M.enabled then
        M.close_minimap()
    else
        M.open_minimap()
    end
end

M.setup = function()
    local logger = require("neominimap.logger")
    api.nvim_set_hl(0, "NeominimapBackground", { link = "Normal", default = true })
    api.nvim_set_hl(0, "NeominimapBorder", { link = "FloatBorder", default = true })

    local gid = api.nvim_create_augroup("Neominimap", { clear = true })
    api.nvim_create_autocmd("VimEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            logger.log("VimEnter event triggered. Checking if minimap should auto-enable.", vim.log.levels.TRACE)
            if config.auto_enable then
                M.open_minimap()
            end
        end),
    })
    api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = gid,
        callback = function(args)
            logger.log(
                string.format("BufReadPost or BufNewFile event triggered for buffer %d.", args.buf),
                vim.log.levels.TRACE
            )
            vim.schedule(function()
                if M.enabled then
                    local buffer = require("neominimap.buffer")
                    local bufnr = tonumber(args.buf)
                    ---@cast bufnr integer
                    logger.log(string.format("Refreshing minimap for buffer %d.", bufnr), vim.log.levels.TRACE)
                    buffer.refresh_minimap_buffer(bufnr)
                    logger.log(string.format("Minimap buffer refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("BufWipeout", {
        group = gid,
        callback = function(args)
            logger.log(string.format("BufWipeout event triggered for buffer %d.", args.buf), vim.log.levels.TRACE)
            vim.schedule(function()
                local buffer = require("neominimap.buffer")
                local bufnr = tonumber(args.buf)
                logger.log(string.format("Wiping out minimap for buffer %d.", bufnr), vim.log.levels.TRACE)
                ---@cast bufnr integer
                buffer.wipe_out_minimap_buffer(bufnr)
                logger.log(string.format("Minimap buffer wiped out for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("BufWinEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            local winid = api.nvim_get_current_win()
            logger.log(string.format("BufWindoEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
            if M.enabled then
                local window = require("neominimap.window")
                logger.log(string.format("Refreshing minimap window for window ID: %d.", winid), vim.log.levels.TRACE)
                window.refresh_minimap_window(winid)
                logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
            end
        end),
    })
    api.nvim_create_autocmd("WinNew", {
        group = gid,
        callback = function()
            local winid = api.nvim_get_current_win()
            logger.log(string.format("WinNew event triggered for window %d.", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                if M.enabled then
                    local window = require("neominimap.window")
                    logger.log(
                        string.format("Refreshing minimap window for window ID: %d.", winid),
                        vim.log.levels.TRACE
                    )
                    window.refresh_minimap_window(winid)
                    logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("WinClosed", {
        group = gid,
        callback = function(args)
            logger.log(
                string.format("WinClosed event triggered for window %d.", tonumber(args.match)),
                vim.log.levels.TRACE
            )
            local winid = tonumber(args.match)
            vim.schedule(function()
                local window = require("neominimap.window")
                logger.log(string.format("Closing minimap for window %d.", winid), vim.log.levels.TRACE)
                ---@cast winid integer
                window.close_minimap_window(winid)
                logger.log(string.format("Minimap window closed for window %d.", winid), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("TabEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            local tid = api.nvim_get_current_tabpage()
            local window = require("neominimap.window")
            logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
            logger.log(string.format("Refreshing minimaps for tab ID: %d.", tid), vim.log.levels.TRACE)
            window.refresh_minimaps_in_tab(tid)
            logger.log(string.format("Minimaps refreshed for tab %d.", tid), vim.log.levels.TRACE)
        end),
    })
    api.nvim_create_autocmd("WinResized", {
        group = gid,
        callback = function()
            logger.log("WinResized event triggered.", vim.log.levels.TRACE)
            local win_list = vim.deepcopy(vim.v.event.windows)
            logger.log(string.format("Windows to be resized: %s", vim.inspect(win_list)), vim.log.levels.TRACE)
            vim.schedule(function()
                if M.enabled then
                    local window = require("neominimap.window")
                    for _, winid in ipairs(win_list) do
                        logger.log(string.format("Refreshing minimaps for window: %d", winid), vim.log.levels.TRACE)
                        window.refresh_minimap_window(winid)
                        logger.log(string.format("Minimaps refreshed for window: %d", winid), vim.log.levels.TRACE)
                    end
                end
            end)
        end,
    })
    api.nvim_create_autocmd("WinScrolled", {
        group = gid,
        callback = function()
            logger.log("WinScrolled event triggered.", vim.log.levels.TRACE)
            local win_list = {}
            for winid, _ in pairs(vim.v.event) do
                if winid ~= "all" then
                    win_list[#win_list + 1] = tonumber(winid)
                end
            end
            logger.log(string.format("Windows to be scrolled: %s", vim.inspect(win_list)), vim.log.levels.TRACE)
            vim.schedule(function()
                if M.enabled then
                    local window = require("neominimap.window")
                    for _, winid in ipairs(win_list) do
                        logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
                        window.refresh_minimap_window(winid)
                        logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
                    end
                end
            end)
        end,
    })
end

return M
