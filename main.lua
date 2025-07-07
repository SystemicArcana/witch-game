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

    -- World space drawings (not screen space) go here
    globals.cam:attach()
        CauldronSystem.draw()
        LizardSpawner.draw()
        FloatingText.draw()
        ForageSystem.draw()
    globals.cam:detach()

    -- Screen space drawings (these need to be placed explicitly AFTER global detach)
    DialogueBox.draw()

    -- UI / instruction
    love.graphics.print("Move mouse to screen edges to pan camera", 10, 10)
end

function love.mousepressed(x, y, button)
    local worldX, worldY = globals.cam:worldCoords(x, y)
    ForageSystem.mousepressed(worldX, worldY, button)
    LizardSpawner.mousepressed(worldX, worldY, button)
    CauldronSystem.mousepressed(worldX, worldY, button)
end