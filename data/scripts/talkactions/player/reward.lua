local config = {
	items = {
		{ id = 35284, charges = 64400 }, --durable exercise wand
		{ id = 35279, charges = 64400 }, --durable exercise sword
		{ id = 35281, charges = 64400 }, --durable exercise club
		{ id = 35283, charges = 64400 }, --durable exercise rod
		{ id = 35282, charges = 64400 }, --durable exercise bow
		{ id = 35280, charges = 64400 }, --durable exercise axe
		{ id = 44066, charges = 64400 }, --durable exercise shield
	},
	storage = tonumber(Storage.PlayerWeaponReward), -- storage key, player can only win once
}

-- Ordenar os itens por ID
table.sort(config.items, function(a, b) return a.id < b.id end)

local function sendExerciseRewardModal(player)
	local window = ModalWindow({
		title = "Exercise Reward",
		message = "choose an item",
	})
	for _, it in pairs(config.items) do
		local iType = ItemType(it.id)
		if iType then
			window:addChoice(iType:getName(), function(player, button, choice)
				if button.name ~= "Select" then
					return true
				end

				local inbox = player:getStoreInbox()
				local inboxItems = inbox:getItems()
				if inbox and #inboxItems <= inbox:getMaxCapacity() and player:getFreeCapacity() >= iType:getWeight() then
					local item = inbox:addItem(it.id, it.charges)
					if item then
						item:setActionId(IMMOVABLE_ACTION_ID)
						item:setAttribute(ITEM_ATTRIBUTE_STORE, systemTime())
						item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, string.format("You won this exercise weapon as a reward to be a %s player. Use it in a dummy!\nHave a nice game...", configManager.getString(configKeys.SERVER_NAME)))
					else
						player:sendTextMessage(MESSAGE_LOOK, "You need to have capacity and empty slots to receive.")
						return
					end
					player:sendTextMessage(MESSAGE_LOOK, string.format("Congratulations! You received a %s with %i charges in your store inbox.", iType:getName(), it.charges))
					player:setStorageValue(config.storage, 1)
				else
					player:sendTextMessage(MESSAGE_LOOK, "You need to have capacity and empty slots to receive.")
				end
			end)
		end
	end
	window:addButton("Select")
	window:addButton("Close")
	window:setDefaultEnterButton(0)
	window:setDefaultEscapeButton(1)
	window:sendToPlayer(player)
end

local exerciseRewardModal = TalkAction("!reward")
function exerciseRewardModal.onSay(player, words, param)
	if player:getLevel() < 20 then
		player:sendTextMessage(MESSAGE_LOOK, "You need to be level 20 to receive your exercise weapon reward!")
		return true
	end

	if not configManager.getBoolean(configKeys.TOGGLE_RECEIVE_REWARD) or player:getTown():getId() < TOWNS_LIST.AB_DENDRIEL then
		return true
	end
	if player:getStorageValue(config.storage) > 0 then
		player:sendTextMessage(MESSAGE_LOOK, "You already received your exercise weapon reward!")
		return true
	end
	sendExerciseRewardModal(player)
	return true
end

exerciseRewardModal:separator(" ")
exerciseRewardModal:groupType("normal")
exerciseRewardModal:register()
