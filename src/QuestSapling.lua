-- src/QuestSapling.lua
local QuestSapling    = {}
local globals      = require("src/globals")
local HoverTooltip = require("src/HoverTooltip")

-- Load assets
local questSapling         = love.graphics.newImage("assets/sprites/QuestSapling.png")
local questSaplingOutlined = love.graphics.newImage("assets/sprites/QuestSapling-Outlined.png")

-- Local variables
local x = globals.cauldronX + 900    -- World position X
local y = globals.cauldronY + 400    -- World position Y
local w   = questSapling:getWidth()  -- Sapling PNG width
local h   = questSapling:getHeight() -- Sapling PNG height

function QuestSapling.update(worldX, worldY)
    globals.saplingHovered = worldX > x - w/2 and worldX < x + w/2 and worldY > y - h/2 and worldY < y + h/2  --Update the global 'saplingHovered' variable
end

function QuestSapling.draw()
    -- Draw sapling (with outline if hovered)
    local img = globals.saplingHovered and questSaplingOutlined or questSapling
    love.graphics.draw(img, x, y, 0, 1, 1, w/2, h/2)

    -- Show tooltip only on hover
    if globals.saplingHovered then
        local lines, colors

        if globals.saplingQuestCompleted then
            lines = {"The stem sways happily."}
            colors = {0.8, 1, 0.3}   -- soft green/yellow
        else
            lines = {
                "A small page grows from a bud of this strange sapling.",
                "\"I require utmost positivity; there will be no growth until I am a joy to behold.\""
            }
            colors = {
                {0, 1, 0},
                {0, 0.6, 1}
            }
        end

        HoverTooltip.drawGeneric{
            widgetX = x,
            widgetY = y - 100,
            lines   = lines,
            colors  = colors,
            align   = "top",
            tether  = "widget"
        }
    end
end

return QuestSapling
