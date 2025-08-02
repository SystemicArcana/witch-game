local CauldronSystem = {}
local globals       = require("src/globals")
local CauldronUI    = require("src.CauldronUI")
local PotionStump   = require("src/PotionStump")
local Ascension     = require("src/Ascension")
local Objectives    = require("src/Objectives")
local DialogueBox   = require("src/DialogueBox")

-- Assets
local cauldronHoveredSprite  = love.graphics.newImage("assets/sprites/cauldron_witch.png")
local cauldronSlotSprite     = love.graphics.newImage("assets/sprites/cauldron_slot.png")

-- Stage visuals
local cauldronStageImages = {
    [1] = love.graphics.newImage("assets/sprites/stage_1.png"),
    [2] = love.graphics.newImage("assets/sprites/stage_2.png"),
}

-- Hover state
local slotHovered    = false
local rareSlotHovered = nil
local slotW, slotH   = cauldronSlotSprite:getWidth(), cauldronSlotSprite:getHeight()

-- Ingredient slots (always visible)
local ingredientSlots = {
    { id="left1", xOffset=-250, yOffset=  0 },
    { id="left2", xOffset=-250, yOffset=200 },
    { id="left3", xOffset=-250, yOffset=-200 },
}

-- ===============================
-- UPDATE
-- ===============================
function CauldronSystem.update(worldX, worldY, dt)
    CauldronSystem.setCauldronHovered(worldX, worldY)
    CauldronSystem.setSlotHovered(worldX, worldY)
    CauldronSystem.setPourStatus()
    CauldronUI.update(worldX, worldY)
    PotionStump.update(worldX, worldY, dt)
end

function CauldronSystem.setCauldronHovered(worldX, worldY)
    local ox, oy = cauldronHoveredSprite:getWidth() / 2, cauldronHoveredSprite:getHeight() / 2
    globals.cauldronHovered = worldX > globals.cauldronX - ox
                                  and worldX < globals.cauldronX + ox
                                  and worldY > globals.cauldronY - oy
                                  and worldY < globals.cauldronY + oy
    return globals.cauldronHovered
end

-- ===============================
-- INGREDIENT SLOT HOVERED
-- ===============================
function CauldronSystem.setSlotHovered(x, y)
    slotHovered = nil
    rareSlotHovered = nil

    for i, slot in ipairs(CauldronUI.getIngredientSlots()) do
        local sx = globals.cauldronX + slot.xOffset
        local sy = globals.cauldronY + slot.yOffset

        if x > sx - slotW / 2 and x < sx + slotW / 2 and
           y > sy - slotH / 2 and y < sy + slotH / 2 then
            slotHovered = i
            return
        end
    end

    for i, slot in ipairs(CauldronUI.getRareIngredientSlots()) do
        local sx = globals.cauldronX + slot.xOffset
        local sy = globals.cauldronY + slot.yOffset

        if x > sx - slotW / 2 and x < sx + slotW / 2 and
           y > sy - slotH / 2 and y < sy + slotH / 2 then
            rareSlotHovered = i
            return
        end
    end
end

-- ===============================
-- ADD INGREDIENTS TO BREW
-- ===============================
function CauldronSystem.addIngredientToBrew(ingredient)
    -- Add ingredient to the current brewState queue
    table.insert(globals.brewState.ingredients, ingredient)
    while #globals.brewState.ingredients > 3 do
        table.remove(globals.brewState.ingredients, 1)
    end
    while #globals.brewState.ingredients < 3 do
        table.insert(globals.brewState.ingredients, "none")
    end

    -- Deduct from resource list (check both standard and rare)
    local found = nil
    for _, r in ipairs(globals.resources) do
        if r.name:lower() == ingredient:lower() then
            r.amount = math.max(0, r.amount - 1)
            found = r
            break
        end
    end

    -- If not found in regular resources, check rare resources
    if not found then
        for _, r in ipairs(globals.rareResources) do
            if r.name:lower() == ingredient:lower() then
                r.amount = math.max(0, r.amount - 1)
                found = r
                break
            end
        end
    end

    -- ===============================
    -- TRACKING FOR ASCENSION REQUIREMENTS
    -- ===============================
    -- Increment total ingredients added
    globals.BrewStageData.totalIngredients = globals.BrewStageData.totalIngredients + 1

    -- Track unique ingredient (only add if not already present)
    if not globals.BrewStageData.uniqueIngredients[ingredient] then
        globals.BrewStageData.uniqueIngredients[ingredient] = true
    end

    -- Track rare ingredients (if flagged as rare)
    if found and found.rare then
        globals.BrewStageData.rareIngredientCount = globals.BrewStageData.rareIngredientCount + 1
    end

    -- Recalculate brew color and update BrewStageData color tracking
    globals.recalculateBrewPVC()
    local pvc = globals.brewState.PVC    
    CauldronSystem.updateBrewColor(pvc)
end

-- ===============================
-- UPDATE BREW COLOR
-- ===============================
function CauldronSystem.updateBrewColor(pvc)
    -- Compute the normalized color
    local newColor = {
        (pvc[1] + 8) / 16,
        (pvc[2] + 8) / 16,
        (pvc[3] + 8) / 16,
        1
    }

    -- TRACK COLOR HISTORY
    -- Represent color as a string key for easy comparison
    local colorKey = string.format("%.2f-%.2f-%.2f", newColor[1], newColor[2], newColor[3])

    -- Only count as a new color if it's not in history yet
    if not globals.BrewStageData.colorHistory[colorKey] then
        globals.BrewStageData.colorHistory[colorKey] = true
        globals.BrewStageData.colorChangeCount = globals.BrewStageData.colorChangeCount + 1
    end

    -- Apply the new color to the brew state
    globals.brewState.color = newColor
