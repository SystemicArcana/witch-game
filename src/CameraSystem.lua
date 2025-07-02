local globals = require("src.globals")
local CameraSystem = {}

function CameraSystem.scroll(mx, my, dt)
    -- Horizontal edge scrolling
    if mx <globals. edgeMargin then
        globals.cam:move(-globals.scrollSpeed * dt, 0)
    elseif mx > globals.screenWidth - globals.edgeMargin then
        globals.cam:move(globals.scrollSpeed * dt, 0)
    end

    -- Vertical edge scrolling (optional)
    if my < globals.edgeMargin then
        globals.cam:move(0, -globals.scrollSpeed * dt)
    elseif my > globals.screenHeight - globals.edgeMargin then
        globals.cam:move(0, globals.scrollSpeed * dt)
    end
end

function CameraSystem.clampCamera()
    local x, y = globals.cam:position()
    local camX = math.max(0, math.min(x, globals.worldWidth))
    local camY = math.max(0, math.min(y, globals.worldHeight))
    globals.cam:lookAt(camX, camY)
end

return CameraSystem