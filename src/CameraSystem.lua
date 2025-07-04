local CameraSystem = {}
globals = require("src/globals")
local radialShader = {}
function CameraSystem.load()
    local width, height = love.graphics.getDimensions()
    radialShader = love.graphics.newShader[[
    extern number cameraY;
    extern number worldHeight;
    extern vec2 cameraOffset;
    extern vec2 center;
    extern number radius;
    extern vec4 colorCenter;
    extern vec4 colorTop;
    extern vec4 colorEdge;

    vec4 effect(vec4 vcolor, Image tex, vec2 texCoords, vec2 screenCoords) {
        float dist = distance(screenCoords + cameraOffset, center);
        float radialFactor = clamp(dist / radius, 0.0, 1.0);

        // Shift the vertical position by camera Y
        float adjustedY = screenCoords.y + cameraY;

        // Vertical blending factor: lower = black, higher = white
        float verticalFactor = clamp(1.0 - (adjustedY / worldHeight), 0.0, 1.0);

        vec4 edgeMix = mix(colorEdge, colorTop, verticalFactor);
        return mix(colorCenter, edgeMix, radialFactor);
    }
    ]]

    -- Set parameters
    radialShader:send("center", {globals.worldWidth / 2, globals.worldHeight / 2})
    radialShader:send("radius", math.max(width, height) / 1.1)
    radialShader:send("worldHeight", globals.worldHeight)
    radialShader:send("colorCenter", {0.5, 0.5, 0.5, 1.0})  -- Gray
    radialShader:send("colorTop", {1.0, 1.0, 1.0, 1.0})     -- White (top highlight)
    radialShader:send("colorEdge", {0.0, 0.0, 0.0, 1.0})    -- Black (edges)
    
end

function CameraSystem.draw()
    local camX, camY = globals.cam:position()
     radialShader:send("cameraY", camY)
    radialShader:send("cameraOffset", {camX, camY})
    love.graphics.setShader(radialShader)
    local w = globals.worldWidth
    local h = globals.worldHeight
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setShader()
end

function CameraSystem.scroll(mx, my, dt)
    -- Horizontal edge scrolling
    if mx < globals.edgeMargin then
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