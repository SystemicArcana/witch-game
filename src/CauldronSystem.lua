local CauldronSystem = {}

-- Assets loading
local cauldronSprite = love.graphics.newImage("assets/sprites/cauldron.png")
local cauldronHoveredSprite = love.graphics.newImage("assets/sprites/cauldron_witch.png")
local cauldronSelectedSprite = love.graphics.newImage("assets/sprites/cauldron_selected.png")
local cauldronSlotSprite = love.graphics.newImage("assets/sprites/cauldron_slot.png")
local pileEmptySprite = love.graphics.newImage({"assets/sprites/potion_stump_empty.png"})
local pileAvailSprite = love.graphics.newImage({"assets/sprites/potion_stump_avail.png"})
local pileSelectedSprite = love.graphics.newImage({"assets/sprites/potion_stump_selected.png"})
-- local variables
local cauldronStageImages = {
    [1] = love.graphics.newImage("assets/sprites/stage_1.png")
}
local cauldronHovered = false
local slotHovered = false
local slotW = cauldronSlotSprite:getWidth()
local slotH = cauldronSlotSprite:getHeight()

-- Potion Pile Variables
local pileHovered = false
local potionPileX = globals.cauldronX + 300
local potionPileY = globals.cauldronY
local pileW = pileEmptySprite:getWidth()
local pileH = pileEmptySprite:getHeight()

-- Imports
local CauldronUI = require("src.CauldronUI")

function CauldronSystem.update(worldX, worldY)
    CauldronSystem.setCauldronHovered(worldX, worldY)
    CauldronSystem.setSlotHovered(worldX, worldY)
    CauldronSystem.setPileHovered(worldX, worldY)
    CauldronSystem.setPourStatus()
    CauldronUI.update(worldX, worldY)
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

    -- Left slot 1 bounds
    local left1X = globals.cauldronX - 250
    local left1Y = globals.cauldronY
    -- Left slot 2 bounds
    local left2X = globals.cauldronX - 250
    local left2Y = globals.cauldronY + 200

    if worldX > left1X - ox and worldX < left1X + ox and
       worldY > left1Y - oy and worldY < left1Y + oy then
        slotHovered = "left1"
    elseif worldX > left2X - ox and worldX < left2X + ox and
           worldY > left2Y - oy and worldY < left2Y + oy then
        slotHovered = "left2"
    else
        slotHovered = false
    end
end

function CauldronSystem.setPileHovered(worldX, worldY)
    -- Set potionPile position
    local ox = pileW / 2
    local oy = pileH / 2

    if worldX > potionPileX - ox and worldX < potionPileX + ox and
       worldY > potionPileY - oy and worldY < potionPileY + oy then
        pileHovered = true
    else
        pileHovered = false
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
        ["none-none-wyrmroot"] = {1.0, 0.6, 0.6}, -- light red
        ["none-wyrmroot-wyrmroot"] = {0.8, 0.2, 0.2}, -- medium red
        ["wyrmroot-wyrmroot-wyrmroot"] = {0.5, 0.0, 0.0}, -- dark red
        -- Lycanlily
        ["none-none-lycanlily"] = {0.8, 0.6, 1.0}, -- light purple
        ["none-lycanlily-lycanlily"] = {0.6, 0.3, 0.8}, -- medium purple
        ["lycanlily-lycanlily-lycanlily"] = {0.4, 0.0, 0.4}, -- dark purple
        -- Wyrmroot/Lycanlily
        ["none-wyrmroot-lycanlily"] = {0.2, 0.8, 0.2}, -- medium green
        ["none-lycanlily-wyrmroot"] = {0.2, 0.8, 0.2}, -- medium green
        ["wyrmroot-lycanlily-lycanlily"] = {0.6, 1.0, 0.6}, -- light green
        ["lycanlily-lycanlily-wyrmroot"] = {0.6, 1.0, 0.6}, -- light green 
        ["lycanlily-wyrmroot-lycanlily"] = {0.6, 1.0, 0.6}, -- light green
        ["wyrmroot-wyrmroot-lycanlily"] = {0.0, 0.4, 0.0}, -- dark green
        ["wyrmroot-lycanlily-wyrmroot"] = {0.0, 0.4, 0.0}, -- dark green
        ["lycanlily-wyrmroot-wyrmroot"] = {0.0, 0.4, 0.0}, -- dark green     
        -- Add more combinations as needed
    }

    globals.brewState.color = comboColors[comboKey] or {0.3, 0.3, 0.3} -- fallback: murky gray
end

function CauldronSystem.setPourStatus()
    ings = globals.brewState.ingredients
    -- Stage 0 -> 1 requirements
    if globals.cauldronStage == 0 then
        globals.pourStatus =  ings[2] ~= "none" and ings[3] ~= "none"
    else 
        globals.pourStatus =  false
    end
end

function CauldronSystem.pourCauldron()
    globals.brewState.ingredients = {"none", "none", "none"}
    CauldronSystem.updateBrewColor()
    globals.cauldronStage = globals.cauldronStage + 1
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
    local img = (globals.cauldronSelected and cauldronSelectedSprite) or (cauldronHovered and cauldronHoveredSprite) or cauldronSprite
    local w = img:getWidth()
    local h = img:getHeight()
    love.graphics.draw(img, globals.cauldronX, globals.cauldronY, 0, 1, 1, w/2, h/2)
    -- Draw Cauldron UI
    if globals.cauldronSelected then
        CauldronUI.draw()
    end

    -- Draw Potion Pile
    if globals.cauldronStage > 0 then
        local img = (#globals.potionSlots == 0 and pileEmptySprite)
        or (globals.pileSelected == true and pileSelectedSprite)
        or pileAvailSprite
        local w = img:getWidth()
        local h = img:getHeight()
        love.graphics.draw(img, potionPileX, potionPileY, 0, 1, 1, w/2, h/2)

        if globals.pileSelected == true then
        -- Draw potion slots
        end
    end
end

function CauldronSystem.mousepressed(x, y, button)
    if button == 1 then -- left click
        if cauldronHovered or slotHovered or CauldronUI.buttonHovered then
            globals.cauldronSelected = true
        else
            globals.cauldronSelected = false
        end

        -- Pour Cauldron
        if CauldronUI.buttonHovered == "Pour" and globals.pourStatus == true then
            CauldronSystem.pourCauldron()
        end

        if slotHovered == "left1" and globals.resources[2].amount > 0 then
            CauldronSystem.addIngredientToBrew("lycanlily")
        elseif slotHovered == "left2" and globals.resources[1].amount > 0 then
            CauldronSystem.addIngredientToBrew("wyrmroot")
        end

        -- Stage 2 Mechanics
        if globals.cauldronStage > 0 then
            -- PotionPile
            if pileHovered then
                globals.pileSelected = true
            else
                globals.pileSelected = false
            end

            if CauldronUI.buttonHovered == "Bottle" then
                print("Bottling WIP")
                -- Bottle Function here
            end
        end
    end
end

return CauldronSystem