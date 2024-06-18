Before:
if weapon:getAttribute(ITEM_ATTRIBUTE_CHARGES) <= 0 then
    weapon:remove(1)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your training weapon has disappeared.")
    leaveExerciseTraining(playerId)
    return false
end

After:
if weapon:getAttribute(ITEM_ATTRIBUTE_CHARGES) <= 0 then
    weapon:remove(1)
    local weapon = player:getItemById(weaponId, true)
    if not weapon or (not weapon:isItem() or not weapon:hasAttribute(ITEM_ATTRIBUTE_CHARGES)) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your training weapon has disappeared.")
        leaveExerciseTraining(playerId)
        return false
    end
end