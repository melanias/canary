local exhaustionTime = 10

local exerciseWeaponsTable = {
	-- MELEE
	[28540] = { skill = SKILL_SWORD },
	[28552] = { skill = SKILL_SWORD },
	[35279] = { skill = SKILL_SWORD },
	[35285] = { skill = SKILL_SWORD },
	[28553] = { skill = SKILL_AXE },
	[28541] = { skill = SKILL_AXE },
	[35280] = { skill = SKILL_AXE },
	[35286] = { skill = SKILL_AXE },
	[28554] = { skill = SKILL_CLUB },
	[28542] = { skill = SKILL_CLUB },
	[35281] = { skill = SKILL_CLUB },
	[35287] = { skill = SKILL_CLUB },
	[44064] = { skill = SKILL_SHIELD },
	[44065] = { skill = SKILL_SHIELD },
	[44066] = { skill = SKILL_SHIELD },
	[44067] = { skill = SKILL_SHIELD },
	-- ROD
	[28544] = { skill = SKILL_MAGLEVEL, effect = CONST_ANI_SMALLICE, allowFarUse = true },
	[28556] = { skill = SKILL_MAGLEVEL, effect = CONST_ANI_SMALLICE, allowFarUse = true },
	[35283] = { skill = SKILL_MAGLEVEL, effect = CONST_ANI_SMALLICE, allowFarUse = true },
	[35289] = { skill = SKILL_MAGLEVEL, effect = CONST_ANI_SMALLICE, allowFarUse = true },
	-- RANGE
	[28543] = { skill = SKILL_DISTANCE, effect = CONST_ANI_SIMPLEARROW, allowFarUse = true },
	[28555] = { skill = SKILL_DISTANCE, effect = CONST_ANI_SIMPLEARROW, allowFarUse = true },
	[35282] = { skill = SKILL_DISTANCE, effect = CONST_ANI_SIMPLEARROW, allowFarUse = true },
	[35288] = { skill = SKILL_DISTANCE, effect = CONST_ANI_SIMPLEARROW, allowFarUse = true },
	-- WAND
	[28545] = { skill = SKILL_MAGLEVEL, effect = CONST_ANI_FIRE, allowFarUse = true },
	[28557] = { skill = SKILL_MAGLEVEL, effect = CONST_ANI_FIRE, allowFarUse = true },
	[35284] = { skill = SKILL_MAGLEVEL, effect = CONST_ANI_FIRE, allowFarUse = true },
	[35290] = { skill = SKILL_MAGLEVEL, effect = CONST_ANI_FIRE, allowFarUse = true },
}

local dummies = Game.getDummies()

local function round(n)
	return math.floor((math.floor(n*2) + 1)/2)
end

local function leaveExerciseTraining(playerId)
	if _G.OnExerciseTraining[playerId] then
		stopEvent(_G.OnExerciseTraining[playerId].event)
		_G.OnExerciseTraining[playerId] = nil
	end

	local player = Player(playerId)
	if player then
		player:setTraining(false)
	end
	return
end

