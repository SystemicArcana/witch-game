-- LizardSpawner: Spawns clickable lizard tail that fades in/out and wiggles with rotation
ForageSystem = require("src.ForageSystem")
FloatingText = require("src.FloatingText")
globals = require("src.globals")

local LizardSpawner = {}

-- Spawn timing configuration
local lizardSpawnInterval = 4
local lizardSpawnIntervalVariance = 2

-- Lizard visual configuration
LizardSpawner.baseSize = 50
LizardSpawner.size = LizardSpawner.baseSize * 2.2  -- Final visual size
LizardSpawner.x = 0
LizardSpawner.y = 0
LizardSpawner.alpha = 0
LizardSpawner.visible = false

-- Fade animation config
LizardSpawner.visibleDuration = 2
LizardSpawner.fadeDuration = 0.5
LizardSpawner.fadingIn = false
LizardSpawner.fadingOut = false
LizardSpawner.fadeTimer = 0

-- Wiggle (rotation) state
LizardSpawner.wiggleTimer = 0
LizardSpawner.wiggleSpeed = 6         -- Radians per second
LizardSpawner.wiggleAmplitude = 0.2   -- Max angle in radians (~11.5°)

-- Lizard sprite
local lizardImage = love.graphics.newImage("assets/sprites/lizard.png")
local lizardImageW = lizardImage:getWidth()
local lizardImageH = lizardImage:getHeight()
local lizardScale = LizardSpawner.size / math.max(lizardImageW, lizardImageH)

-- Axis-aligned bounding box collision
local function isOverlapping(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end

-- Attempt to spawn the lizard randomly within full world bounds, avoiding blockers
function LizardSpawner.spawn(blockers)
    local width = globals.worldWidth
    local height = globals.worldHeight
    local maxRetries = 10
    local found = false

    for i = 1, maxRetries do
        local x = math.random(0, width - LizardSpawner.size)
        local y = math.random(0, height - LizardSpawner.size)

        local overlaps = false
        for _, b in ipairs(blockers or {}) do
            if isOverlapping(x, y, LizardSpawner.size, LizardSpawner.size, b.x, b.y, b.w, b.h) then
                overlaps = true
                break
            end
        end

        if not overlaps then
            LizardSpawner.x = x
            LizardSpawner.y = y
            LizardSpawner.visible = true
            LizardSpawner.alpha = 0
            LizardSpawner.fadingIn = true
            LizardSpawner.fadingOut = false
            LizardSpawner.fadeTimer = 0
            LizardSpawner.wiggleTimer = 0
            found = true
            break
        end
    end

    if not found then
        LizardSpawner.visible = false
    end
end

-- Instantly remove lizard from screen
function LizardSpawner.hideInstant()
    LizardSpawner.visible = false
    LizardSpawner.alpha = 0
    LizardSpawner.fadingIn = false
    LizardSpawner.fadingOut = false
end

-- Begin fade-out animation
function LizardSpawner.hide()
    if LizardSpawner.visible and not LizardSpawner.fadingOut then
        LizardSpawner.fadingIn = false
        LizardSpawner.fadingOut = true
        LizardSpawner.fadeTimer = LizardSpawner.fadeDuration
    end
end

-- Update fade animation and wiggle timer
function LizardSpawner.update(dt)
    if LizardSpawner.fadingIn then
        LizardSpawner.alpha = LizardSpawner.alpha + dt / LizardSpawner.fadeDuration
        if LizardSpawner.alpha >= 1 then
            LizardSpawner.alpha = 1
            LizardSpawner.fadingIn = false
        end
    elseif LizardSpawner.fadingOut then
        LizardSpawner.alpha = LizardSpawner.alpha - dt / LizardSpawner.fadeDuration
        if LizardSpawner.alpha <= 0 then
            LizardSpawner.alpha = 0
            LizardSpawner.fadingOut = false
            LizardSpawner.visible = false
        end
    end

    LizardSpawner.wiggleTimer = LizardSpawner.wiggleTimer + dt
end

-- Draw the lizard with alpha and wiggle rotation
function LizardSpawner.draw()
    if LizardSpawner.visible then
        love.graphics.setColor(1, 1, 1, LizardSpawner.alpha)

        -- Calculate rotation based on sine wave for wiggle
        local angle = math.sin(LizardSpawner.wiggleTimer * LizardSpawner.wiggleSpeed) * LizardSpawner.wiggleAmplitude

        -- Draw centered with rotation and scaling
        local cx = LizardSpawner.x + LizardSpawner.size / 2
        local cy = LizardSpawner.y + LizardSpawner.size / 2
        love.graphics.draw(
            lizardImage,
            cx, cy,
            angle,
            lizardScale, lizardScale,
            lizardImageW / 2, lizardImageH / 2
        )

        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Check if mouse click hits the lizard bounding box
function LizardSpawner.isClicked(mx, my)
    local inside =
        LizardSpawner.visible and
        mx >= LizardSpawner.x and mx <= LizardSpawner.x + LizardSpawner.size and
        my >= LizardSpawner.y and my <= LizardSpawner.y + LizardSpawner.size

        -- print(string.format("Clicked at (%.1f, %.1f) | Box at (%.1f, %.1f, %d) → Inside: %s",
        -- mx, my, LizardSpawner.x, LizardSpawner.y, LizardSpawner.size, tostring(inside)))

    return inside
end

-- Calculate next randomized spawn interval
function LizardSpawner.getRandomLizardSpawnInterval()
    local minTime = math.max(0, lizardSpawnInterval - lizardSpawnIntervalVariance)
    local maxTime = lizardSpawnInterval + lizardSpawnIntervalVariance
    return math.random() * (maxTime - minTime) + minTime
end

-- Master control for spawning/fading lizard on timer
function LizardSpawner.checkLizard(dt)
    globals.lizardSpawnTimer = globals.lizardSpawnTimer - dt
    if LizardSpawner.visible then
        LizardSpawner.update(dt)

        local timeToFade = lizardSpawnInterval - LizardSpawner.visibleDuration - LizardSpawner.fadeDuration
        if globals.lizardSpawnTimer <= timeToFade and not LizardSpawner.fadingOut then
            LizardSpawner.hide()
        end

        if not LizardSpawner.visible then
            globals.lizardSpawnTimer = LizardSpawner.getRandomLizardSpawnInterval()
        end
    else
        if globals.lizardSpawnTimer <= 0 then
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
            globals.lizardSpawnTimer = lizardSpawnInterval
        end
    end
end

-- Handle mouse click on lizard
function LizardSpawner.mousepressed(x, y, button)
    if button == 1 then
        if LizardSpawner.isClicked(x, y) then
            --print("LIZARD CLICKED!")

            globals.lizardTailsOwned = globals.lizardTailsOwned + 1
            LizardSpawner.hideInstant()
            globals.lizardSpawnTimer = LizardSpawner.getRandomLizardSpawnInterval()

            local baseX = LizardSpawner.x + LizardSpawner.size / 2
            local baseY = LizardSpawner.y - 10

            FloatingText.spawn(baseX, baseY, "+1 Lizard Tail")
            FloatingText.spawn(baseX, baseY + 30, "Total Owned: " .. globals.lizardTailsOwned)
        end
    end
end

return LizardSpawner
