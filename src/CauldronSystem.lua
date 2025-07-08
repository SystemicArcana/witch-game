local CauldronSystem = {}

-- Assets loading
local cauldronSprite = love.graphics.newImage("assets/sprites/cauldron.png")
local cauldronHoveredSprite = love.graphics.newImage("assets/sprites/cauldron_witch.png")
local cauldronSelectedSprite = love.graphics.newImage("assets/sprites/cauldron_selected.png")
local cauldronSlotSprite = love.graphics.newImage("assets/sprites/cauldron_slot.png")
local pileEmptySprite = love.graphics.newImage({"assets/sprites/potion_stump_empty.png"})
local pileAvailSprite = love.graphics.newImage({"assets/sprites/potion_stump_avail.png"})
local pileSelectedSprite = love.graphics.newImage({"assets/sprites/potion_stump_selected.png"})
local bottleSprite = love.graphics.newImage({"assets/sprites/bottle.png"})
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

local ingredientSlots = {
    { id = "left1", xOffset = -250, yOffset = 0 },
    { id = "left2", xOffset = -250, yOffset = 200 },
    { id = "left3", xOffset = -250, yOffset = -200 }
    -- Add more slots here easily
}

local potionPileSlots = {
    { id = "potion1", xOffset = 310, yOffset = -500 },
    { id = "potion2", xOffset = 310, yOffset = -300 },
    { id = "potion3", xOffset = 310, yOffset = -100 }
}

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
    slotHovered = false -- Default to no slot hovered

    for _, slot in ipairs(ingredientSlots) do
        local slotX = globals.cauldronX + slot.xOffset
        local slotY = globals.cauldronY + slot.yOffset

        if worldX > slotX - ox and worldX < slotX + ox and
           worldY > slotY - oy and worldY < slotY + oy then
            slotHovered = slot.id
            break
        end
    end
    for _, slot in ipairs(potionPileSlots) do
        local slotX = globals.cauldronX + slot.xOffset
        local slotY = globals.cauldronY + slot.yOffset

        if worldX > slotX - ox and worldX < slotX + ox and
           worldY > slotY - oy and worldY < slotY + oy then
            slotHovered = slot.id
            break
        end
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
    -- Decrease the amount of that ingredient in resources
    for _, resource in ipairs(globals.resources) do
        if resource.name:lower() == ingredient:lower() then
            resource.amount = math.max(0, resource.amount - 1)
            break
        end
    end

    -- Keep only the last 3
    if #globals.brewState.ingredients > 3 then
        table.remove(globals.brewState.ingredients, 1)
    end
    local pvc = CauldronSystem.getBrewPVC()
    CauldronSystem.updateBrewColor(pvc)
end

function CauldronSystem.updateBrewColor(pvc)

    local r = (pvc[1] + 8) / 16
    local g = (pvc[2] + 8) / 16
    local b = (pvc[3] + 8) / 16

    globals.brewState.color = {r, g, b, 1}
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
    local pvc = CauldronSystem.getBrewPVC()
    CauldronSystem.updateBrewColor(pvc)
    globals.cauldronStage = globals.cauldronStage + 1
end

function CauldronSystem.getBrewPVC()
    local total = {0, 0, 0}

    for _, ingName in ipairs(globals.brewState.ingredients) do
        if ingName ~= "none" then
            for _, resource in ipairs(globals.resources) do
                if resource.name:lower() == ingName:lower() then
                    for i = 1, 3 do
                        total[i] = total[i] + resource.PVC[i]
                    end
                    break
                end
            end
        end
    end

    return total -- {P, V, C}
end

function CauldronSystem.getBrewMood()
    for i = #globals.brewState.ingredients, 1, -1 do
        local ingName = globals.brewState.ingredients[i]
        if ingName ~= "none" then
            for _, resource in ipairs(globals.resources) do
                if resource.name:lower() == ingName:lower() then
                    return resource.mood or "Mystery"
                end
            end
        end
    end
    return "Mystery"
end

function CauldronSystem.getProfileFromPVC(pvc)
    local p, v, c = pvc[1], pvc[2], pvc[3]
    local sign = function(n) return (n >= 0) and "+" or "-" end

    local key = sign(p) .. sign(v) .. sign(c)

    local nameMap = {
        ["+++"] = "Surging",
        ["++-"] = "Chaotic",
        ["+-+"] = "Refined",
        ["+--"] = "Crude",
        ["-++"] = "Unstable",
        ["-+-"] = "Corrupted",
        ["--+"] = "Subtle",
        ["---"] = "Muddled"
    }

    return nameMap[key] or "Unknown"
end

function CauldronSystem.bottleStatus()
    local slotAvailable = #globals.potionSlots <= 2
    local ing1 = globals.brewState.ingredients[1] ~= "none"
    local ing2 = globals.brewState.ingredients[2] ~= "none"
    local ing3 = globals.brewState.ingredients[3] ~= "none"
    local hasIngredient = ing1 or ing2 or ing3
    return slotAvailable and hasIngredient
end

function CauldronSystem.bottleBrew()
    local pvc = CauldronSystem.getBrewPVC()
    local mood = CauldronSystem.getBrewMood()
    local profile = CauldronSystem.getProfileFromPVC(pvc)
    potionName = string.format("%s Potion of %s", profile, mood)
    potion = {name = potionName, PVC = pvc, mood = mood}
    table.insert(globals.potionSlots, potion)
    FloatingText.spawn(globals.cauldronX, globals.cauldronY, "Created " .. potionName)
    globals.brewState.ingredients = {"none", "none", "none"}
    pvc = CauldronSystem.getBrewPVC()
    CauldronSystem.updateBrewColor(pvc)
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

        if globals.pileSelected == true and #globals.potionSlots ~= 0 then
            for i, slot in ipairs(potionPileSlots) do
                local x = globals.cauldronX + slot.xOffset
                local y = globals.cauldronY + slot.yOffset
                local w = cauldronSlotSprite:getWidth()
                local h = cauldronSlotSprite:getHeight()

                love.graphics.draw(
                    cauldronSlotSprite,
                    x, y,
                    0, -- rotation
                    1, 1, -- scale
                    w / 2, h / 2 -- origin
                )
                -- Draw bottle if a potion exists at this index
                if globals.potionSlots[i] then
                    local bottleW = bottleSprite:getWidth()
                    local bottleH = bottleSprite:getHeight()
                    potionColor = {
                        (globals.potionSlots[i].PVC[1] + 8) / 16,
                        (globals.potionSlots[i].PVC[2] + 8) / 16,
                        (globals.potionSlots[i].PVC[3] + 8) / 16
                    }
                    love.graphics.setColor(potionColor)
                    love.graphics.draw(
                        bottleSprite,
                        x, y,
                        0, 1, 1,
                        bottleW / 2, bottleH / 2
                    )
                    love.graphics.setColor(1, 1, 1)
                end
            end
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
        elseif slotHovered == "left3" and globals.resources[3].amount > 0 then
            CauldronSystem.addIngredientToBrew("crimsonivy")
        end

        -- Stage 2 Mechanics
        if globals.cauldronStage > 0 then
            -- PotionPile
            if pileHovered then
                globals.pileSelected = true
            else
                globals.pileSelected = false
            end

            if CauldronUI.buttonHovered == "Bottle" and CauldronSystem.bottleStatus() then
                CauldronSystem.bottleBrew()
            end
        end
    end
end

return CauldronSystem