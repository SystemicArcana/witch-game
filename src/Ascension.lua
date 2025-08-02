-- ==============================================================================================
-- Ascension.lua
-- Handles progression by incrementing the brew stage, revealing more play area,
-- adjusting zoom, recentering the camera, and triggering stage-specific dialogue events.
-- ==============================================================================================

local Ascension = {}

local globals      = require("src/globals")
local DialogueBox  = require("src/DialogueBox")

-- Stage-specific ascension messages
local ascensionMessages = {
    [1] = "Whoa, is that a forest? I didn't realize things could grow here!",
    [2] = "A garden now too? And... what is that thing growing over there?",
    [3] = "TBD",
    -- future stages can be added here
}
-- =====================================================================
-- HANDLE PROGRESSION
--   Increments stage, resets brew, expands world, adjusts zoom
-- =====================================================================
function Ascension.handleStageIncrease()

    -- INCREMENT STAGE & RESET CAULDRON BREW
    globals.cauldronStage = globals.cauldronStage + 1
    globals.brewState.ingredients = { "none", "none", "none" }
    globals.recalculateBrewPVC()

    -- RESET BREW STAGE PROGRESS DATA
    globals.BrewStageData = {
        totalIngredients    = 0,      -- Reset ingredient count
        uniqueIngredients   = {},     -- Reset unique ingredient tracking
        rareIngredientCount = 0,      -- Reset rare ingredients
        colorHistory        = {},     -- Reset color history
        colorChangeCount    = 0       -- Reset color change counter
    }

    -- PLAY AREA EXPANSION
    globals.playBorderSize = globals.playBorderSize + 1250 -- How much to expand play area by (ADJUSTABLE)
    if globals.playBorderSize > globals.worldWidth then
        globals.playBorderSize = globals.worldWidth
    end
    if globals.playBorderSize > globals.worldHeight then
        globals.playBorderSize = globals.worldHeight
    end

    -- ZOOM ADJUSTMENTS
    local zoomOutStep   = 0.2    -- How much to decrease zoomMin each stage
    local zoomOutLimit  = 0.3    -- Absolute lower bound for zoomMin
    local slightZoomOut = 0.95   -- How much to zoom out instantly (0.95 = 5%)

    -- Decrease zoomMin so the player can zoom out further
    globals.zoomMin = math.max(globals.zoomMin - zoomOutStep, zoomOutLimit)

    -- Slight zoom out immediately (but not beyond new zoomMin)
    globals.camTargetZoom = math.max(globals.zoomMin, globals.camTargetZoom * slightZoomOut)

    -- CAMERA RECENTER
    globals.camTargetX = globals.cauldronX
    globals.camTargetY = globals.cauldronY

    -- STAGE-SPECIFIC DIALOGUE MESSAGE
    local msg = ascensionMessages[globals.cauldronStage]
    if msg then
        DialogueBox.say(msg)   -- Interrupt any ongoing dialogue and show the new message
    end
end

return Ascension
