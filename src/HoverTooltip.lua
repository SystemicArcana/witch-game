-- src/HoverTooltip.lua
local HoverTooltip = {}

-- ===============================
-- ASSETS / SETTINGS
-- ===============================
local tooltipFont = love.graphics.newFont(28)
local padding     = 10
local wrapLimit   = 30 -- max characters before wrapping

-- ===============================
-- HELPER: Calculate position with cardinal alignment
-- ===============================
local function calculatePosition(params, boxW, boxH)
    local align  = params.align or "right"
    local tether = params.tether or "mouse"
    local x, y = 0, 0

    if tether == "mouse" then
        x = params.x or 0
        y = params.y or 0
    else -- widget
        x = params.widgetX or params.x or 0
        y = params.widgetY or params.y or 0
    end

    if align == "left" then
        return x - boxW - 15, y - boxH/2
    elseif align == "right" then
        return x + 15, y - boxH/2
    elseif align == "top" then
        return x - boxW/2, y - boxH - 15
    elseif align == "bottom" then
        return x - boxW/2, y + 15
    else
        return x + 15, y - boxH/2
    end
end

-- ===============================
-- HELPER: Text Wrapping
-- Splits a line into chunks of max wrapLimit chars (tries to break at spaces)
-- ===============================
local function wrapText(line)
    local wrapped = {}
    while #line > wrapLimit do
        local breakPos = wrapLimit
        -- Find last space before wrapLimit
        for i = wrapLimit, 1, -1 do
            if line:sub(i, i) == " " then
                breakPos = i
                break
            end
        end
        table.insert(wrapped, line:sub(1, breakPos))
        line = line:sub(breakPos + 1):match("^%s*(.*)") -- trim leading space
    end
    if #line > 0 then table.insert(wrapped, line) end
    return wrapped
end

-- ===============================
-- HELPER: Draw colored PVC
-- ===============================
local function drawColoredPVC(pvc, startX, startY, showValues)
    local labels = { "P", "V", "C" }
    love.graphics.setFont(tooltipFont)
    local x = startX

    for i = 1, 3 do
        local val   = tonumber(pvc[i]) or 0
        local sign  = (val >= 0) and "+" or "-"
        local color = (val >= 0) and {0,1,0} or {1,0,0}
        local text  = showValues
                        and (labels[i] .. sign .. math.abs(val))
                        or (labels[i] .. sign)

        love.graphics.setColor(color)
        love.graphics.print(text, x, startY)
        x = x + tooltipFont:getWidth(text) + 10
    end

    love.graphics.setColor(1,1,1)
end

-- ===============================
-- DRAW PVC TOOLTIP
-- ===============================
function HoverTooltip.drawPVC(params)
    local name                = params.name or "Unknown"
    local pvc                 = params.pvc or {0,0,0}
    local showNumericalValue  = params.showNumericalValue or false

    love.graphics.setFont(tooltipFont)
    local p,v,c     = tonumber(pvc[1]) or 0, tonumber(pvc[2]) or 0, tonumber(pvc[3]) or 0
    local nameW     = tooltipFont:getWidth(name)
    local nameH     = tooltipFont:getHeight()
    local sampleTxt = showNumericalValue
                        and string.format("P+%d V+%d C+%d", p,v,c)
                        or "P+ V+ C+"
    local profW     = tooltipFont:getWidth(sampleTxt)
    local profH     = tooltipFont:getHeight()
    local boxW      = math.max(nameW, profW) + padding*2
    local boxH      = nameH + profH + padding*3

    local barX, barY = calculatePosition(params, boxW, boxH)

    -- Background
    love.graphics.setColor(0,0,0,0.85)
    love.graphics.rectangle("fill", barX, barY, boxW, boxH)

    -- Name (potion color derived from PVC values)
    love.graphics.setColor((p+8)/16, (v+8)/16, (c+8)/16)
    love.graphics.print(name, barX+padding, barY+padding)

    -- PVC line
    drawColoredPVC(pvc, barX+padding, barY+padding+nameH, showNumericalValue)

    -- Reset
    love.graphics.setFont(love.graphics.newFont())
    love.graphics.setColor(1,1,1)
end

-- ===============================
-- DRAW GENERIC TOOLTIP (Dynamic lines + colors)
-- ===============================
function HoverTooltip.drawGeneric(params)
    local lines  = params.lines or {"Text"}
    local colors = params.colors or {{1,1,1}}

    -- Ensure lines and colors are tables
    if type(lines) == "string" then lines = {lines} end
    if type(colors[1]) ~= "table" then colors = {colors} end

    -- If only one color provided, apply to all lines
    if #colors == 1 and #lines > 1 then
        for i = 2, #lines do
            table.insert(colors, colors[1])
        end
    end

    -- Wrap text for each line
    local wrappedLines = {}
    local wrappedColors = {}
    for i, line in ipairs(lines) do
        local pieces = wrapText(line)
        for _, piece in ipairs(pieces) do
            table.insert(wrappedLines, piece)
            table.insert(wrappedColors, colors[i] or {1,1,1})
        end
    end

    love.graphics.setFont(tooltipFont)

    -- Calculate box size
    local maxW = 0
    for _, l in ipairs(wrappedLines) do
        local lw = tooltipFont:getWidth(l)
        if lw > maxW then maxW = lw end
    end
    local boxW = maxW + padding*2
    local boxH = (#wrappedLines * tooltipFont:getHeight()) + padding*(#wrappedLines + 1)

    local barX, barY = calculatePosition(params, boxW, boxH)

    -- Draw background
    love.graphics.setColor(0,0,0,0.85)
    love.graphics.rectangle("fill", barX, barY, boxW, boxH)

    -- Draw lines with colors
    local y = barY + padding
    for i, l in ipairs(wrappedLines) do
        love.graphics.setColor(wrappedColors[i])
        love.graphics.print(l, barX+padding, y)
        y = y + tooltipFont:getHeight() + padding/2
    end

    -- Reset
    love.graphics.setFont(love.graphics.newFont())
    love.graphics.setColor(1,1,1)
end

return HoverTooltip
