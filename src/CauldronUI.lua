local CauldronUI = {}
globals = require("src/globals")
-- Assets Loading
local cauldronBrewSprite = love.graphics.newImage("assets/sprites/cauldron_brew.png")
local cauldronSlotSprite = love.graphics.newImage("assets/sprites/cauldron_slot.png")
local lycanLilySprite = love.graphics.newImage("assets/sprites/lycanlily.png")
local wyrmRootSprite = love.graphics.newImage("assets/sprites/wyrmroot.png")
local crimsonIvySprite = love.graphics.newImage("assets/sprites/crimson_ivy.png")
local w = cauldronBrewSprite:getWidth()
local h = cauldronBrewSprite:getHeight()
-- Pour/Bottle Button Variables
local button_w = 100
local button_h = 40
local button_y = globals.cauldronY + 300
local button_spacing = 5
local pour_x = globals.cauldronX - button_w + 15
local bottle_x = pour_x + button_w + button_spacing
local tooltipX = 0
local tooltipY = 0
local tooltipText = nil
CauldronUI.buttonHovered = nil
CauldronUI.pourEnabled = false


function CauldronUI.update(worldX, worldY)
    tooltipX = worldX
    tooltipY = worldY
    bottleXBounds = tooltipX > bottle_x and tooltipX < bottle_x + button_w
    pourXBounds = tooltipX > pour_x and tooltipX < pour_x + button_w
    buttonYBounds = tooltipY > button_y and tooltipY < button_y + button_h  
    if pourXBounds and buttonYBounds then
        tooltipText = "Pour the cauldron and ascend to greater heights."
        CauldronUI.buttonHovered = "Pour"
    elseif globals.cauldronStage > 0 then
        if bottleXBounds and buttonYBounds then
            tooltipText = "Store the potion in a bottle"
            CauldronUI.buttonHovered = "Bottle"
        else
            tooltipText = nil
            CauldronUI.buttonHovered = nil
        end
    else
        tooltipText = nil
        CauldronUI.buttonHovered = nil
    end
end

local function drawSlotWithResource(sprite, count, icon, x, y)
    local fontSize = 24
    local font = love.graphics.newFont(fontSize)
    local slotW = cauldronSlotSprite:getWidth()
    local slotH = cauldronSlotSprite:getHeight()
    love.graphics.setFont(font)

    -- Draw the slot background
    love.graphics.draw(sprite, x, y, 0, 1, 1, slotW / 2, slotH / 2)

    -- Draw the resource icon and count if available
    if count > 0 then
        love.graphics.draw(icon, x, y, 0, 1, 1, slotW / 2, slotH / 2)

        local text = tostring(count)
        local textW = font:getWidth(text)
        local textH = font:getHeight()
        local textX = x + slotW / 2 - textW - 4
        local textY = y + slotH / 2 - textH - 2

        love.graphics.print(text, textX, textY)
    end
    love.graphics.setFont(love.graphics.newFont())
end

function CauldronUI.draw()
    love.graphics.setColor(globals.brewState.color)
    love.graphics.draw(cauldronBrewSprite, globals.cauldronX, globals.cauldronY, 0, 1, 1, w/2, h/2)
    love.graphics.setColor(1, 1, 1)
    local cauldronX = globals.cauldronX
    local cauldronY = globals.cauldronY

    local lycanLilyCount = globals.resources[2].amount
    local wyrmRootCount = globals.resources[1].amount
    local crimsonIvyCount = globals.resources[3].amount


    -- Left Slot 1: Lycanlily
    drawSlotWithResource(cauldronSlotSprite, lycanLilyCount, lycanLilySprite, cauldronX - 250, cauldronY)
    -- Left Slot 2: Wyrmroot
    drawSlotWithResource(cauldronSlotSprite, wyrmRootCount, wyrmRootSprite, cauldronX - 250, cauldronY + 200)
    -- Left Slot 3: Crimson Ivy
    drawSlotWithResource(cauldronSlotSprite, crimsonIvyCount, crimsonIvySprite, cauldronX - 250, cauldronY - 200)

    -- Pour / Bottle Buttons
    local font = love.graphics.newFont(24)
    love.graphics.setFont(font)
    if globals.cauldronSelected then
        local total_width = (button_w * 2) + button_spacing
        -- Offset buttons if > Stage 1
        if globals.cauldronStage >= 1 then
            pour_x = (globals.cauldronX - total_width / 2) -100
            if require("src/CauldronSystem").bottleStatus() then
                love.graphics.setColor(0.2, 0.4, 0.8, 1)
            else
                -- Set gray if not bottleable
                love.graphics.setColor(0.6, 0.6, 0.6, 1)
            end
            love.graphics.rectangle("fill", bottle_x, button_y, button_w, button_h)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(
                "Bottle", 
                bottle_x + (button_w - font:getWidth("Bottle")) / 2,
                button_y + (button_h - font:getHeight()) / 2
            )
        end
        if globals.pourStatus == true then
            love.graphics.setColor(0.2, 0.6, 0.2, 1)
        else
            -- Set gray if not pourable
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
        end
        love.graphics.rectangle("fill", pour_x, button_y, button_w, button_h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(
            "Pour", 
            pour_x + (button_w - font:getWidth("Pour")) / 2,
            button_y + (button_h - font:getHeight()) / 2
        )
    end
    -- Tooltips
    if tooltipText then
        local padding = 6
        local textWidth = love.graphics.getFont():getWidth(tooltipText)
        local textHeight = love.graphics.getFont():getHeight()
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", tooltipX + 10, tooltipY + 10, textWidth + padding * 2, textHeight + padding * 2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tooltipText, tooltipX + 10 + padding, tooltipY + 10 + padding)
    end
love.graphics.setFont(love.graphics.newFont())
love.graphics.setColor(1, 1, 1)
end

return CauldronUI