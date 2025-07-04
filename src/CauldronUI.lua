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
    -- Left Slot 2
    love.graphics.draw(
        cauldronSlotSprite,
        cauldronX - 250,
        cauldronY + 200,
        0,
        1, 1,
        slotW / 2,
        slotH / 2
    )
    if wyrmRootCount > 0 then
        -- Right Slot Resource: Wyrmroot
        love.graphics.draw(
            wyrmRootSprite,
            cauldronX - 250,
            cauldronY + 200,
            0,
            1, 1,
            slotW / 2,
            slotH / 2
        )
        local textW = font:getWidth(tostring(wyrmRootCount))
        local textH = font:getHeight()
        local textX = cauldronX - 250 + slotW / 2 - textW - 4
        local textY = cauldronY + 200 + slotH / 2 - textH - 2
        love.graphics.print(tostring(wyrmRootCount), textX, textY)
    end
    -- Pour / Bottle Buttons
    if globals.cauldronSelected then
        local button_w = 100
        local button_h = 40
        local pour_x = globals.cauldronX - button_w
        local button_y = globals.cauldronY + 400
        local button_spacing = 20
        local total_width = (button_w * 2) + button_spacing
        local font = love.graphics.getFont()
        -- Offset buttons if > Stage 1
        if globals.cauldronStage >= 1 then
            pour_x = globals.cauldronX - total_width / 2
            local bottle_x = pour_x + button_w + button_spacing
            love.graphics.setColor(0.2, 0.4, 0.8, 1)
            love.graphics.rectangle("fill", bottle_x, button_y, button_w, button_h)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(
                "Bottle", 
                bottle_x + (button_w - font:getWidth("Bottle")) / 2,
                button_y + (button_h - font:getHeight()) / 2
            )
        end
        love.graphics.setColor(0.2, 0.6, 0.2, 1)
        love.graphics.rectangle("fill", pour_x, button_y, button_w, button_h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(
            "Pour", 
            pour_x + (button_w - font:getWidth("Pour")) / 2,
            button_y + (button_h - font:getHeight()) / 2
        )
    end
        

love.graphics.setColor(1, 1, 1)
end

return CauldronUI