local function exerciseTrainingEvent(playerId, tilePosition, weaponId, dummyId)
	local player = Player(playerId)
	if not player then
		return leaveExerciseTraining(playerId)
	end

	if player:isTraining() == 0 then
		player:sendTextMessage(MESSAGE_FAILURE, "You have stopped training.")
		return leaveExerciseTraining(playerId)
	end

	if not Tile(tilePosition):getItemById(dummyId) then
		player:sendTextMessage(MESSAGE_FAILURE, "Someone has moved the dummy, the training has stopped.")
		leaveExerciseTraining(playerId)
		return false
	end

	local playerPosition = player:getPosition()
	if not playerPosition:isProtectionZoneTile() then
		player:sendTextMessage(MESSAGE_FAILURE, "You are no longer in a protection zone, the training has stopped.")
		leaveExerciseTraining(playerId)
		return false
	end

	if player:getItemCount(weaponId) <= 0 then
		player:sendTextMessage(MESSAGE_FAILURE, "You need the training weapon in the backpack, the training has stopped.")
		leaveExerciseTraining(playerId)
		return false
	end

	local weapon = player:getItemById(weaponId, true)
	if not weapon:isItem() or not weapon:hasAttribute(ITEM_ATTRIBUTE_CHARGES) then
		player:sendTextMessage(MESSAGE_FAILURE, "The selected item is not a training weapon, the training has stopped.")
		leaveExerciseTraining(playerId)
		return false
	end

	local weaponCharges = weapon:getAttribute(ITEM_ATTRIBUTE_CHARGES)
	if not weaponCharges or weaponCharges <= 0 then
		weapon:remove(1) -- ??
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your training weapon has disappeared.")
		
		if not weapon or (not weapon:isItem() or not weapon:hasAttribute(ITEM_ATTRIBUTE_CHARGES)) then
			leaveExerciseTraining(playerId)
			return false
		end
	end

	if not dummies[dummyId] then
		return false
	end

	local skillId = exerciseWeaponsTable[weaponId].skill
	local dummyRate = dummies[dummyId] / 100
	local isMagic = skillId == SKILL_MAGLEVEL
	if isMagic then
		player:addManaSpent(600 * dummyRate)

		--Exibir status do treino
		local manaPercent = string.format("%.2f", ((player:getManaSpent() * 100) / player:getVocation():getRequiredManaSpent(player:getMagicLevel() + 1)))
		local trainingInfo = "Current magic level: ".. player:getMagicLevel() .." with ".. manaPercent .."% to ".. player:getMagicLevel() + 1 .."."
		trainingInfo = trainingInfo .."\n ".. player:getManaSpent() .." attempts of ".. player:getVocation():getRequiredManaSpent(player:getMagicLevel() + 1) .." to magic level ".. player:getMagicLevel() + 1 .."."
		player:sendTextMessage(MESSAGE_FAILURE, trainingInfo)
	else
		player:addSkillTries(skillId, math.floor((7.2 + 0.5) * dummyRate))

		--Exibir status do treino
		local trainingInfo = "Current skill level: ".. player:getSkillLevel(skillId) .." with ".. player:getSkillPercent(skillId) .."% to ".. player:getSkillLevel(skillId) + 1 .."."
		trainingInfo = trainingInfo .."\n ".. player:getSkillTries(skillId) .." / ".. player:getVocation():getRequiredSkillTries(skillId, player:getSkillLevel(skillId) + 1) .." to raise the skill to ".. player:getSkillLevel(skillId) + 1 .."."
		player:sendTextMessage(MESSAGE_FAILURE, trainingInfo)
	end

	--Remover uma carga da exercise weapon e exibir o efeito
	weapon:setAttribute(ITEM_ATTRIBUTE_CHARGES, (weaponCharges - 1))
	tilePosition:sendMagicEffect(CONST_ME_HITAREA)

	if exerciseWeaponsTable[weaponId].effect then
		playerPosition:sendDistanceEffect(tilePosition, exerciseWeaponsTable[weaponId].effect)
	end

	if weapon:getAttribute(ITEM_ATTRIBUTE_CHARGES) <= 0 then
		weapon:remove(1)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your training weapon has disappeared.")
		
		if not weapon or (not weapon:isItem() or not weapon:hasAttribute(ITEM_ATTRIBUTE_CHARGES)) then
			leaveExerciseTraining(playerId)
			return false
		end
	end

	local vocation = player:getVocation()
	_G.OnExerciseTraining[playerId].event = addEvent(exerciseTrainingEvent, vocation:getBaseAttackSpeed() / configManager.getFloat(configKeys.RATE_EXERCISE_TRAINING_SPEED), playerId, tilePosition, weaponId, dummyId)
	return true
end

local function isDummy(id)
	return dummies[id] and dummies[id] > 0
end

local exerciseTraining = Action()

function exerciseTraining.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or type(target) == "table" or not target:getId() then
		return true
	end

	local playerId = player:getId()
	local targetId = target:getId()

	if target:isItem() and isDummy(targetId) then
		if _G.OnExerciseTraining[playerId] then
			player:sendTextMessage(MESSAGE_FAILURE, "You are already training!")
			return true
		end

		local playerPos = player:getPosition()
		if not exerciseWeaponsTable[item.itemid].allowFarUse and (playerPos:getDistance(target:getPosition()) > 1) then
			player:sendTextMessage(MESSAGE_FAILURE, "Get closer to the dummy.")
			return true
		end

		if not playerPos:isProtectionZoneTile() then
			player:sendTextMessage(MESSAGE_FAILURE, "You need to be in a protection zone.")
			return true
		end

		local playerHouse = player:getTile():getHouse()
		local targetPos = target:getPosition()
		local targetHouse = Tile(targetPos):getHouse()

		if targetHouse and isDummy(targetId) then
			if playerHouse ~= targetHouse then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You must be inside the house to use this dummy.")
				return true
			end

			local playersOnDummy = 0
			for _, playerTraining in pairs(_G.OnExerciseTraining) do
				if playerTraining.dummyPos == targetPos then
					playersOnDummy = playersOnDummy + 1
				end

				if playersOnDummy >= configManager.getNumber(configKeys.MAX_ALLOWED_ON_A_DUMMY) then
					player:sendTextMessage(MESSAGE_FAILURE, "That exercise dummy is busy.")
					return true
				end
			end
		end

		if player:hasExhaustion("training-exhaustion") then
			player:sendTextMessage(MESSAGE_FAILURE, "This exercise dummy can only be used after a " .. exhaustionTime .. " seconds cooldown.")
			return true
		end

		_G.OnExerciseTraining[playerId] = {}
		if not _G.OnExerciseTraining[playerId].event then
			_G.OnExerciseTraining[playerId].event = addEvent(exerciseTrainingEvent, 0, playerId, targetPos, item.itemid, targetId)
			_G.OnExerciseTraining[playerId].dummyPos = targetPos
			player:setTraining(true)
			player:setExhaustion("training-exhaustion", exhaustionTime)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have started training on an exercise dummy.")
		end
		return true
	end
	return false
end

for weaponId, weapon in pairs(exerciseWeaponsTable) do
	exerciseTraining:id(weaponId)
	if weapon.allowFarUse then
		exerciseTraining:allowFarUse(true)
	end
end

exerciseTraining:register()
