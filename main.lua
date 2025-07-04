-- Internal libraries
local LizardSpawner = require("src.LizardSpawner")
local FloatingText = require("src.FloatingText")
local ForageSystem = require("src.ForageSystem")
local CauldronSystem = require("src.CauldronSystem")
local CameraSystem = require("src.CameraSystem")
local DialogueBox = require("src.DialogueBox")

function love.load()
    -- Default zoom: 50%
    globals.cam:zoomTo(0.5)
    globals.cam:lookAt(globals.cauldronX, globals.cauldronY)
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
    
    -- Drawings that move with camera goes in here
    globals.cam:attach()
    CauldronSystem.draw()
    FloatingText.draw()

    -- Stage 2 Systems
    if globals.cauldronStage >= 1 then
        ForageSystem.draw()
        LizardSpawner.draw()
    end
    globals.cam:detach()

    DialogueBox.draw() -- explicity placed AFTER global detach

    -- UI / instruction
    love.graphics.print("Move mouse to screen edges to pan camera", 10, 10)
end

function love.mousepressed(x, y, button)
    CauldronSystem.mousepressed(x, y, button)

    -- Stage 2 Systems
    if globals.cauldronStage >= 1 then
        ForageSystem.mousepressed(x, y, button)
        LizardSpawner.mousepressed(x, y, button)
    end
end