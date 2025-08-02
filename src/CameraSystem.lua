local CameraSystem = {}
local globals = require("src/globals")

-- Drag state
local dragging = false
local dragStart = {x = 0, y = 0}
local cameraStart = {x = 0, y = 0}

-- Wall status flags
local walls = {left=false, right=false, top=false, bottom=false}

-- ===============================
-- INITIAL LOAD
-- ===============================
function CameraSystem.load()
    -- Placeholder for shaders if you add background effects
end

-- ===============================
-- CAMERA UPDATE (smooth pan & zoom)
-- ===============================
function CameraSystem.update(dt)
    -- Smooth position
    local cx, cy = globals.cam:position()
    cx = cx + (globals.camTargetX - cx) * globals.cameraLerpSpeed * dt
    cy = cy + (globals.camTargetY - cy) * globals.cameraLerpSpeed * dt
    globals.cam:lookAt(cx, cy)

    -- Smooth zoom
    local cz = globals.cam.scale
    local nz = cz + (globals.camTargetZoom - cz) * globals.zoomLerpSpeed * dt
    globals.cam:zoomTo(nz)

    -- Dragging
    if dragging then
        local mx, my = love.mouse.getPosition()
        local dx = (dragStart.x - mx) / globals.cam.scale
        local dy = (dragStart.y - my) / globals.cam.scale
        globals.camTargetX = cameraStart.x + dx
        globals.camTargetY = cameraStart.y + dy
    end
end

-- ===============================
-- CLAMP CAMERA TO CURRENT PLAY AREA
-- ===============================
function CameraSystem.clampCamera()
    local zoom = globals.cam.scale
    local halfW = (globals.screenWidth / zoom) / 2
    local halfH = (globals.screenHeight / zoom) / 2

    -- If visible area exceeds playBorderSize, skip clamping
    if (halfW * 2) >= globals.playBorderSize and (halfH * 2) >= globals.playBorderSize then
        return
    end

    -- Play area centered on world center
    local centerX = (globals.worldMinX + globals.worldMaxX) / 2
    local centerY = (globals.worldMinY + globals.worldMaxY) / 2
    local halfPlay = globals.playBorderSize / 2

    local minX = centerX - halfPlay + halfW
    local maxX = centerX + halfPlay - halfW
    local minY = centerY - halfPlay + halfH
    local maxY = centerY + halfPlay - halfH

    globals.camTargetX = math.max(minX, math.min(globals.camTargetX, maxX))
    globals.camTargetY = math.max(minY, math.min(globals.camTargetY, maxY))
end

-- ===============================
-- ZOOM CONTROL
-- ===============================
function CameraSystem.handleZoomInput(dy)
    local factor = 1.1 ^ dy
    local newZoom = globals.camTargetZoom * factor
    newZoom = math.max(globals.zoomMin, math.min(newZoom, globals.zoomMax))
    globals.camTargetZoom = newZoom

    -- Always center zoom around cauldron
    globals.camTargetX = globals.cauldronX
    globals.camTargetY = globals.cauldronY
end

-- ===============================
-- DRAGGING
-- ===============================
function CameraSystem.beginDrag(x, y)
    dragging = true
    dragStart.x, dragStart.y = x, y
    cameraStart.x, cameraStart.y = globals.camTargetX, globals.camTargetY
end

function CameraSystem.endDrag()
    dragging = false
end

-- ===============================
-- WALL DETECTION
-- ===============================
function CameraSystem.updateWallStatus()
    local zoom = globals.cam.scale
    local halfW = (globals.screenWidth / zoom) / 2
    local halfH = (globals.screenHeight / zoom) / 2
    local centerX = (globals.worldMinX + globals.worldMaxX) / 2
    local centerY = (globals.worldMinY + globals.worldMaxY) / 2
    local halfPlay = globals.playBorderSize / 2

    -- If visible area exceeds playBorderSize, disable wall indicators
    if (halfW * 2) >= globals.playBorderSize or (halfH * 2) >= globals.playBorderSize then
        walls.left, walls.right, walls.top, walls.bottom = false, false, false, false
        return
    end

    local x, y = globals.cam:position()

    walls.left   = (x - halfW) <= (centerX - halfPlay + globals.epsilon)
    walls.right  = (x + halfW) >= (centerX + halfPlay - globals.epsilon)
    walls.top    = (y - halfH) <= (centerY - halfPlay + globals.epsilon)
    walls.bottom = (y + halfH) >= (centerY + halfPlay - globals.epsilon)
end

-- ===============================
-- DRAW BACKGROUND (Optional)
-- ===============================
function CameraSystem.draw()
    -- Background rendering placeholder
end

return CameraSystem
