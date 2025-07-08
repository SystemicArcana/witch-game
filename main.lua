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
    CameraSystem.load()
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
    CameraSystem.draw()

    globals.cam:attach()
        -- Stage 2 Systems
        if globals.cauldronStage >= 1 then
            ForageSystem.draw()
            LizardSpawner.draw()
        end
        CauldronSystem.draw()
        FloatingText.draw()
    globals.cam:detach()

    -- Screen space drawings (these need to be placed explicitly AFTER global detach)
    DialogueBox.draw()

    -- UI / instruction
    love.graphics.print("Move mouse to screen edges to pan camera", 10, 10)
end

function love.mousepressed(x, y, button)
    local worldX, worldY = globals.cam:worldCoords(x, y)
    LizardSpawner.mousepressed(worldX, worldY, button)
    CauldronSystem.mousepressed(worldX, worldY, button)

    -- Stage 2 Systems
    if globals.cauldronStage >= 1 then
        ForageSystem.mousepressed(worldX, worldY, button)
        LizardSpawner.mousepressed(x, y, button)
    end
end