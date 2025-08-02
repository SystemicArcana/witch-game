local CauldronUI = {}

local globals          = require("src/globals")
local PotionStump      = require("src/PotionStump")
local HoverTooltip     = require("src/HoverTooltip")
local Objectives       = require("src/Objectives")
local AscensionTooltip = require("src/AscensionTooltip")

-- ===============================
-- ASSETS
-- ===============================
local cauldronBrewSprite = love.graphics.newImage("assets/sprites/cauldron_brew.png")
local cauldronSlotSprite = love.graphics.newImage("assets/sprites/cauldron_slot.png")

local lycanLilySprite    = love.graphics.newImage("assets/sprites/lycanlily.png")
local wyrmRootSprite     = love.graphics.newImage("assets/sprites/wyrmroot.png")
local crimsonIvySprite   = love.graphics.newImage("assets/sprites/crimson_ivy.png")

local lizardTailSprite   = love.graphics.newImage("assets/sprites/lizard_tail.png")
local questVoucherSprite = love.graphics.newImage("assets/sprites/quest_voucher.png")


local w = cauldronBrewSprite:getWidth()
local h = cauldronBrewSprite:getHeight()

-- ===============================
-- BUTTONS
-- ===============================
local button_w = 150
local button_h = 80

-- Position buttons centered vertically with the cauldron (slightly lower)
local button_y = globals.cauldronY - (button_h / 2)

-- Equal spacing from cauldron center
local button_offset = 260 -- tweak for desired horizontal distance

local pour_x = globals.cauldronX - button_w - button_offset
local bottle_x = globals.cauldronX + button_offset


-- ===============================
-- TOOLTIP STATE
-- ===============================
local tooltipParams = nil
local tooltipType   = nil

CauldronUI.buttonHovered = nil
CauldronUI.pourEnabled   = false

-- ===============================
-- INGREDIENT SLOTS
-- ===============================
local slotW, slotH = cauldronSlotSprite:getWidth(), cauldronSlotSprite:getHeight()
local slotSpacing = slotW + 30 -- horizontal spacing

local ingredientSlots = {
    { name="wyrmroot",   sprite=wyrmRootSprite,   xOffset=-slotSpacing, yOffset= h/2 + 80, index=1 },
    { name="lycanlily",  sprite=lycanLilySprite,  xOffset=0,            yOffset= h/2 + 80, index=2 },
    { name="crimsonivy", sprite=crimsonIvySprite, xOffset= slotSpacing, yOffset= h/2 + 80, index=3 }
}

local rareIngredientSlots = {
    { name="Lizard Tail",   sprite=lizardTailSprite,   xOffset=-slotSpacing, yOffset= h + 40, index=1 },
    { name="Quest Voucher", sprite=questVoucherSprite, xOffset=0,            yOffset= h + 40, index=2 }
}

