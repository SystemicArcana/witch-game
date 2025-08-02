-- src/PotionDropHandler.lua
local PotionDropHandler = {}

local globals          = require("src/globals")
local Objectives       = require("src/Objectives")
local DialogueBox      = require("src/DialogueBox")

-- ===============================
-- Called from love.mousereleased in main.lua
-- ===============================
function PotionDropHandler.mousereleased(worldX, worldY, button)
    if button == 1 and globals.draggingPotion then
        local potion = globals.draggingPotion

        -- CAULDRON
        if globals.cauldronHovered then
            globals.potionSlots[globals.dragOrigin] = nil
            DialogueBox.say("Guess I won't be needing that potion anymore.")
        end

        -- QUEST SAPLING
        if globals.saplingHovered and not globals.saplingQuestCompleted then   -- Potion dropped on sapling AND quest still active?
            if Objectives.checkSaplingQuest(potion) then                       -- Check to see if the dropped potion is correct
                globals.potionSlots[globals.dragOrigin] = nil
                DialogueBox.say(Objectives.saplingQuest.successMessage)        -- 'Correct' dialogue message
                globals.saplingQuestCompleted = true                           -- Mark the quest as complete

                for _, resource in ipairs(globals.rareResources) do            -- Increment Lizard Tail in globals
                    if resource.name == "Quest Voucher" then

                        resource.amount = resource.amount + 1                  -- Add voucher to storage
                        globals.discoveredRareResources[resource.name] = true  -- Mark voucher as discovered 
                        
                        break
                    end
                end
                
            else
                globals.potionSlots[globals.dragOrigin] = nil
                DialogueBox.say(Objectives.saplingQuest.failureMessage)      -- 'Incorrect' dialogue message
            end
        end

        -- ALWAYS clear drag state
        globals.draggingPotion = nil
        globals.dragOrigin = nil

        return true
    end

    return false
end

return PotionDropHandler
