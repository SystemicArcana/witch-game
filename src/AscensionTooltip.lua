-- src/AscensionTooltip.lua
local AscensionTooltip = {}

local globals     = require("src/globals")
local Objectives  = require("src/Objectives")

-- ===============================
-- ASSETS / SETTINGS
-- ===============================
local tooltipFont   = love.graphics.newFont(26)
local quantityFont  = love.graphics.newFont(22) -- Slightly smaller for quantities
local padding       = 10
local barHeight     = 10
local spacing       = 12  -- Space between each requirement block
local lineGap       = 3   -- Gap between the two rows of a requirement

-- Percent allocations for Row 2 layout (total = 1.0)
local percentLeftPadding  = 0.05
local percentRightPadding = 0.05
local percentGap          = 0.10
local percentCounter      = 0.20
local percentBar          = 0.60

-- ===============================
-- FUNCTION: Draw Ascension Tooltip
-- ===============================
function AscensionTooltip.draw(pourButtonX, pourButtonY, buttonW, buttonH)
    local nextStage = globals.cauldronStage + 1
    local objective = Objectives.ascension[nextStage]
    if not objective then return end

    -- ===============================
    -- BUILD CONTEXT (Current progress)
    -- ===============================
    local context = {
        ingredients     = globals.BrewStageData.totalIngredients or 0,
        uniqueCount     = 0,
        rareIngredients = globals.BrewStageData.rareIngredientCount or 0,
        colorChanges    = globals.BrewStageData.colorChangeCount or 0
    }

    if globals.BrewStageData.uniqueIngredients then
        for _ in pairs(globals.BrewStageData.uniqueIngredients) do
            context.uniqueCount = context.uniqueCount + 1
        end
    end

    -- ===============================
    -- DYNAMIC REQUIREMENTS LIST (Skip zero-value objectives)
    -- ===============================
    local requirements = {}

    if objective.ingredientsRequired and objective.ingredientsRequired > 0 then
        table.insert(requirements, {
            label    = "Total Ingredients",
            current  = context.ingredients,
            required = objective.ingredientsRequired
        })
    end

    if objective.uniqueIngredients and objective.uniqueIngredients > 0 then
        table.insert(requirements, {
            label    = "Unique Ingredients",
            current  = context.uniqueCount,
            required = objective.uniqueIngredients
        })
    end

    if objective.rareIngredients and objective.rareIngredients > 0 then
        table.insert(requirements, {
            label    = "Rare Ingredients",
            current  = context.rareIngredients,
            required = objective.rareIngredients
        })
    end

    if objective.colorChanges and objective.colorChanges > 0 then
        table.insert(requirements, {
            label    = "Color Changes",
            current  = context.colorChanges,
            required = objective.colorChanges
        })
    end

    if #requirements == 0 then return end

    -- ===============================
    -- CALCULATE TOOLTIP SIZE
    -- ===============================
    local maxTextWidth = 0
    for _, req in ipairs(requirements) do
        local labelWidth = tooltipFont:getWidth(req.label)
        if labelWidth > maxTextWidth then
            maxTextWidth = labelWidth
        end
    end

    local headingText = "Pour out the Brew"
    local headingHeight = tooltipFont:getHeight()

    -- Tooltip width = max label width + padding
    local contentWidth = maxTextWidth
    local row2Width    = contentWidth
    local boxW = padding * 2 + row2Width
    local boxH = headingHeight + padding + (#requirements * ((tooltipFont:getHeight() * 2) + barHeight + lineGap + spacing)) - spacing + padding * 2

    -- ===============================
    -- POSITION: Below Pour button
    -- ===============================
    local boxX = pourButtonX + buttonW - boxW  -- Right edge aligned
    local boxY = pourButtonY + buttonH + 30    -- Space below button

    -- ===============================
    -- DRAW BACKGROUND
    -- ===============================
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 6, 6)

    -- ===============================
    -- DRAW HEADING
    -- ===============================
    love.graphics.setFont(tooltipFont)
    love.graphics.setColor(0, 1, 0)
    love.graphics.print(headingText, boxX + padding, boxY + padding)


    -- Adjust Y position for requirements
    local currentY = boxY + padding + headingHeight + 10

    -- ===============================
    -- DRAW EACH REQUIREMENT
    -- ===============================
    for _, req in ipairs(requirements) do
        local current  = req.current or 0
        local required = req.required or 1
        local met      = current >= required

        -- === Row 1: Requirement Label ===
        love.graphics.setColor(met and {0, 1, 0} or {1, 0, 0})
        love.graphics.print(req.label, boxX + padding, currentY)

        currentY = currentY + tooltipFont:getHeight() + lineGap

        -- === Row 2: Counter + Progress Bar (proportional layout) ===
        local rowX = boxX + padding
        local rowWidth = row2Width

        -- Calculate proportional segments
        local leftPad   = rowWidth * percentLeftPadding
        local rightPad  = rowWidth * percentRightPadding
        local gapWidth  = rowWidth * percentGap
        local counterW  = rowWidth * percentCounter
        local barW      = rowWidth * percentBar

        local counterX = rowX + leftPad
        local barX     = counterX + counterW + gapWidth
        local barY     = currentY + (quantityFont:getHeight() / 2) - (barHeight / 2)

        -- Counter text
        love.graphics.setFont(quantityFont)
        love.graphics.setColor(1, 1, 1)
        local counter = string.format("%d / %d", current, required)
        local counterTextW = quantityFont:getWidth(counter)
        love.graphics.print(counter, counterX + (counterW - counterTextW) / 2, currentY)

        -- Progress bar background
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle("fill", barX, barY, barW, barHeight)

        -- Filled portion
        local fillWidth = current / required
        if fillWidth > 1 then fillWidth = 1 end
        love.graphics.setColor(0.2, 0.6, 0.2)
        love.graphics.rectangle("fill", barX, barY, barW * fillWidth, barHeight)

        -- Reset font for next label
        love.graphics.setFont(tooltipFont)

        -- Move Y for next requirement
        currentY = currentY + quantityFont:getHeight() + barHeight + spacing
    end

    -- Reset graphics state
    love.graphics.setFont(love.graphics.newFont())
    love.graphics.setColor(1, 1, 1)
end

return AscensionTooltip
