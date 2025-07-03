local CauldronUI = {}
globals = require("src/globals")
-- Assets Loading
local cauldronBrewSprite = love.graphics.newImage("assets/sprites/cauldron_brew.png")
local cauldronSlotSprite = love.graphics.newImage("assets/sprites/cauldron_slot.png")
local lycanLilySprite = love.graphics.newImage("assets/sprites/lycanlily.png")
local wyrmRootSprite = love.graphics.newImage("assets/sprites/wyrmroot.png")
local w = cauldronBrewSprite:getWidth()
local h = cauldronBrewSprite:getHeight()
function CauldronUI.draw()
    love.graphics.setColor(globals.brewState.color)
    love.graphics.draw(cauldronBrewSprite, globals.cauldronX, globals.cauldronY, 0, 1, 1, w/2, h/2)
    love.graphics.setColor(1, 1, 1)
    local fontSize = 24
    local slotW = cauldronSlotSprite:getWidth()
    local slotH = cauldronSlotSprite:getHeight()

    local cauldronX = globals.cauldronX
    local cauldronY = globals.cauldronY

    local lycanLilyCount = globals.resources[2].amount
    local wyrmRootCount = globals.resources[1].amount
    local defaultFont = love.graphics.getFont()
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    -- Left Slot 1
    love.graphics.draw(
        cauldronSlotSprite,
        cauldronX - 250,
        cauldronY,
        0,
        1, 1,
        slotW / 2,
        slotH / 2
    )
    if lycanLilyCount > 0 then
        -- Left Slot Resource: Lycanlily
        love.graphics.draw(
            lycanLilySprite,
            cauldronX - 250,
            cauldronY,
            0,
            1, 1,
            slotW / 2,
            slotH / 2
        )
        local textW = font:getWidth(tostring(lycanLilyCount))
        local textH = font:getHeight()
        local textX = cauldronX - 250 + slotW / 2 - textW - 4
        local textY = cauldronY + slotH / 2 - textH - 2
        love.graphics.print(tostring(lycanLilyCount), textX, textY)
    end
    -- Right Slot 1
    love.graphics.draw(
        cauldronSlotSprite,
        cauldronX + 200,
        cauldronY,
        0,
        1, 1,
        slotW / 2,
        slotH / 2
    )
    if wyrmRootCount > 0 then
        -- Right Slot Resource: Wyrmroot
        love.graphics.draw(
            wyrmRootSprite,
            cauldronX + 200,
            cauldronY,
            0,
            1, 1,
            slotW / 2,
            slotH / 2
        )
        local textW = font:getWidth(tostring(wyrmRootCount))
        local textH = font:getHeight()
        local textX = cauldronX + 200 + slotW / 2 - textW - 4
        local textY = cauldronY + slotH / 2 - textH - 2
        love.graphics.print(tostring(wyrmRootCount), textX, textY)
    end
    love.graphics.setFont(defaultFont)
end

return CauldronUI