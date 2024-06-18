local food = TalkAction("!food")

function food.onSay(player, words, param)
    local quantity = 100
    local foodCost = 1000

    --self:sendTextMessage(MESSAGE_TRADE, ("Paid %s gold from bank account. Your account balance is now %s gold."):format(FormatNumber(amount), FormatNumber(self:getBankBalance())))

	if player:removeMoneyBank(foodCost) then
		player:addItem(3725, quantity)
        player:sendTextMessage(MESSAGE_LOOT, string.format("You have received s% brown mushrooms.", quantity))
	else
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage(string.format("You do not have enough money. You need %s gold to buy food!", foodCost))
	end
end

food:groupType("normal")
food:register()