-- ===============================
-- UPDATE
-- ===============================
function CauldronUI.update(worldX, worldY)
    -- Reset tooltip each frame
    tooltipParams = nil
    tooltipType   = nil
    CauldronUI.buttonHovered = nil

    -- Button Hover Checks
    local isHoveringPour   = worldX > pour_x   and worldX < pour_x + button_w
                          and worldY > button_y and worldY < button_y + button_h
    local isHoveringBottle = worldX > bottle_x and worldX < bottle_x + button_w
                          and worldY > button_y and worldY < button_y + button_h

    if isHoveringPour then
        CauldronUI.buttonHovered = "Pour"
    return

    elseif globals.cauldronStage > 0 and isHoveringBottle then
        if table.concat(globals.brewState.ingredients, ","):find("none") ~= nil then -- If missing any ingredients, set static tip (not PVC)
            globals.recalculateBrewPVC(true)
            tooltipParams = {
                lines              = {"Bottle the Brew","3 ingredients needed"},
                pvc                = globals.brewState.PVC or {0,0,0},
                colors             = {{0.2,0.8,0.2},{1,1,1}},
                widgetX            = bottle_x + button_w - 40, -- Horizontal positioning of tooltip
                widgetY            = button_y + button_h / 2 + 55,
                align              = "bottom",
                tether             = "widget",
                showNumericalValue = true
            }
            tooltipType = "generic"
            CauldronUI.buttonHovered = "Bottle"
            return
        else --If the brew has at least 3 ingredients, use PVC tooltip instead
            globals.recalculateBrewPVC(true)
            tooltipParams = {
                name               = "Bottle the Brew",
                pvc                = globals.brewState.PVC or {0,0,0},
                widgetX            = bottle_x + button_w - 35,
                widgetY            = button_y + button_h / 2 + 50,
                align              = "bottom",
                tether             = "widget",
                showNumericalValue = true
            }
            tooltipType = "pvc"
            CauldronUI.buttonHovered = "Bottle"
            return
        end
    end

    -- Standard Ingredient Hover Check
    for _, slot in ipairs(ingredientSlots) do
        local sx = globals.cauldronX + slot.xOffset
        local sy = globals.cauldronY + slot.yOffset
        local r = globals.resources[slot.index]

        -- Only proceed if player has at least one of this resource
        if r.amount > 0 then
            if worldX > sx - slotW/2 and worldX < sx + slotW/2
            and worldY > sy - slotH/2 and worldY < sy + slotH/2 then

                -- Combine name + mood
                local fullName = r.name
                if r.mood and r.mood ~= "" then
                    fullName = fullName .. " (" .. r.mood .. ")"
                end

                -- Build tooltip params
                tooltipParams = {
                    name               = fullName,
                    pvc                = r.PVC,
                    widgetX            = sx,
                    widgetY            = sy + slotH / 2 + 10,
                    align              = "bottom",
                    tether             = "widget",
                    showNumericalValue = true,
                }
                tooltipType = "pvc"
            end
        end
    end

    -- Rare Ingredient Hover Check
    for _, slot in ipairs(rareIngredientSlots) do
        local rr = globals.rareResources[slot.index]
        if rr.amount > 0 then                            -- ONLY UPDATE TOOLTIP FOR RARE INGREDIENTS IF PLAYER HAS ONE

            local sx = globals.cauldronX + slot.xOffset
            local sy = globals.cauldronY + slot.yOffset

            if worldX > sx - slotW/2 and worldX < sx + slotW/2
            and worldY > sy - slotH/2 and worldY < sy + slotH/2 then
                

                -- Combine name + mood
                local fullName = rr.name
                if rr.mood and rr.mood ~= "" then
                    fullName = fullName .. " (" .. rr.mood .. ")"
                end

                -- Build tooltip params
                tooltipParams = {
                    lines              = {fullName, ("Effect: " .. rr.effect)},
                    colors             = {{0.2,0.8,0.2},{1,1,1}},
                    pvc                = rr.PVC,
                    widgetX            = sx,
                    widgetY            = sy + slotH / 2 + 10,
                    align              = "bottom",
                    tether             = "widget",
                    showNumericalValue = true,
                }
                tooltipType = "generic"
            end
        end
    end
end

-- ===============================
-- DRAW SLOT WITH RESOURCE
-- ===============================
local function drawSlotWithResource(sprite, count, icon, x, y, tint)
    local font = love.graphics.newFont(30)
    love.graphics.setFont(font)
    local w, h = cauldronSlotSprite:getWidth(), cauldronSlotSprite:getHeight()

    -- Apply tint to slot background
    love.graphics.setColor(tint or {1, 1, 1, 1}) -- default white if no tint
    love.graphics.draw(sprite, x, y, 0, 1, 1, w/2, h/2)

    -- Draw icon and count if available
    if count > 0 then
        love.graphics.setColor(1, 1, 1, 1) -- reset color for icon
        love.graphics.draw(icon, x, y, 0, 1, 1, w/2, h/2)

        local txt = tostring(count)
        local tw, th = font:getWidth(txt), font:getHeight()
        love.graphics.print(txt, x + w/2 - tw - 4, y + h/2 - th - 2)
    end

    love.graphics.setFont(love.graphics.newFont())
    love.graphics.setColor(1, 1, 1, 1) -- reset after drawing
end

