local LizardSpawner = require("LizardSpawner")
local FloatingText = require("FloatingText")
local ForageSystem = require("ForageSystem")

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

local lizardTailsOwned = 0
local lizardSpawnTimer = 0
local lizardSpawnInterval = 4              -- base seconds between spawns
local lizardSpawnIntervalVariance = 2      -- +/- seconds variance
local visibleDuration = 2                  -- seconds fully visible after fade-in
local floatingTextDuration = 1             -- seconds floating texts last and fade out
local floatingTextFontSize = 14            -- font size of floating texts

local floatingTexts = {}

function love.load()
    cam = Camera(0, 0)
    cauldronSprite = love.graphics.newImage("assets/sprites/cauldron.png")
    cauldronHoveredSprite = love.graphics.newImage("assets/sprites/cauldron_witch.png")
    lizardSpawnTimer = getRandomLizardSpawnInterval()
end

local function clampCamera()
    local x, y = cam:position()
    local camX = math.max(0, math.min(x, worldWidth))
    local camY = math.max(0, math.min(y, worldHeight))
    cam:lookAt(camX, camY)
end

local function getRandomLizardSpawnInterval()
    local minTime = math.max(0, lizardSpawnInterval - lizardSpawnIntervalVariance)
    local maxTime = lizardSpawnInterval + lizardSpawnIntervalVariance
    return math.random() * (maxTime - minTime) + minTime
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

    lizardSpawnTimer = lizardSpawnTimer - dt

    ForageSystem.update(dt)

    if LizardSpawner.visible then
        if LizardSpawner.fadingIn or LizardSpawner.fadingOut then
            LizardSpawner.update(dt)
        end

        if lizardSpawnTimer <= lizardSpawnInterval - visibleDuration - LizardSpawner.fadeDuration and not LizardSpawner.fadingOut then
            LizardSpawner.hide()
        end

        if not LizardSpawner.visible then
            lizardSpawnTimer = getRandomLizardSpawnInterval()
        end
    else
        if lizardSpawnTimer <= 0 then
            local blockers = {}

            if ForageSystem.forageButtonVisible then
                table.insert(blockers, {
                    x = ForageSystem.forageButtonX,
                    y = ForageSystem.forageButtonY,
                    w = 190,
                    h = 38
                })
            end

            if ForageSystem.active then
                local menuW = 320
                local menuH = 180
                local menuX = ForageSystem.forageButtonX + 190 / 2 - menuW / 2
                local menuY = ForageSystem.forageButtonY + 38 + 10

                table.insert(blockers, {
                    x = menuX,
                    y = menuY,
                    w = menuW,
                    h = menuH
                })
            end

            LizardSpawner.spawn(blockers)
            lizardSpawnTimer = lizardSpawnInterval
        end
    end

    -- Update floating texts (move up and fade out)
    for i = #floatingTexts, 1, -1 do
        local ft = floatingTexts[i]
        ft.lifetime = ft.lifetime - dt
        ft.y = ft.y - 30 * dt      -- move up 30 pixels per second

        local halfDuration = floatingTextDuration / 2
        if ft.lifetime > halfDuration then
            ft.alpha = 1
        else
            ft.alpha = ft.lifetime / halfDuration
        end

        if ft.lifetime <= 0 then
            table.remove(floatingTexts, i)
        end
    end
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

    function love.mousepressed(x, y, button)
    ForageSystem.mousepressed(x, y, button)

    if button == 1 then -- left click
        if LizardSpawner.isClicked(x, y) then
            lizardTailsOwned = lizardTailsOwned + 1
            LizardSpawner.hideInstant()
            lizardSpawnTimer = getRandomLizardSpawnInterval()

            local baseX = LizardSpawner.x + LizardSpawner.size / 2
            local baseY = LizardSpawner.y - 10

            -- +1 Lizard Tail text
            table.insert(floatingTexts, {
                x = baseX,
                y = baseY,
                alpha = 1,
                lifetime = floatingTextDuration,
                text = "+1 Lizard Tail"
            })

            -- Total Owned text just below +1 text
            table.insert(floatingTexts, {
                x = baseX,
                y = baseY + 15,
                alpha = 1,
                lifetime = floatingTextDuration,
                text = "Total Owned: " .. lizardTailsOwned
            })
        end
    end

    LizardSpawner.draw()
    ForageSystem.draw()

    -- Draw all floating texts centered horizontally
    love.graphics.setFont(love.graphics.newFont(floatingTextFontSize))

    for _, ft in ipairs(floatingTexts) do
        love.graphics.setColor(1, 1, 1, ft.alpha)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(ft.text)
        love.graphics.print(ft.text, ft.x - textWidth / 2, ft.y)
    end

    love.graphics.setColor(1, 1, 1, 1) -- reset color
end