local CauldronSystem = {}
local CauldronUI = require("src.CauldronUI")

-- Assets loading
local cauldronSprite = love.graphics.newImage("assets/sprites/cauldron.png")
local cauldronHoveredSprite = love.graphics.newImage("assets/sprites/cauldron_witch.png")
local cauldronSelectedSprite = love.graphics.newImage("assets/sprites/cauldron_selected.png")
local cauldronSlotSprite = love.graphics.newImage("assets/sprites/cauldron_slot.png")

-- local variables
local cauldronStageImages = {
    [1] = love.graphics.newImage("assets/sprites/stage_1.png")
}
local cauldronSelected = false
local cauldronHovered = false
local slotHovered = false
local slotW = cauldronSlotSprite:getWidth()
local slotH = cauldronSlotSprite:getHeight()


function CauldronSystem.update(worldX, worldY)
    CauldronSystem.setCauldronHovered(worldX, worldY)
    CauldronSystem.setSlotHovered(worldX, worldY)
end

function CauldronSystem.setCauldronHovered(worldX, worldY) 
    local ox = cauldronSprite:getWidth() / 2
    local oy = cauldronSprite:getHeight() / 2

    -- Check mouse within bounds of image
    if worldX > globals.cauldronX - ox and worldX < globals.cauldronX + ox and
       worldY > globals.cauldronY - oy and worldY < globals.cauldronY + oy then
        cauldronHovered = true
    else
        cauldronHovered = false
    end
    return cauldronHovered
end

function CauldronSystem.setSlotHovered(worldX, worldY)
    local ox = slotW / 2
    local oy = slotH / 2

    local cauldronX = globals.cauldronX
    local cauldronY = globals.cauldronY

    -- Left slot bounds
    local leftX = globals.cauldronX - 250
    local rightX = globals.cauldronX + 200

    if worldX > leftX - ox and worldX < leftX + ox and
       worldY > cauldronY - oy and worldY < cauldronY + oy then
        slotHovered = "left"
    elseif worldX > rightX - ox and worldX < rightX + ox and
           worldY > cauldronY - oy and worldY < cauldronY + oy then
        slotHovered = "right"
    else
        slotHovered = false
    end
end

function CauldronSystem.addIngredientToBrew(ingredient)
    table.insert(globals.brewState.ingredients, ingredient)
    if ingredient == "wyrmroot" then
        globals.resources[1].amount = globals.resources[1].amount - 1
    elseif ingredient == "lycanlily" then
        globals.resources[2].amount = globals.resources[2].amount - 1
    end
    -- Keep only the last 3
    if #globals.brewState.ingredients > 3 then
        table.remove(globals.brewState.ingredients, 1)
    end

    CauldronSystem.updateBrewColor()
end

function CauldronSystem.updateBrewColor()
    local comboKey = table.concat(globals.brewState.ingredients, "-")
    local comboColors = {
        -- Wyrmroot
        ["none-none-wyrmroot"] = {0.6, 0.1, 0.8}, -- purple
        ["none-wyrmroot-wyrmroot"] = {0.2, 0.9, 0.2}, -- green
        ["wyrmroot-wyrmroot-wyrmroot"] = {1, 0.2, 0.2}, -- red
        -- Lycanlily
        ["none-none-lycanlily"] = {0.6, 0.1, 0.8}, -- purple
        ["none-lycanlily-lycanlily"] = {0.2, 0.9, 0.2}, -- green
        ["lycanlily-lycanlily-lycanlily"] = {1, 0.2, 0.2}, -- red
        -- Wyrmroot/Lycanlily
        ["none-wyrmroot-lycanlily"] = {0.6, 0.1, 0.8}, -- purple
        ["none-lycanlily-wyrmroot"] = {0.2, 0.9, 0.2}, -- green
        ["wyrmroot-lycanlily-lycanlily"] = {1, 0.2, 0.2}, -- red        
        -- Add more combinations as needed
    }

    globals.brewState.color = comboColors[comboKey] or {0.3, 0.3, 0.3} -- fallback: murky gray
end

function CauldronSystem.draw()
    -- Draw Cauldron Stage
    for i = 1, globals.cauldronStage do
        local img = cauldronStageImages[i]
        local w = img:getWidth()
        local h = img:getHeight()
        love.graphics.draw(img, globals.cauldronX, globals.cauldronY + 200, 0, 1, 1, w/2, h/2)
    end
    -- Draw Cauldron
    local img = (cauldronSelected and cauldronSelectedSprite) or (cauldronHovered and cauldronHoveredSprite) or cauldronSprite
    local w = img:getWidth()
    local h = img:getHeight()
    love.graphics.draw(img, globals.cauldronX, globals.cauldronY, 0, 1, 1, w/2, h/2)
    -- Draw Cauldron UI
    if cauldronSelected then
        CauldronUI.draw()
    end
    if slotHovered == "left" and cauldronSelected then
        love.graphics.print("Hovering left slot", 10, -50)
    elseif slotHovered == "right" and cauldronSelected then
        love.graphics.print("Hovering right slot", 10, -50)
    end
end

function CauldronSystem.mousepressed(x, y, button)
    if button == 1 then -- left click
        if cauldronHovered or slotHovered then
            cauldronSelected = true

            if slotHovered == "left" and globals.resources[2].amount > 0 then
                CauldronSystem.addIngredientToBrew("lycanlily")
            elseif slotHovered == "right" and globals.resources[1].amount > 0 then
                CauldronSystem.addIngredientToBrew("wyrmroot")
            end
        else
            cauldronSelected = false
        end
    end
end

return CauldronSystem