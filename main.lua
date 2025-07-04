-- Internal libraries
local LizardSpawner = require("src.LizardSpawner")
local FloatingText = require("src.FloatingText")
local ForageSystem = require("src.ForageSystem")
local CauldronSystem = require("src.CauldronSystem")
local CameraSystem = require("src.CameraSystem")
local DialogueBox = require("src.DialogueBox")
local globals = require("src.globals")

function love.load()
    -- Default zoom: 50%
    globals.cam:zoomTo(0.5)
    globals.LizardSpawner = LizardSpawner.getRandomLizardSpawnInterval()
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    local worldX, worldY = globals.cam:worldCoords(mx, my)

    CameraSystem.scroll(mx, my, dt)
    CameraSystem.clampCamera()

    CauldronSystem.update(worldX, worldY)
    ForageSystem.update(dt)
    LizardSpawner.checkLizard(dt)
    FloatingText.update(dt)
    DialogueBox.update(dt)
end

function love.draw()
    
    globals.cam:attach()
    -- Drawings that move with camera goes in here
    CauldronSystem.draw()
    LizardSpawner.draw()
    FloatingText.draw()
    ForageSystem.draw()

    globals.cam:detach()

    DialogueBox.draw() -- explicity placed AFTER global detach

    -- UI / instruction
    love.graphics.print("Move mouse to screen edges to pan camera", 10, 10)

    function love.mousepressed(x, y, button)
        ForageSystem.mousepressed(x, y, button)
        LizardSpawner.mousepressed(x, y, button)
        CauldronSystem.mousepressed(x, y, button)
    end
end