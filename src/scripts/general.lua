function onInit()
	ActionsManager.registerResultHandler("dice", onRoll);
end

function onRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

    WeightedDiceCore.changeRoll(rRoll);

	Comm.deliverChatMessage(rMessage);
end