-- ===============================
-- DRAW MAIN UI
-- ===============================
function CauldronUI.draw()
    local cx, cy = globals.cauldronX, globals.cauldronY

    -- Brew
    love.graphics.setColor(globals.brewState.color)
    love.graphics.draw(cauldronBrewSprite, cx, cy, 0, 1, 1, w/2, h/2)
    love.graphics.setColor(1, 1, 1)

    -- Ingredient Slots (STANDARD RESOURCES)
    for _, slot in ipairs(ingredientSlots) do
        local x = cx + slot.xOffset
        local y = cy + slot.yOffset
        local resource = globals.resources[slot.index]

        love.graphics.setColor(1, 1, 1, 1)
        drawSlotWithResource(cauldronSlotSprite, resource.amount, slot.sprite, x, y)
    end

    -- Ingredient Slots (RARE RESOURCES)
    for _, slot in ipairs(rareIngredientSlots) do
        local x = cx + slot.xOffset
        local y = cy + slot.yOffset

        local rr = globals.rareResources[slot.index]
        if globals.discoveredRareResources[rr.name] then
            local goldenTint = {1, 0.84, 0.25, 1} -- Gold-like color
            drawSlotWithResource(cauldronSlotSprite, rr.amount, slot.sprite, x, y, goldenTint)
        end
    end

    -- Buttons
    local font = love.graphics.newFont(32)
    love.graphics.setFont(font)

    -- Bottle Button
    if globals.cauldronStage >= 1 then
        love.graphics.setColor(PotionStump.bottleStatus() and {0.2,0.4,0.8,1} or {0.6,0.6,0.6,1})
        love.graphics.rectangle("fill", bottle_x, button_y, button_w, button_h)
        love.graphics.setColor(1,1,1)
        love.graphics.print("Bottle", bottle_x + (button_w - font:getWidth("Bottle"))/2, button_y + (button_h - font:getHeight())/2)
    end

    -- Pour Button
    love.graphics.setColor(globals.pourStatus and {0.2,0.6,0.2,1} or {0.6,0.6,0.6,1})
    love.graphics.rectangle("fill", pour_x, button_y, button_w, button_h)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Pour", pour_x + (button_w - font:getWidth("Pour"))/2, button_y + (button_h - font:getHeight())/2)

    -- ===============================
    -- Progress Bar under Bottle
    -- ===============================
    if globals.cauldronStage >= 1 then
        -- Determine how many ingredients are present in the current brew
        local filled = 0
        for _, ing in ipairs(globals.brewState.ingredients) do
            if ing ~= "none" then filled = filled + 1 end
        end

        -- Bar positioning and dimensions
        local bar_x = bottle_x
        local bar_y = button_y + button_h + 10 -- below the button
        local bar_width = button_w
        local bar_height = 12
        local sections = 3
        local section_width = bar_width / sections

        -- Draw empty section outlines
        love.graphics.setColor(0.6,0.6,0.6)
        for i=0,sections-1 do
            love.graphics.rectangle("line", bar_x + i*section_width, bar_y, section_width-2, bar_height)
        end

        -- Draw filled sections
        love.graphics.setColor(0.2,0.4,0.8)
        for i=0,math.min(filled, sections)-1 do
            love.graphics.rectangle("fill", bar_x + i*section_width, bar_y, section_width-2, bar_height)
        end

        love.graphics.setColor(1,1,1)
    end

    -- ===============================
    -- Dynamic Progress Bar under Pour (Multi-Section)
    -- ===============================
    do
        local nextStage = globals.cauldronStage + 1
        local objective = Objectives.ascension[nextStage]

        if objective then
            -- Build context from BrewStageData
            local context = {
                ingredients     = globals.BrewStageData.totalIngredients or 0,
                uniqueCount     = 0,
                rareIngredients = globals.BrewStageData.rareIngredientCount or 0,
                colorChanges    = globals.BrewStageData.colorChangeCount or 0
            }
            for _ in pairs(globals.BrewStageData.uniqueIngredients) do
                context.uniqueCount = context.uniqueCount + 1
            end

            -- Build criteria dynamically
            local criteria = {}
            if objective.ingredientsRequired and objective.ingredientsRequired > 0 then
                table.insert(criteria, { label = "Ingredients", met = context.ingredients >= objective.ingredientsRequired })
            end
            if objective.uniqueIngredients and objective.uniqueIngredients > 0 then
                table.insert(criteria, { label = "Unique", met = context.uniqueCount >= objective.uniqueIngredients })
            end
            if objective.rareIngredients and objective.rareIngredients > 0 then
                table.insert(criteria, { label = "Rare", met = context.rareIngredients >= objective.rareIngredients })
            end
            if objective.colorChanges and objective.colorChanges > 0 then
                table.insert(criteria, { label = "Color", met = context.colorChanges >= objective.colorChanges })
            end

            -- Bar positioning
            local bar_x = pour_x
            local bar_y = button_y + button_h + 10
            local bar_width = button_w
            local bar_height = 12
            local sections = #criteria
            local section_width = bar_width / sections

            -- Draw section outlines
            love.graphics.setColor(0.6, 0.6, 0.6)
            for i = 0, sections - 1 do
                love.graphics.rectangle("line", bar_x + i * section_width, bar_y, section_width - 2, bar_height)
            end

            -- Draw filled sections for completed requirements
            love.graphics.setColor(0.2, 0.6, 0.2)
            for i, c in ipairs(criteria) do
                if c.met then
                    love.graphics.rectangle("fill", bar_x + (i - 1) * section_width, bar_y, section_width - 2, bar_height)
                end
            end

            -- Reset color
            love.graphics.setColor(1, 1, 1)
        end
    end

    -- ===============================
    -- Ascension Tooltip for Pour Button
    -- Only show when hovering Pour
    -- ===============================
    if CauldronUI.buttonHovered == "Pour" then
        AscensionTooltip.draw(pour_x, button_y, button_w, button_h)
    end

    -- Tooltip
    if tooltipParams then
        if tooltipType == "generic" then
            HoverTooltip.drawGeneric(tooltipParams)
        else
            HoverTooltip.drawPVC(tooltipParams)
        end
    end

    love.graphics.setFont(love.graphics.newFont())
    love.graphics.setColor(1,1,1)
end

function CauldronUI.getIngredientSlots()
    return ingredientSlots
end

function CauldronUI.getRareIngredientSlots()
    return rareIngredientSlots
end

return CauldronUI