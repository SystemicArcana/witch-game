-- main.lua

-- Internal libraries
local LizardSpawner     = require("src.LizardSpawner")
local FloatingText      = require("src/FloatingText")
local ForageSystem      = require("src/ForageSystem")
local CauldronSystem    = require("src.CauldronSystem")
local CauldronUI        = require("src.CauldronUI")
local CameraSystem      = require("src.CameraSystem")
local DialogueBox       = require("src/DialogueBox")
local QuestSapling      = require("src/QuestSapling")
local PotionStump       = require("src/PotionStump")
local PotionDropHandler = require("src/PotionDropHandler")
local globals           = require("src/globals")

-- ===============================
-- LOVE LOAD
-- ===============================
function love.load()
    -- RNG Seed setup
    globals.rngSeed = os.time()
    math.randomseed(globals.rngSeed)
    for i = 1, 3 do math.random() end  -- warm up the RNG to improve 'randomness'
    
    -- Ensure the camera starts centered on the world (and cauldron)
    globals.cam:zoomTo(globals.camTargetZoom)
    globals.cam:lookAt(globals.camTargetX, globals.camTargetY)

    -- Initialize systems
    globals.LizardSpawner = LizardSpawner.getRandomLizardSpawnInterval()
    CameraSystem.load()
end

-- ===============================
-- LOVE UPDATE
-- ===============================
function love.update(dt)
    local mx, my = love.mouse.getPosition()
    local worldX, worldY = globals.cam:worldCoords(mx, my)

    -- Camera logic
    CameraSystem.update(dt)
    CameraSystem.clampCamera()
    CameraSystem.updateWallStatus()

    -- Game systems
    CauldronSystem.update(worldX, worldY, dt)
    PotionStump.update(worldX, worldY, dt)
    ForageSystem.update(dt)
    LizardSpawner.checkLizard(dt)
    FloatingText.update(dt)
    DialogueBox.update(dt)
    QuestSapling.update(worldX, worldY)
end

-- ===============================
-- LOVE DRAW
-- ===============================
function love.draw()
    -- Draw background
    CameraSystem.draw()

    -- World rendering within camera
    globals.cam:attach()

        love.graphics.setColor(1, 1, 1) -- reset

        -- Cauldron and UI
        CauldronSystem.draw()
        CauldronUI.draw()
        
        -- Stage 1 drawings
        if globals.cauldronStage >= 1 then
            ForageSystem.draw()
            QuestSapling.draw()
            PotionStump.draw()
            LizardSpawner.draw()
        end

        -- Dialogue and Text
        DialogueBox.draw()
        FloatingText.draw()

    globals.cam:detach()
end

-- ===============================
-- INPUT: MOUSE PRESS
-- ===============================
function love.mousepressed(x, y, button)
    local worldX, worldY = globals.cam:worldCoords(x, y)
    local selected = false

    selected = PotionStump.mousepressed(worldX, worldY, button) or selected     -- Prioritize PotionStump
    selected = CauldronSystem.mousepressed(worldX, worldY, button) or selected
    
    -- LizardSpawner last to guarentee click priority
    if globals.cauldronStage >= 1 then
        selected = ForageSystem.mousepressed(worldX, worldY, button) or selected
        selected = LizardSpawner.mousepressed(worldX, worldY, button) or selected
    end

    if not selected and button == 1 then
        CameraSystem.beginDrag(x, y)
    end
end

-- ===============================
-- INPUT: MOUSE RELEASE
-- ===============================
function love.mousereleased(x, y, button)
    local worldX, worldY = globals.cam:worldCoords(x, y)
    
    if PotionDropHandler.mousereleased(worldX, worldY, button) then -- Handle potion drop logic
        return
    end

    if button == 1 then
        CameraSystem.endDrag()
    end
end

-- ===============================
-- INPUT: SCROLL WHEEL ZOOM
-- ===============================
function love.wheelmoved(_, dy)
    if dy ~= 0 then
        CameraSystem.handleZoomInput(dy)
    end
end
