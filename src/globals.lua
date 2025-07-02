local globals = {}
-- External Libraries
local Camera = require("src.lib.hump.camera")
globals.cam = Camera(0,0)
globals.playerName = "Witch"
globals.floatingTexts = {}
globals.screenWidth = love.graphics.getWidth()
globals.screenHeight = love.graphics.getHeight()
globals.scrollSpeed = 300              -- pixels per second
globals.edgeMargin = 30                -- distance from screen edge to trigger scroll
globals.worldWidth = 200
globals.worldHeight = 500
-- Cauldron placement
globals.cauldronX = globals.worldWidth / 2
globals.cauldronY = globals.worldHeight /2
-- Lizard Variables
globals.lizardSpawnCount = 0
globals.lizardTailsOwned = 0
globals.lizardSpawnTimer = 0

return globals