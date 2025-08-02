-- Objectives could be either for one-off tasks (quest sapling), for quest tree logic, or for requests from the Witch Commune
-- Objectives will need a "Type"? Objectives will need to check on the potion's PVC and mood and return a pass/fail

-- src/Objectives.lua
local Objectives = {}

-- ===============================
-- ASCENSION OBJECTIVES
-- ===============================
-- These define requirements to unlock the "Pour" button for each stage.
-- Key = Stage you are advancing TO (e.g., stage 1 is the first ascension).
Objectives.ascension = {
    [1] = {
        ingredientsRequired = 3,      -- Add three unique ingredients
        uniqueIngredients   = 0,
        rareIngredients     = 0,      -- None needed yet
        colorChanges        = 0       -- No color change requirement
    },
    [2] = {
        ingredientsRequired = 20,     -- Total ingredients added
        uniqueIngredients   = 5,      -- 5 different ingredients
        rareIngredients     = 0,      -- 5 rare ingredients (like lizard tails)
        colorChanges        = 10       -- Brew must change color 4 times
    },
    [3] = {
        ingredientsRequired = 100,    -- Total ingredients
        uniqueIngredients   = 9,     -- Unique ingredient types
        rareIngredients     = 3,      -- 3 unique rare ingredients
        colorChanges        = 15       -- 6 color changes
    },
    [4] = {
        ingredientsRequired = 9999,   -- Max capacity goal (placeholder for future logic)
        uniqueIngredients   = 20,     -- Every ingredient in the game
        rareIngredients     = 10,     -- Large rare requirement
        colorChanges        = 8       -- 8 color changes
    }
}

-- ===============================
-- SAPLING QUEST
-- ===============================
Objectives.saplingQuest = {
    
        pvcCondition = function(pvc)
            return pvc[1] >= 0 and pvc[2] >= 0 and pvc[3] >= 0
        end,
        mood = "Joy",
        successMessage = "The little guy seems happy! Oh, it dropped something?",
        failureMessage = "I don't think that was quite right...",
    }

-- ===============================
-- QUEST OBJECTIVES
-- ===============================
Objectives.questsTier1 = {
    [1] = {
        pvcCondition = function(pvc)
            return pvc[1] >= 0 and pvc[2] >= 0 and pvc[3] >= 0
        end,
        mood = "Joy",
        successMessage = "The sapling glows and sways happily. You've done it!",
        failureMessage = "I don't think that was quite right...",
    }
}

-- ==============================================
-- FUNCTION: Check if Ascension Objective is met
-- ==============================================
function Objectives.checkAscension(stage, context)
    -- stage             = stage we're advancing to
    -- context           = {
    --   ingredients     = total ingredients added,
    --   uniqueIngredients     = number of unique ingredients,
    --   rareIngredients = number of rare ingredients,
    --   colorChanges    = number of unique color changes
    -- }

    local req = Objectives.ascension[stage]
    if not req then return false end

    -- Ensure context fields have default values to avoid nil comparisons
    local ing  = context.ingredients or 0
    local uniq = context.uniqueIngredients or 0
    local rare = context.rareIngredients or 0
    local col  = context.colorChanges or 0

    if req.ingredientsRequired and ing < req.ingredientsRequired then     -- Check total ingredient requirement
        return false
    end

    if req.uniqueIngredients and uniq < req.uniqueIngredients then -- Check unique ingredient requirement
        return false
    end

    if req.rareIngredients and rare < req.rareIngredients then -- Check rare ingredient requirement
        return false
    end

    if req.colorChanges and col < req.colorChanges then     -- Check color change requirement
        return false
    end

    return true
end

-- =====================================================
-- SAPLING FUNCTION: Check if potion meets requirement
-- =====================================================
function Objectives.checkSaplingQuest(potion)
    local saplingQuest = Objectives.saplingQuest
    if not saplingQuest then return false end

    local meetsMood = not saplingQuest.mood or potion.mood == saplingQuest.mood
    local meetsPVC = not saplingQuest.pvcCondition or saplingQuest.pvcCondition(potion.PVC)

    return meetsMood and meetsPVC
end

-- ==================================================
-- FUNCTION: Check if potion meets quest requirements
-- ==================================================
function Objectives.checkQuest(potion, questID)
    local quest = Objectives.questsTier1[questID]
    if not quest then return false end

    local meetsMood = not quest.mood or potion.mood == quest.mood
    local meetsPVC = not quest.pvcCondition or quest.pvcCondition(potion.PVC)

    return meetsMood and meetsPVC
end


return Objectives
