-- src/PotionStump.lua
local PotionStump  = {}
local globals      = require("src/globals")
local HoverTooltip = require("src/HoverTooltip")

-- ===============================
-- ASSETS
-- ===============================
local stumpEmptySprite    = love.graphics.newImage("assets/sprites/potion_stump_empty.png")
local stumpAvailSprite    = love.graphics.newImage("assets/sprites/potion_stump_avail.png")
local stumpSelectedSprite = love.graphics.newImage("assets/sprites/potion_stump_selected.png")
local slotSprite         = love.graphics.newImage("assets/sprites/cauldron_slot.png")
local bottleSprite       = love.graphics.newImage("assets/sprites/bottle.png")

-- ===============================
-- POSITIONING
-- ===============================
local stumpX = globals.cauldronX + 400
local stumpY = globals.cauldronY + 240
local stumpW = stumpEmptySprite:getWidth()
local stumpH = stumpEmptySprite:getHeight()

-- ===============================
-- SLOT LAYOUT
-- ===============================
local slotW, slotH   = slotSprite:getWidth(), slotSprite:getHeight()
local slotSpacing    = 30
local baseGap        = 20
local maxSlots       = 3

-- ===============================
-- STATE
-- ===============================
globals.draggingPotion = nil
globals.dragOrigin = nil

local stumpHovered    = false
local dragOffsetX, dragOffsetY = 0,0
local mouseX, mouseY = 0,0

-- ===============================
-- SET POTION SLOT POSITIONS
-- ===============================
local function getSlotPosition(i)
    -- X position: Slots appear to the right of the stump
    local x = stumpX + (stumpW / 2) + slotW / 2 + baseGap

    -- Y position:
    -- Bottom slot (i = 1) aligns its BOTTOM edge with stump's bottom edge, next slots stack upward.
    local bottomAlignY = stumpY + (stumpH / 2) - (slotH / 2)
    local y = bottomAlignY - (i - 1) * (slotH + slotSpacing)

    return x, y
end

-- ===============================
-- UPDATE
-- ===============================
function PotionStump.update(worldX, worldY, dt)
    mouseX, mouseY = worldX, worldY

    -- If no potions remain, auto-deselect stump
    local hasPotions = false
    for i = 1, maxSlots do
        if globals.potionSlots[i] then
            hasPotions = true
            break
        end
    end
    if not hasPotions then
        globals.stumpSelected = false
    end

    -- Hover detection (only if potions exist)
    if hasPotions then
        local ox, oy = stumpW / 2, stumpH / 2
        stumpHovered = worldX > stumpX - ox and worldX < stumpX + ox
                    and worldY > stumpY - oy and worldY < stumpY + oy
    else
        stumpHovered = false
    end
end

-- ===============================
-- MOUSE PRESSED
-- ===============================
function PotionStump.mousepressed(worldX, worldY, button)
    if button~=1 then return false end
    local clickedSlot=false
    for i=1,maxSlots do
        local x,y=getSlotPosition(i)
        if worldX>x-slotW/2 and worldX<x+slotW/2
        and worldY>y-slotH/2 and worldY<y+slotH/2 then
            clickedSlot=true
            break
        end
    end

    if stumpHovered then
        globals.stumpSelected=true
        return true
    end

    if globals.stumpSelected and clickedSlot then
        for i=1,maxSlots do
            local x,y=getSlotPosition(i)
            if globals.potionSlots[i]
            and worldX>x-slotW/2 and worldX<x+slotW/2
            and worldY>y-slotH/2 and worldY<y+slotH/2 then
                globals.draggingPotion=globals.potionSlots[i]
                globals.dragOrigin=i
                dragOffsetX=worldX-x
                dragOffsetY=worldY-y
                return true
            end
        end
    end

    globals.stumpSelected=false
    return false
end

-- ===============================
-- Count Potions - helper function for the bottle status check below.
-- ===============================
local function countPotions()
    local count = 0
    for i = 1, maxSlots do
        if globals.potionSlots[i] then
            count = count + 1
        end
    end
    return count
end

-- ===============================
-- BOTTLE STATUS CHECK: All 3 ingredients needed to bottle a potion - Maybe move this to CauldronSystem in the future?
-- ===============================
function PotionStump.bottleStatus()
    local potionSlotAvailable       = countPotions() < maxSlots
    local cauldronHasAllIngredients = globals.brewState.ingredients[1] ~= "none"
                                   and globals.brewState.ingredients[2] ~= "none"
                                   and globals.brewState.ingredients[3] ~= "none"
    return potionSlotAvailable and cauldronHasAllIngredients
end

-- ===============================
-- DRAW
-- ===============================
function PotionStump.draw()
    if globals.cauldronStage>0 then
        -- Stump
        local img = (#globals.potionSlots==0)
                    and stumpEmptySprite
                    or (stumpHovered or globals.stumpSelected)
                    and stumpSelectedSprite
                    or stumpAvailSprite
        love.graphics.draw(img,stumpX,stumpY,0,1,1,stumpW/2,stumpH/2)

        if globals.stumpSelected then
            for i=1,maxSlots do
                local x,y=getSlotPosition(i)
                love.graphics.draw(slotSprite,x,y,0,1,1,slotW/2,slotH/2)

                local potion = globals.potionSlots[i]
                if potion and (not globals.draggingPotion or globals.dragOrigin~=i) then
                    local PVC = potion.PVC
                    love.graphics.setColor((PVC[1]+8)/16,(PVC[2]+8)/16,(PVC[3]+8)/16)
                    love.graphics.draw(bottleSprite,x,y,0,1,1,
                                       bottleSprite:getWidth()/2,
                                       bottleSprite:getHeight()/2)
                    love.graphics.setColor(1,1,1)

                    local mouseOver = mouseX>x-slotW/2 and mouseX<x+slotW/2
                                   and mouseY>y-slotH/2 and mouseY<y+slotH/2
                    if mouseOver then
                        HoverTooltip.drawPVC({
                            widgetX      = x + 50, widgetY      = y,  -- Adjust spacing of tooltip here
                            align        = "right", tether = "widget",
                            name         = potion.name or "Unknown",
                            pvc          = PVC,
                            showNumericalValue = false
                        })
                    end
                end
            end
        end

        -- Dragging
        if globals.draggingPotion then
            local dx,dy = mouseX-dragOffsetX, mouseY-dragOffsetY
            local PVC = globals.draggingPotion.PVC
            love.graphics.setColor((PVC[1]+8)/16,(PVC[2]+8)/16,(PVC[3]+8)/16)
            love.graphics.draw(bottleSprite,dx,dy,0,1,1,
                               bottleSprite:getWidth()/2,
                               bottleSprite:getHeight()/2)
            love.graphics.setColor(1,1,1)
        end
    end
end

return PotionStump
