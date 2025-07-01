local Camera = require "src.lib.hump.camera"
local cam
local dragging = false
local dragStartX, dragStartY
local camStartX, camStartY
local cam
local scrollSpeed = 300      -- pixels per second
local edgeMargin = 30        -- distance from screen edge to trigger scroll
local worldWidth = 200
local worldHeight = 500
local cauldronX = worldWidth / 2
local cauldronY = worldHeight /2

function love.load()
    cam = Camera(0, 0)
    cauldronSprite = love.graphics.newImage("assets/sprites/cauldron.png")
    cauldronHoveredSprite = love.graphics.newImage("assets/sprites/cauldron_witch.png")
end

local function clampCamera()
    local x, y = cam:position()
    local camX = math.max(0, math.min(x, worldWidth))
    local camY = math.max(0, math.min(y, worldHeight))
    cam:lookAt(camX, camY)
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    local worldX, worldY = cam:worldCoords(mx, my)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Horizontal edge scrolling
    if mx < edgeMargin then
        cam:move(-scrollSpeed * dt, 0)
    elseif mx > screenWidth - edgeMargin then
        cam:move(scrollSpeed * dt, 0)
    end

    -- Vertical edge scrolling (optional)
    if my < edgeMargin then
        cam:move(0, -scrollSpeed * dt)
    elseif my > screenHeight - edgeMargin then
        cam:move(0, scrollSpeed * dt)
    end

    local ox = cauldronSprite:getWidth() / 2
    local oy = cauldronSprite:getHeight() / 2

    -- Check mouse within bounds of image

    if worldX > cauldronX - ox and worldX < cauldronX + ox and
       worldY > cauldronY - oy and worldY < cauldronY + oy then
        cauldronHovered = true
    else
        cauldronHovered = false
    end

    clampCamera()
end

function love.draw()
    cam:attach()

    -- Draw game world (simple grid)
    for i = -1000, 1000, 100 do
        for j = -1000, 1000, 100 do
            love.graphics.rectangle("line", i, j, 90, 90)
        end
    end

    -- Draw Cauldron
    local img = cauldronHovered and cauldronHoveredSprite or cauldronSprite
    local w = img:getWidth()
    local h = img:getHeight()
    love.graphics.draw(img, cauldronX, cauldronY, 0, 1, 1, w/2, h/2)

    cam:detach()

    -- UI / instruction
    love.graphics.print("Move mouse to screen edges to pan camera", 10, 10)
end