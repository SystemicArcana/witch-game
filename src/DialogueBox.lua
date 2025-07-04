-- Periodically spawns dialogue at bottom of screen for the dialogue, instructions, quest info, etc.
-- Can be called from anywhere: DialogueBox.show("Custom text") or DialogueBox.show() for a random message

local DialogueBox = {}

-- Message pool
local messages = {
    "It's amazing how the liquid never seems to bubble over...",
    "I wonder how many other witches are out there..?",
    "The cauldron smells...surprisingly pleasant.",
    "I like this place... it's much quieter than I'm used to.",
    "The ingredients here are so strange... I love it!",
    "Perhaps something new will grow if I pour the cauldron out..."
}

-- Configuration
local fadeInDuration  = 0.5   -- seconds to fade in box
local textDelay       = 0.25  -- initial pause before first character
local charDelay       = 0.033 -- between normal characters
local dotDelay        = 0.5   -- between periods ("…")
local showDuration    = 3     -- seconds fully visible after typing
local fadeOutDuration = 2     -- seconds to fade out
local interval        = 10    -- seconds between pop‑ups when idle

-- Loaded resources
local parchmentNoise = love.graphics.newImage("assets/images/ParchmentBackground.png")
local success, italicFont = pcall(love.graphics.newFont, "fonts/OpenSans-Italic.ttf", 20)
local font = success and italicFont or love.graphics.newFont(20)

-- State variables
DialogueBox.state        = "hidden"  -- "hidden" | "fading_in" | "typing" | "displaying" | "fading_out"
DialogueBox.elapsed      = 0         -- when hidden, counts up to `interval`
DialogueBox.opacity      = 0
DialogueBox.activeMessage= nil
DialogueBox.displayedText= ""
DialogueBox.charIndex    = 0
DialogueBox.charTimer    = 0
DialogueBox.displayTimer = 0
DialogueBox.currentDelay = textDelay

-- Pick a new non-duplicate message
local function pickMessage(custom)
    if custom then return custom end
    local choice
    repeat
        choice = messages[math.random(#messages)]
    until choice ~= DialogueBox.activeMessage or #messages == 1
    return choice
end

-- Starts a new dialogue sequence
function DialogueBox.say(msg)
    DialogueBox.activeMessage = pickMessage(msg)
    DialogueBox.state         = "fading_in"
    DialogueBox.opacity       = 0

    DialogueBox.displayedText = ""
    DialogueBox.charIndex     = 0
    DialogueBox.charTimer     = 0
    DialogueBox.currentDelay  = textDelay
    DialogueBox.displayTimer  = 0
    DialogueBox.elapsed       = 0
end

-- Called from love.update(dt) in main.lua
function DialogueBox.update(dt)
    if DialogueBox.state == "hidden" then
        DialogueBox.elapsed = DialogueBox.elapsed + dt
        if DialogueBox.elapsed >= interval then
            DialogueBox.say()
        end

    elseif DialogueBox.state == "fading_in" then
        DialogueBox.opacity = math.min(1, DialogueBox.opacity + dt / fadeInDuration)
        if DialogueBox.opacity >= 1 then
            DialogueBox.state = "typing"
        end

    elseif DialogueBox.state == "typing" then
        DialogueBox.charTimer = DialogueBox.charTimer + dt
        -- type next character when timer exceeds currentDelay
        if DialogueBox.charTimer >= DialogueBox.currentDelay then
            DialogueBox.charIndex = DialogueBox.charIndex + 1
            DialogueBox.charTimer = DialogueBox.charTimer - DialogueBox.currentDelay

            -- update displayed text
            DialogueBox.displayedText = string.sub(DialogueBox.activeMessage, 1, DialogueBox.charIndex)

            -- decide next delay (check for period "." characters for additional delay)
            local nextChar = string.sub(DialogueBox.activeMessage, DialogueBox.charIndex+1, DialogueBox.charIndex+1)
            DialogueBox.currentDelay = (nextChar == ".") and dotDelay or charDelay

            -- Check if the dialogue is finished typing
            if DialogueBox.charIndex >= #DialogueBox.activeMessage then
                DialogueBox.state = "displaying"
            end
        end

    elseif DialogueBox.state == "displaying" then
        DialogueBox.displayTimer = DialogueBox.displayTimer + dt
        if DialogueBox.displayTimer >= showDuration then
            DialogueBox.state = "fading_out"
        end

    elseif DialogueBox.state == "fading_out" then
        DialogueBox.opacity = math.max(0, DialogueBox.opacity - dt / fadeOutDuration)
        if DialogueBox.opacity <= 0 then
            DialogueBox.state = "hidden"
            -- reset for next cycle
            DialogueBox.displayedText = ""
            DialogueBox.activeMessage = nil
            DialogueBox.elapsed       = 0
        end
    end
end

-- Called from love.draw() in main.lua
function DialogueBox.draw()
    if DialogueBox.state == "hidden" or not DialogueBox.activeMessage then
        return
    end

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local boxW, boxH = sw * 0.5, 130
    local x = (sw - boxW) * 0.5
    local y = sh - boxH - (sh * 0.1)
    local corner = 8

    -- Colors
    local borderColor    = {0.4, 0.25, 0.1, DialogueBox.opacity}
    local parchmentColor = {0.98, 0.94, 0.78, DialogueBox.opacity}
    local textColor      = {0.3, 0.1, 0.4, DialogueBox.opacity}

    love.graphics.setFont(font)

    -- Border
    love.graphics.setColor(unpack(borderColor))
    love.graphics.rectangle("fill", x - 3, y - 3, boxW + 6, boxH + 6, corner)

    -- Background
    love.graphics.setColor(unpack(parchmentColor))
    love.graphics.rectangle("fill", x, y, boxW, boxH, corner)

    -- Noise overlay (parchment paper background)
    love.graphics.setColor(1, 1, 1, DialogueBox.opacity * 0.9) --the noise overlay is faint, so a high opacity is needed
    love.graphics.draw(
        parchmentNoise,
        x, y, 0,
        boxW / parchmentNoise:getWidth(),
        boxH / parchmentNoise:getHeight()
    )

    -- Text
    if #DialogueBox.displayedText > 0 then
        love.graphics.setColor(unpack(textColor))
        local _, wrapped = font:getWrap(DialogueBox.displayedText, boxW - 30)
        local textH = #wrapped * font:getHeight()
        local textY = y + (boxH - textH) / 2
        love.graphics.printf(DialogueBox.displayedText, x + 15, textY, boxW - 30, "center")
    end

    -- Reset dialogue box color so other game elements aren't affected
    love.graphics.setColor(1, 1, 1, 1)
end

-- Call from anywhere via DialogueBox.show("Message") or DialogueBox.show()
function DialogueBox.show(msg)
    DialogueBox.say(msg)
end

return DialogueBox