end

-- ===============================
-- POUR BUTTON STATUS - CAN IT BE CLICKED?
-- ===============================
function CauldronSystem.setPourStatus()
    local nextStage = globals.cauldronStage + 1

    -- If there's no next stage objective, pouring is disabled
    if not Objectives.ascension[nextStage] then
        globals.pourStatus = false
        return
    end

    -- Calculate unique ingredient count
    local uniqueCount = 0
    for _ in pairs(globals.BrewStageData.uniqueIngredients) do
        uniqueCount = uniqueCount + 1
    end

    -- Build the context table with all tracked metrics
    local context = {
        ingredients     = globals.BrewStageData.totalIngredients or 0,      -- Total number of ingredients added
        uniqueIngredients = uniqueCount,                                    -- Count of unique ingredients
        potions         = globals.BrewStageData.potionsBottled or 0,        -- Potions bottled this stage
        rareIngredients = globals.BrewStageData.rareIngredientCount or 0,   -- Rare ingredients count
        colorChanges    = globals.BrewStageData.colorChangeCount or 0       -- Number of brew color changes
    }

    -- Check if the objectives for the next stage are met
    globals.pourStatus = Objectives.checkAscension(nextStage, context)
end

-- ===============================
-- POUR / ASCENSION
-- ===============================
function CauldronSystem.pourCauldron()
    CauldronSystem.updateBrewColor({0,0,0}) -- Reset brew color (strictly visual) 
    Ascension.handleStageIncrease() -- Increment brew stage and everything else that comes with it || ASCENSION
end

-- ===============================
-- BOTTLING
-- ===============================
function CauldronSystem.bottlePotion()
    if not PotionStump.bottleStatus() then return end

    local pvc = globals.recalculateBrewPVC(true) -- true flag sets as return only, no changes are made to PVC by calling it this way
    local mood = CauldronSystem.getBrewMood()
    local prof = CauldronSystem.getProfileFromPVC(pvc)

    table.insert(globals.potionSlots,{
        name    = ("%s Potion of %s"):format(prof, mood),
        PVC     = pvc,
        mood    = mood,
        profile = prof
    })

    globals.brewState.ingredients = {"none","none","none"}
    CauldronSystem.updateBrewColor({0,0,0})
end

-- ===============================
-- Determine Brew Mood
-- ===============================
-- The mood is determined by the last ingredient added to the brew
function CauldronSystem.getBrewMood()
    -- Iterate ingredients in reverse order (last added → first)
    for i = #globals.brewState.ingredients, 1, -1 do
        local ing = globals.brewState.ingredients[i]

        -- Skip empty slots
        if ing ~= "none" then
            
            -- Search standard resources
            for _, r in ipairs(globals.resources) do
                if r.name:lower() == ing:lower() then
                    return r.mood or "Mystery"
                end
            end

            -- Search rare resources
            for _, r in ipairs(globals.rareResources) do
                if r.name:lower() == ing:lower() then
                    return r.mood or "Mystery"
                end
            end
        end
    end
    return "Mystery"    -- Fallback if no valid mood found (might happen later if only rare ingredients are used. Maybe a late game quest)
end


function CauldronSystem.getProfileFromPVC(pvc)
    local p,v,c = pvc[1], pvc[2], pvc[3]
    local key = (p>=0 and "+" or "-")
              ..(v>=0 and "+" or "-")
              ..(c>=0 and "+" or "-")
    local map = {
        ["+++"]="Surging", ["++-"]="Chaotic", ["+-+"]="Refined", ["+--"]="Crude",
        ["-++"]="Unstable",["-+-"]="Corrupted",["--+"]="Subtle",  ["---"]="Muddled"
    }
    return map[key] or "Unknown"
end

-- ===============================
-- DRAW
-- ===============================
function CauldronSystem.draw()
    -- For the cauldron stage background uner the cauldron
    for i=1,globals.cauldronStage do
        local img=cauldronStageImages[i]
        love.graphics.draw(img, globals.cauldronX, globals.cauldronY+200, 0,1,1, img:getWidth()/2, img:getHeight()/2)
    end

    -- Then draw the cauldron on top
    love.graphics.draw(cauldronHoveredSprite, globals.cauldronX, globals.cauldronY, 0,1,1, cauldronHoveredSprite:getWidth()/2, cauldronHoveredSprite:getHeight()/2)
end

-- ===============================
-- MOUSE PRESSED
-- ===============================
function CauldronSystem.mousepressed(x, y, button)
    if button ~= 1 then return end

    local over = CauldronSystem.setCauldronHovered(x, y)
    CauldronSystem.setSlotHovered(x, y)
    
    -- Buttons handling
    if CauldronUI.buttonHovered == "Pour" and globals.pourStatus then
        CauldronSystem.pourCauldron()
    end
    if CauldronUI.buttonHovered == "Bottle" then
        CauldronSystem.bottlePotion()
    end

    -- Handle clicking standard ingredients
    if slotHovered and globals.resources[slotHovered].amount > 0 then
        local ingredientName = CauldronUI.getIngredientSlots()[slotHovered].name
        CauldronSystem.addIngredientToBrew(ingredientName)
    end

    -- Handle clicking rare ingredients
    if rareSlotHovered and globals.rareResources[rareSlotHovered].amount > 0 then
        local ingredientName = CauldronUI.getRareIngredientSlots()[rareSlotHovered].name
        CauldronSystem.addIngredientToBrew(ingredientName)
    end

    local handled = PotionStump.mousepressed(x, y, button)
    if not handled then
        globals.stumpSelected = false
    end
end

return CauldronSystem
