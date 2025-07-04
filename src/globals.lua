local globals = {}
-- External Libraries
local Camera = require("src.lib.hump.camera")
globals.cam = Camera(0,0)
globals.playerName = "Witch"
globals.floatingTexts = {}
globals.screenWidth = love.graphics.getWidth()
globals.screenHeight = love.graphics.getHeight()
globals.scrollSpeed = 600              -- pixels per second
globals.edgeMargin = 30                -- distance from screen edge to trigger scroll
globals.worldWidth = 2000
globals.worldHeight = 2000
-- Cauldron Variables
globals.brewState = {
    ingredients = {"none", "none", "none"},
    color = {1, 1, 1, 1},
}
globals.cauldronStage = 0
globals.pourStatus = false
globals.cauldronSelected = false
globals.pileSelected = false
globals.cauldronX = globals.worldWidth / 2
globals.cauldronY = globals.worldHeight /2
globals.potionSlots = {}
-- Lizard Variables
globals.lizardSpawnCount = 0
globals.lizardTailsOwned = 0
globals.lizardSpawnTimer = 0
-- Foraging Variables
globals.resources = {
    { name = "Wyrmroot", color = {0.55, 0.27, 0.07}, amount = 1, PVC = {-1, 0, 1}, mood = "Rage"},
    { name = "Lycanlily", color = {0.5, 0.3, 0.5}, amount = 1, PVC = {1, 0, -1}, mood = "Sorrow" },
    { name = "TBD 1", color = {0.5, 0.5, 0.5}, amount = 0 },
    { name = "TBD 2", color = {0.5, 0.5, 0.5}, amount = 0 },
    { name = "TBD 3", color = {0.5, 0.5, 0.5}, amount = 0 },
    { name = "TBD 4", color = {0.5, 0.5, 0.5}, amount = 0 },
    { name = "TBD 5", color = {0.5, 0.5, 0.5}, amount = 0 },
    { name = "TBD 6", color = {0.5, 0.5, 0.5}, amount = 0 }
}
return globals