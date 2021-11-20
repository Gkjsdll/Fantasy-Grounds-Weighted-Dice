function onInit()
	ActionsManager.registerResultHandler("concentration", onConcentrationRoll);
	ActionsManager.registerResultHandler("death", onDeathRoll);
	ActionsManager.registerResultHandler("death_auto", onDeathRoll);
	ActionsManager.registerResultHandler("save", onSave);
	ActionsManager.registerResultHandler("systemshock", onSystemShockRoll);
end

function onConcentrationRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

    WeightedDiceCore.changeRoll(rRoll);

	if Session.IsHost and ActorManager.isPC(rSource) then
		rMessage.secret = nil;
	end
	Comm.deliverChatMessage(rMessage);

	local bAutoFail = rRoll.sDesc:match("%[AUTOFAIL%]");
	if not bAutoFail and rRoll.nTarget then
		notifyApplyConc(rSource, rMessage.secret, rRoll);
	end
end

function onDeathRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

    WeightedDiceCore.changeRoll(rRoll);

	if ActorHealthManager.getWoundPercent(rSource) >= 1 then
		local nTotal = ActionsManager.total(rRoll);
		
		local bStatusCheck = true;
		local sOriginalStatus = ActorHealthManager.getHealthStatus(rSource);
		
		local sSuccessField, sFailField;
		local sSourceNodeType, nodeSource = ActorManager.getTypeAndNode(rSource);
		if not nodeSource then
			return;
		end
		if sSourceNodeType == "pc" then
			sSuccessField = "hp.deathsavesuccess";
			sFailField = "hp.deathsavefail";
		elseif sSourceNodeType == "ct" then
			sSuccessField = "deathsavesuccess";
			sFailField = "deathsavefail";
		else
			return;
		end

		local nFirstDie = 0;
		if #(rRoll.aDice) > 0 then
			nFirstDie = rRoll.aDice[1].result or 0;
		end
		if nFirstDie == 1 then
			rMessage.text = rMessage.text .. " [CRITICAL FAILURE]";
			
			if nodeSource then
				local nValue = DB.getValue(nodeSource, sFailField, 0);
				if nValue < 3 then
					nValue = math.min(nValue + 2, 3);
					DB.setValue(nodeSource, sFailField, "number", nValue);
				end
			end
		elseif nFirstDie == 20 then
			rMessage.text = rMessage.text .. " [CRITICAL SUCCESS]";
			
			ActionDamage.applyDamage(nil, rSource, rRoll.bSecret, "[HEAL]", 1);
			bStatusCheck = false;
		elseif nTotal >= 10 then
			rMessage.text = rMessage.text .. " [SUCCESS]";

			if nodeSource then
				local nValue = DB.getValue(nodeSource, sSuccessField, 0);
				if nValue < 3 then
					nValue = nValue + 1;
					DB.setValue(nodeSource, sSuccessField, "number", nValue);
				end
				if nValue >= 3 then
					local aEffect = { sName = "Stable", nDuration = 0 };
					if ActorManager.getFaction(rSource) ~= "friend" then
						aEffect.nGMOnly = 1;
					end
					EffectManager.addEffect("", "", ActorManager.getCTNode(rSource), aEffect, true);
				end
			end
		else
			rMessage.text = rMessage.text .. " [FAILURE]";

			if nodeSource then
				local nValue = DB.getValue(nodeSource, sFailField, 0);
				if nValue < 3 then
					DB.setValue(nodeSource, sFailField, "number", nValue + 1);
				end
			end
		end
		
		if bStatusCheck then
			local bShowStatus = false;
			if ActorManager.getFaction(rSource) == "friend" then
				bShowStatus = not OptionsManager.isOption("SHPC", "off");
			else
				bShowStatus = not OptionsManager.isOption("SHNPC", "off");
			end
			if bShowStatus then
				local sNewStatus = ActorHealthManager.getHealthStatus(rSource);
				if sOriginalStatus ~= sNewStatus then
					rMessage.text = rMessage.text .. " [" .. Interface.getString("combat_tag_status") .. ": " .. sNewStatus .. "]";
				end
			end
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end

function onSave(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

    WeightedDiceCore.changeRoll(rRoll);

	Comm.deliverChatMessage(rMessage);

	local bAutoFail = rRoll.sDesc:match("%[AUTOFAIL%]");
	if not bAutoFail and rRoll.nTarget then
		notifyApplySave(rSource, rRoll);
	end
end

function onSystemShockRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

    WeightedDiceCore.changeRoll(rRoll);

	Comm.deliverChatMessage(rMessage);

	notifyApplySystemShock(rSource, rMessage.secret, rRoll);
end