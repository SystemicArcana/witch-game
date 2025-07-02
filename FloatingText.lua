-- A floating pop-up text that may appear whenever something is collected
-- NOTE: Text size is set based on the last set text side (project wide) -> Search main.lua for "love.graphics.setFont(...)"

local FloatingText = {}

FloatingText.texts = {}
FloatingText.duration = 1.5   -- seconds at 100% opacity before fading
FloatingText.riseSpeed = 20   -- pixels per second

function FloatingText.spawn(x, y, text)
    table.insert(FloatingText.texts, {
        x = x,
        y = y,
        alpha = 1,
        lifetime = FloatingText.duration,
        text = text
    })
end

function FloatingText.update(dt)
    local halfDuration = FloatingText.duration / 2
    for i = #FloatingText.texts, 1, -1 do
        local ft = FloatingText.texts[i]
        ft.lifetime = ft.lifetime - dt
        ft.y = ft.y - FloatingText.riseSpeed * dt

        if ft.lifetime > halfDuration then
            ft.alpha = 1
        else
            ft.alpha = ft.lifetime / halfDuration
        end

        if ft.lifetime <= 0 then
            table.remove(FloatingText.texts, i)
        end
    end
end

function FloatingText.draw()
    for _, ft in ipairs(FloatingText.texts) do
        love.graphics.setColor(1, 1, 1, ft.alpha)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(ft.text)
        love.graphics.print(ft.text, ft.x - textWidth / 2, ft.y)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return FloatingText
