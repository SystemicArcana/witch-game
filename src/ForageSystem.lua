-- Foraging Time!
-- Clicking the foraging menu expands it, allowing you to select a resource to forage. 
-- Foraging menu can be closed by clicking anywhere else.
-- Progress bar charges, collecting the resource that had been selected when the bar had started charging.
-- If another resource is selected it is 'queued' for next resource to be collected
-- Bar color matches the resource being charged

local ForageSystem = {}
globals = require("src/globals")
-- Basic UI setup
ForageSystem.forageButtonX = 860
ForageSystem.forageButtonY = 100
ForageSystem.forageButtonWidth = 380
ForageSystem.forageButtonHeight = 42
ForageSystem.forageButtonVisible = true

-- Menu state
ForageSystem.active = false
ForageSystem.maxVisibleItems = 4


ForageSystem.selected = nil
ForageSystem.queued = nil

-- Progress bar logic
ForageSystem.tickRate = 0.05
ForageSystem.baseTicks = 40
ForageSystem.tickTimer = 0
ForageSystem.progress = 0
ForageSystem.targetTicks = 0

-- Floating text support
local floatingTexts = {}
local floatingTextDuration = 1.5

function ForageSystem.toggleMenu()
    ForageSystem.active = not ForageSystem.active
end

function ForageSystem.update(dt)
    ForageSystem.tickTimer = ForageSystem.tickTimer - dt

    if ForageSystem.selected then
        if ForageSystem.tickTimer <= 0 then
            ForageSystem.tickTimer = ForageSystem.tickRate
            ForageSystem.progress = ForageSystem.progress + 1

            if ForageSystem.progress >= ForageSystem.targetTicks then
                globals.resources[ForageSystem.selected].amount = globals.resources[ForageSystem.selected].amount + 1
                local resName = globals.resources[ForageSystem.selected].name
                spawnFloatingText("+1 " .. resName, -10)

                ForageSystem.progress = 0

                if ForageSystem.queued then
                    ForageSystem.selected = ForageSystem.queued
                    ForageSystem.queued = nil
                    ForageSystem.targetTicks = math.floor(ForageSystem.baseTicks * (1.5 ^ (ForageSystem.selected - 1)))
                    spawnFloatingText("Foraging for " .. globals.resources[ForageSystem.selected].name, 5)
                end
            end
        end
    end

    for i = #floatingTexts, 1, -1 do
        local ft = floatingTexts[i]
        ft.lifetime = ft.lifetime - dt
        ft.y = ft.y - 30 * dt
        local half = floatingTextDuration / 2
        ft.alpha = ft.lifetime > half and 1 or ft.lifetime / half
        if ft.lifetime <= 0 then
            table.remove(floatingTexts, i)
        end
    end
end

function spawnFloatingText(text, offset)
    table.insert(floatingTexts, {
        x = ForageSystem.forageButtonX + ForageSystem.forageButtonWidth / 2,
        y = ForageSystem.forageButtonY + offset,
        alpha = 1,
        lifetime = floatingTextDuration,
        text = text
    })
end

function ForageSystem.mousepressed(x, y, button)
    if button == 1 then
        local menuX = ForageSystem.forageButtonX
        local menuY = ForageSystem.forageButtonY
        local menuW = ForageSystem.forageButtonWidth
        local menuH = ForageSystem.forageButtonHeight + 10 + (ForageSystem.active and 270 or 10)

        local clickedLizard = require("src.LizardSpawner").isClicked(x, y)

        if ForageSystem.active then
            local scrollY = menuY + ForageSystem.forageButtonHeight + 10 + 20
            for i, res in ipairs(globals.resources) do
                local col = (i - 1) % 2
                local row = math.floor((i - 1) / 2)
                local bw = (menuW - 30) / 2
                local bx = menuX + 10 + col * (bw + 10)
                local by = scrollY + row * 50
                local bh = 40
                if y >= by and y <= by + bh and x >= bx and x <= bx + bw then
                    if ForageSystem.selected == i then
                        ForageSystem.queued = nil
                    elseif ForageSystem.selected then
                        ForageSystem.queued = i
                    else
                        ForageSystem.selected = i
                        ForageSystem.targetTicks = math.floor(ForageSystem.baseTicks * (1.5 ^ (i - 1)))
                        ForageSystem.tickTimer = ForageSystem.tickRate
                        ForageSystem.progress = 0
                        spawnFloatingText("Foraging for " .. res.name, 5)
                    end
                    return
                end
            end
        end

        local insideButton = x >= menuX and x <= menuX + menuW and
                             y >= menuY and y <= menuY + menuH

        if insideButton then
            ForageSystem.active = not ForageSystem.active
        elseif not clickedLizard then
            ForageSystem.active = false
        end
    end
end

function ForageSystem.draw()
    local menuX = ForageSystem.forageButtonX
    local menuY = ForageSystem.forageButtonY
    local menuW = ForageSystem.forageButtonWidth
    local menuH = ForageSystem.forageButtonHeight + 10 + (ForageSystem.active and 270 or 10)

    love.graphics.setColor(0.1, 0.4, 0.1)
    love.graphics.rectangle("fill", menuX, menuY, menuW, menuH, 6, 6)
    love.graphics.setColor(0, 0.2, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", menuX, menuY, menuW, menuH, 6, 6)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.printf("Foraging", menuX, menuY + 10, menuW, "center")

    for _, ft in ipairs(floatingTexts) do
        love.graphics.setColor(1, 1, 1, ft.alpha)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(ft.text)
        love.graphics.print(ft.text, ft.x - textWidth / 2, ft.y)
    end

    local ph = ForageSystem.active and 20 or 10
    local barPadding = 30
    local pw = menuW - barPadding
    local px = menuX + barPadding / 2
    local py = menuY + ForageSystem.forageButtonHeight + 10

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", px, py, pw, ph)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", px, py, pw, ph)

    if ForageSystem.selected then
        local fillW = (ForageSystem.progress / ForageSystem.targetTicks) * pw
        local color = globals.resources[ForageSystem.selected].color
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", px, py, fillW, ph)
    end

    if ForageSystem.active then
        local scrollY = py + ph + 10
        for i, res in ipairs(globals.resources) do
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            local bw = (menuW - 30) / 2
            local bx = menuX + 10 + col * (bw + 10)
            local by = scrollY + row * 50
            local bh = 40

            love.graphics.setColor(res.color)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", bx, by, bw, bh, 4, 4)

            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(love.graphics.newFont(16))
            love.graphics.print(res.amount, bx + 8, by + 10)
            love.graphics.print(res.name, bx + 40, by + 10)

            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(1)
            love.graphics.circle("line", bx + bw - 20, by + bh / 2, 8)
            if ForageSystem.selected == i then
                love.graphics.circle("fill", bx + bw - 20, by + bh / 2, 4)
            elseif ForageSystem.queued == i then
                love.graphics.setColor(1, 0, 0)
                love.graphics.circle("fill", bx + bw - 20, by + bh / 2, 4)
            end
        end
    end
    -- Reset color for use elsewhere
    love.graphics.setColor(1, 1, 1)
end

return ForageSystem