-- Spawns clickable lizard tail that fades in and out
-- Will avoid overlapping UI elements by checking against a list of blockers passed in from main.lua
ForageSystem = require("src.ForageSystem")
FloatingText = require("src.FloatingText")
globals = require("src.globals")

local LizardSpawner = {}
local lizardSpawnInterval = 4              -- base seconds between spawns
local lizardSpawnIntervalVariance = 2      -- +/- seconds variance

-- Configuration
LizardSpawner.size = 50
LizardSpawner.x = 0
LizardSpawner.y = 0
LizardSpawner.alpha = 0
LizardSpawner.visible = false
LizardSpawner.visibleDuration = 2
LizardSpawner.fadingIn = false
LizardSpawner.fadingOut = false
LizardSpawner.fadeDuration = 0.5 -- seconds
LizardSpawner.fadeTimer = 0

-- Axis-aligned bounding box overlap check
local function isOverlapping(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end

-- Attempt to spawn in a random location avoiding UI blockers
function LizardSpawner.spawn(blockers)
    local width, height = love.graphics.getDimensions()
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
            found = true
            break
        end
    end

    if not found then
        LizardSpawner.visible = false -- delay retry until next timer window
    end
end

-- Instantly hide the square (used on click)
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

-- Animate fade-in and fade-out
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
end

-- Draw the lizard tail square with current opacity
function LizardSpawner.draw()
    if LizardSpawner.visible then
        love.graphics.setColor(1, 1, 1, LizardSpawner.alpha)
        love.graphics.rectangle("fill", LizardSpawner.x, LizardSpawner.y, LizardSpawner.size, LizardSpawner.size)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Check if the player clicked the box
function LizardSpawner.isClicked(mx, my)
    return LizardSpawner.visible and
           mx >= LizardSpawner.x and mx <= LizardSpawner.x + LizardSpawner.size and
           my >= LizardSpawner.y and my <= LizardSpawner.y + LizardSpawner.size
end

function LizardSpawner.getRandomLizardSpawnInterval()
    local minTime = math.max(0, lizardSpawnInterval - lizardSpawnIntervalVariance)
    local maxTime = lizardSpawnInterval + lizardSpawnIntervalVariance
    return math.random() * (maxTime - minTime) + minTime
end

function LizardSpawner.checkLizard(dt)
    globals.lizardSpawnTimer = globals.lizardSpawnTimer - dt
    if LizardSpawner.visible then
        if LizardSpawner.fadingIn or LizardSpawner.fadingOut then
            LizardSpawner.update(dt)
        end
        
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

function LizardSpawner.mousepressed(x, y, button)
    if button == 1 then -- left click
        if LizardSpawner.isClicked(x, y) then
            globals.lizardTailsOwned = globals.lizardTailsOwned + 1
            LizardSpawner.hideInstant()
            lizardSpawnTimer = LizardSpawner.getRandomLizardSpawnInterval()

            local baseX = LizardSpawner.x + LizardSpawner.size / 2
            local baseY = LizardSpawner.y - 10

            -- +1 Lizard Tail text
            FloatingText.spawn(baseX, baseY, "+1 Lizard Tail")

            -- Total Owned text just below +1 text
            FloatingText.spawn(baseX, baseY + 15, "Total Owned: " .. globals.lizardTailsOwned)
        end
    end
end
return LizardSpawner
