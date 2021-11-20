WEIGHTED_ROLL = nil;

function onInit()
  math.randomseed(os.time())
  OOBManager.registerOOBMsgHandler("weighted_dice_set", setManualRoll);

  do
    local oldrandom = math.random;
    local randomtable;
    math.random = function ()
      if randomtable == nil then
        randomtable = {}
        for i = 1, 97 do
          randomtable[i] = oldrandom()
        end
      end
      local x = oldrandom()
      local i = 1 + math.floor(97*x)
      x, randomtable[i] = randomtable[i], x
      return x
      end
    end
end

function setManualRoll(msgOOB)
  local next_roll_value = tonumber(msgOOB.next_roll_value);
  local manualDieRollWindow = Interface.findWindow("weighteddice", "");

  local last_roll_value = WEIGHTED_ROLL;
  WEIGHTED_ROLL = next_roll_value;
  
  if manualDieRollWindow and last_roll_value ~= next_roll_value then
    manualDieRollWindow.weighted_die_roll.setValue(next_roll_value);
  end
end

function changeRoll(rRoll)
  Debug.console(rRoll);
	if WEIGHTED_ROLL ~= nil and WEIGHTED_ROLL > 0 then
		-- Set the d20 die roll result to the value of the manual roll field
		rRoll.aDice[1].result = WEIGHTED_ROLL;	
		rRoll.aDice[1].value = WEIGHTED_ROLL;	
		
		-- Clear the value (set it back to 0)
		Comm.deliverOOBMessage({type="weighted_dice_set", next_roll_value=0});
  else
    local new_roll = math.random(1, 20) * 19 + 1;
    if new_roll % 1 > 0.5 then
      new_roll = math.ceil(new_roll);
    else
      new_roll = math.floor(new_roll);
    end
    Debug.chat(new_roll);
    rRoll.aDice[1].result = new_roll;
    rRoll.aDice[1].value = new_roll;
	end
  Debug.console(rRoll);
end
