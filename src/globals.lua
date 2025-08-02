local globals = {}

-- ===============================
-- External Libraries
-- ===============================
local Camera = require("src.lib.hump.camera")
globals.cam = Camera(0, 0)

-- ===============================
-- SCREEN SETTINGS
-- ===============================
globals.screenWidth = 1000
globals.screenHeight = 1000

-- ===============================
-- WORLD SETTINGS
-- ===============================
globals.worldMinX = 0
globals.worldMinY = 0
globals.worldMaxX = 5000  -- Large world width
globals.worldMaxY = 5000  -- Large world height
globals.worldWidth  = globals.worldMaxX - globals.worldMinX
globals.worldHeight = globals.worldMaxY - globals.worldMinY

-- ===============================
-- PLAY AREA SETTINGS
-- ===============================
globals.playBorderSize = 1500

-- ===============================
-- CAMERA & ZOOM SETTINGS
-- ===============================
globals.epsilon = 0.001
globals.cameraLerpSpeed = 5.0
globals.zoomLerpSpeed = 6.0
globals.zoomMax = 1.2
globals.zoomMin = 0.8
globals.camTargetZoom = 0.8
globals.cam:zoomTo(globals.camTargetZoom)
globals.camTargetX = (globals.worldMinX + globals.worldMaxX) / 2
globals.camTargetY = (globals.worldMinY + globals.worldMaxY) / 2
globals.cam:lookAt(globals.camTargetX, globals.camTargetY)

-- ===============================
-- CAULDRON POSITION
-- ===============================
globals.cauldronX = globals.camTargetX
globals.cauldronY = globals.camTargetY

-- ===============================
-- HOVER STATES
-- ===============================
globals.cauldronHovered = false
globals.saplingHovered = false

-- ===============================
-- GAME STATE
-- ===============================
globals.rngSeed = nil
globals.floatingTexts = {}
globals.brewState = {
    ingredients = { "none", "none", "none" },
    color       = { 1, 1, 1, 1 },
    PVC         = { 0, 0, 0 }
}
globals.cauldronStage   = 0
globals.pourStatus      = false
globals.stumpSelected     = false
globals.saplingQuestCompleted = false

-- ===============================
-- BREW STAGE DATA (Resets every ascension stage)
-- ===============================
globals.BrewStageData = {
    totalIngredients = 0,                 -- Total number of ingredients added this stage
    uniqueIngredients = {},               -- Table of ingredient names added (as keys)
    rareIngredientCount = 0,              -- Number of rare ingredients added
    colorHistory = {},                    -- Table to store unique color states (optional: hex or RGB string)
    colorChangeCount = 0                  -- Number of times the brew changed color
}

-- ===============================
-- POTION STORAGE + DRAG STATE
-- ===============================
globals.potionSlots = {}
globals.draggingPotion = nil
globals.dragOrigin = nil

-- =======================================================
-- RESOURCES (LIZARD TAIL, FORAGABLE, RARE)
-- =======================================================
globals.discoveredRareResources = {}
globals.lizardSpawnCount   = 0
globals.lizardSpawnTimer   = 0

globals.resources = {
    { name = "Wyrmroot",    color = {0.55,0.27,0.07}, amount = 10, PVC = { 1,  0, -1},  mood = "Rage"  },
    { name = "Lycanlily",   color = {0.5, 0.3, 0.5}, amount = 10, PVC =  {-2, -1,  1},  mood = "Joy"   },
    { name = "CrimsonIvy",  color = {0.9, 0.2, 0.3}, amount = 10, PVC =  {-1,  1,  2},  mood = "Fear"  }
}

globals.rareResources = {
    { name = "Lizard Tail"   ,color = {0.4,0.4,0.4}, amount = 0,  PVC = {0, 0, 0},  mood = "Joy",    effect = "Latent Doubler" },
    { name = "Quest Voucher" ,color = {0.8,0.8,0.8}, amount = 0,  PVC = {0, 0, 0},  mood = "Sorrow", effect = "Polarity"      }

}

-- ===============================
-- FUNCTION: Recalculate Brew PVC (with Latent Doubler support)
-- ===============================
-- ===============================
-- FUNCTION: Recalculate Brew PVC (with Latent Doubler and Polarity support)
-- ===============================
function globals.recalculateBrewPVC(returnOnly)
    local pvc = {0, 0, 0}
    local ingredients = globals.brewState.ingredients

    for _, ing in ipairs(ingredients) do
        if ing ~= "none" then
            local r = nil

            -- Look in normal resources
            for _, res in ipairs(globals.resources) do
                if res.name:lower() == ing:lower() then
                    r = res
                    break
                end
            end

            -- If not found, look in rare resources
            if not r then
                for _, res in ipairs(globals.rareResources) do
                    if res.name:lower() == ing:lower() then
                        r = res
                        break
                    end
                end
            end

            if r then
                if r.effect == "Latent Doubler" then
                    pvc[1] = pvc[1] * 2
                    pvc[2] = pvc[2] * 2
                    pvc[3] = pvc[3] * 2
                elseif r.effect == "Polarity" then
                    pvc[1] = pvc[1] * -1
                    pvc[2] = pvc[2] * -1
                    pvc[3] = pvc[3] * -1
                else
                    local basePVC = r.PVC or {0, 0, 0}
                    pvc[1] = pvc[1] + basePVC[1]
                    pvc[2] = pvc[2] + basePVC[2]
                    pvc[3] = pvc[3] + basePVC[3]
                end
            end
        end
    end

    if returnOnly then
        return pvc
    else
        globals.brewState.PVC = pvc
    end
end

-- ===============================
-- FUNCTION: Reset 
-- ===============================
function globals.resetBrewStageData()
    globals.brewHistory = {
        totalIngredients = 0,
        uniqueIngredients = {},
        rareIngredientCount = 0,
        colorHistory = {},
        colorChangeCount = 0
    }
end


return globals
