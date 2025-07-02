local CauldronSystem = {}
local globals = require("src.globals")
-- Assets loading
local cauldronSprite = love.graphics.newImage("assets/sprites/cauldron.png")
local cauldronHoveredSprite = love.graphics.newImage("assets/sprites/cauldron_witch.png")
-- local variables

function CauldronSystem.checkCauldronHover(worldX, worldY) 
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

function CauldronSystem.draw()
        -- Draw Cauldron
    local img = cauldronHovered and cauldronHoveredSprite or cauldronSprite
    local w = img:getWidth()
    local h = img:getHeight()
    love.graphics.draw(img, cauldronX, cauldronY, 0, 1, 1, w/2, h/2)
end

return CauldronSystem