-- A floating pop-up text that may appear whenever something is collected
-- NOTE: Text size is set based on the last set text side (project wide) -> Search main.lua for "love.graphics.setFont(...)"

local FloatingText = {}
local globals = require("src.globals")

local duration = 1.5   -- seconds at 100% opacity before fading
local riseSpeed = 20   -- pixels per second
local fontSize = 14

function FloatingText.spawn(x, y, text)
    table.insert(globals.floatingTexts, {
        x = x,
        y = y,
        alpha = 1,
        lifetime = duration,
        text = text
    })
end

function FloatingText.update(dt)
    local halfDuration = duration / 2
    for i = #globals.floatingTexts, 1, -1 do
        local ft = globals.floatingTexts[i]
        ft.lifetime = ft.lifetime - dt
        ft.y = ft.y - riseSpeed * dt

        if ft.lifetime > halfDuration then
            ft.alpha = 1
        else
            ft.alpha = ft.lifetime / halfDuration
        end

        if ft.lifetime <= 0 then
            table.remove(globals.floatingTexts, i)
        end
    end
end

function FloatingText.draw()
    -- Draw all floating texts centered horizontally
    love.graphics.setFont(love.graphics.newFont(fontSize))
    for _, ft in ipairs(globals.floatingTexts) do
        love.graphics.setColor(1, 1, 1, ft.alpha)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(ft.text)
        love.graphics.print(ft.text, ft.x - textWidth / 2, ft.y)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return FloatingText
