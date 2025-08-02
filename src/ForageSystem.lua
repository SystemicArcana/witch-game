local ForageSystem = {}
local globals = require("src/globals")

-- ===============================
-- ASSETS
-- ===============================
local forestSprite = love.graphics.newImage("assets/sprites/forage_forest_default.png")

-- ===============================
-- CONFIGURATION
-- ===============================
ForageSystem.baseTicks = 40
ForageSystem.tickRate = 0.05

-- Fonts
local buttonFont = love.graphics.newFont(40)

-- ===============================
-- INITIALIZATION
-- ===============================
function ForageSystem.init()
    local imgW, imgH = forestSprite:getWidth(), forestSprite:getHeight()
    ForageSystem.forestX = globals.cauldronX
    ForageSystem.forestY = 1600
    ForageSystem.forestW = imgW
    ForageSystem.forestH = imgH

    -- Button dimensions
    ForageSystem.buttonW = 320
    ForageSystem.buttonH = 100
    ForageSystem.progressH = 18
    ForageSystem.paddingTopText = 12
    ForageSystem.paddingBottomBar = 12

    -- Spread buttons across 60% of image width
    local totalSpacing = ForageSystem.forestW * 0.6
    local startX = ForageSystem.forestX - totalSpacing / 2
    local gap = totalSpacing / (#globals.resources - 1)

    ForageSystem.buttons = {}
    ForageSystem.selected = nil
    ForageSystem.queued = nil
    ForageSystem.tickTimer = 0
    ForageSystem.progress = {}
    ForageSystem.progressDisplay = {} -- smooth animation
    ForageSystem.targetTicks = {}

    local y = ForageSystem.forestY - ForageSystem.forestH / 4 + 60
    for i = 1, #globals.resources do
        local x = startX + (i - 1) * gap - ForageSystem.buttonW / 2
        ForageSystem.buttons[i] = { x = x, y = y }
        ForageSystem.progress[i] = 0
        ForageSystem.progressDisplay[i] = 0
        ForageSystem.targetTicks[i] = math.floor(ForageSystem.baseTicks * (1.5 ^ (i - 1)))
    end
end
ForageSystem.init()

-- ===============================
-- UPDATE
-- ===============================
function ForageSystem.update(dt)
    -- Smooth progress interpolation
    for i = 1, #globals.resources do
        ForageSystem.progressDisplay[i] = ForageSystem.progressDisplay[i] +
            (ForageSystem.progress[i] - ForageSystem.progressDisplay[i]) * (10 * dt)
    end

    -- Foraging logic: continuous charging
    if ForageSystem.selected then
        ForageSystem.tickTimer = ForageSystem.tickTimer - dt
        if ForageSystem.tickTimer <= 0 then
            ForageSystem.tickTimer = ForageSystem.tickRate
            local i = ForageSystem.selected
            ForageSystem.progress[i] = ForageSystem.progress[i] + 1
            if ForageSystem.progress[i] >= ForageSystem.targetTicks[i] then
                globals.resources[i].amount = globals.resources[i].amount + 1
                ForageSystem.progress[i] = 0
                -- Switch to queued if present, else continue same resource
                if ForageSystem.queued then
                    ForageSystem.selected = ForageSystem.queued
                    ForageSystem.queued = nil
                end
            end
        end
    end
end

-- ===============================
-- INPUT
-- ===============================
function ForageSystem.mousepressed(x, y, button)
    if button ~= 1 then return end
    for i, btn in ipairs(ForageSystem.buttons) do
        if x >= btn.x and x <= btn.x + ForageSystem.buttonW and y >= btn.y and y <= btn.y + ForageSystem.buttonH then
            if ForageSystem.selected == i then
                ForageSystem.queued = nil -- deselect queued
            elseif ForageSystem.selected then
                ForageSystem.queued = i -- queue if something else active
            else
                ForageSystem.selected = i
                ForageSystem.queued = nil
                ForageSystem.tickTimer = ForageSystem.tickRate
                ForageSystem.progress[i] = 0
            end
            return
        end
    end
end

-- ===============================
-- DRAW
-- ===============================
function ForageSystem.draw()
    -- Draw forest
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(forestSprite, ForageSystem.forestX, ForageSystem.forestY, 0, 1, 1,
        ForageSystem.forestW / 2, ForageSystem.forestH / 2)

    for i, btn in ipairs(ForageSystem.buttons) do
        local res = globals.resources[i]
        local bx, by = btn.x, btn.y

        -- Button background
        love.graphics.setColor(res.color)
        love.graphics.rectangle("fill", bx, by, ForageSystem.buttonW, ForageSystem.buttonH, 10, 10)

        -- Button border states
        if ForageSystem.selected == i then
            -- Active → solid white border
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(6)
            love.graphics.rectangle("line", bx, by, ForageSystem.buttonW, ForageSystem.buttonH, 10, 10)
        elseif ForageSystem.queued == i then
            -- Queued → red border
            love.graphics.setColor(1, 0.2, 0.2)
            love.graphics.setLineWidth(6)
            love.graphics.rectangle("line", bx, by, ForageSystem.buttonW, ForageSystem.buttonH, 10, 10)
        end

        -- Reset line width before drawing progress bar
        love.graphics.setLineWidth(2)

        -- Resource text (top)
        love.graphics.setFont(buttonFont)
        local text = res.name
        local textX = bx
        local textY = by + ForageSystem.paddingTopText
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(text, textX, textY, ForageSystem.buttonW, "center")

        -- Progress bar (bottom)
        local pbX = bx + 12
        local pbY = by + ForageSystem.buttonH - ForageSystem.progressH - ForageSystem.paddingBottomBar
        local pbW = ForageSystem.buttonW - 24
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", pbX, pbY, pbW, ForageSystem.progressH, 6, 6)
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle("line", pbX, pbY, pbW, ForageSystem.progressH, 6, 6)

        if ForageSystem.selected == i then
            local fillW = (ForageSystem.progressDisplay[i] / ForageSystem.targetTicks[i]) * (pbW - 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", pbX + 2, pbY + 2, fillW, ForageSystem.progressH - 4, 6, 6)
        end
    end

    love.graphics.setColor(1, 1, 1)
end

return ForageSystem
