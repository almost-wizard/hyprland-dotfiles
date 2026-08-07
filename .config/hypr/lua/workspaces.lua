---------------------
---- WORKSPACES -----
---------------------

local M = {}

local function grid_target(delta)
    local workspace = hl.get_active_workspace()
    local id = tonumber(workspace.id)
    if not id or id < 1 or id > 10 then
        return nil
    end
    return ((id - 1 + delta) % 10) + 1
end

function M.focus_grid_relative(delta)
    return function()
        local target = grid_target(delta)
        if target then
            hl.dispatch(hl.dsp.focus({ workspace = target }))
        end
    end
end

function M.move_active_window_grid_relative(delta)
    return function()
        local target = grid_target(delta)
        if target then
            hl.dispatch(hl.dsp.window.move({ workspace = target }))
        end
    end
end

function M.open_relative_selector(delta)
    return "e" .. (delta > 0 and "+" or "") .. tostring(delta)
end

function M.focus_open_relative(delta)
    return function()
        hl.dispatch(hl.dsp.focus({ workspace = M.open_relative_selector(delta) }))
    end
end

function M.move_active_window_open_relative(delta)
    return function()
        hl.dispatch(hl.dsp.window.move({ workspace = M.open_relative_selector(delta) }))
    end
end

return M
