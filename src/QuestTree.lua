local QuestTree = {}

-- Load assets
local questSapling = love.graphics.newImage("assets/sprites/QuestSapling.png")
local questSaplingOutlined = love.graphics.newImage("assets/sprites/QuestSapling-Outlined.png")
local ingredientBox = love.graphics.newImage("assets/sprites/cauldron_slot.png") -- reuse for sapling text info box

-- World position
local x = globals.cauldronX + 1200
local y = globals.cauldronY + 500

-- State
local hovered = false
local selected = false
local ingredientBoxHovered = false
local showPotionPrompt = false

-- Constants
local textFont = love.graphics.newFont(31) -- size of text
local boxW = 500
local boxH = 250
local boxPadding = 20
local ingredientBoxW = ingredientBox:getWidth()
local ingredientBoxH = ingredientBox:getHeight()

function QuestTree.update(worldX, worldY)
    -- Tree hover
    local w = questSapling:getWidth()
    local h = questSapling:getHeight()

    hovered = worldX > x - w/2 and worldX < x + w/2 and
              worldY > y - h/2 and worldY < y + h/2

    -- Ingredient box hover
    if selected then
        local ibx = x
        local iby = y + 120
        ingredientBoxHovered = worldX > ibx - ingredientBoxW/2 and worldX < ibx + ingredientBoxW/2 and
                               worldY > iby - ingredientBoxH/2 and worldY < iby + ingredientBoxH/2
    else
        ingredientBoxHovered = false
    end
end

function QuestTree.mousepressed(worldX, worldY, button)
    if button ~= 1 then return end

    if hovered then
        selected = true
    elseif selected and ingredientBoxHovered then
        showPotionPrompt = true
    else
        selected = false
        showPotionPrompt = false
    end
end

function QuestTree.draw()
    -- Draw tree
    local treeImage = hovered and questSaplingOutlined or questSapling
    local w = treeImage:getWidth()
    local h = treeImage:getHeight()
    love.graphics.draw(treeImage, x, y, 0, 1, 1, w/2, h/2)

    if selected then
        -- Draw text box background
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", x - boxW/2, y - 350, boxW, boxH, 12, 12)
        love.graphics.setColor(1, 1, 1, 1)

        -- Draw text
        love.graphics.setFont(textFont)
        local fillerText = "A small page grows from a bud of this strange sapling.\nIt states \"This tree requires the utmost positivity; somthing that would be a joy to behold.\""
        love.graphics.printf(fillerText, x - boxW/2 + boxPadding, y - 350 + boxPadding, boxW - 2 * boxPadding)

        -- Draw ingredient box
        love.graphics.draw(ingredientBox, x, y + 150, 0, 1, 1, ingredientBoxW/2, ingredientBoxH/2)

        -- Draw prompt if clicked
        if showPotionPrompt then
            love.graphics.setFont(textFont)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Provide the correct potion", x - 150, y + 220, 300, "center") -- After-click text for potion box
        end
    end
end

return QuestTree
