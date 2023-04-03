-- DESCRIPTION: Handles all actions on player health (master control of g_PlayerHealth).

-- using g_PlayerHealth
g_PlayerInvulnerable = 0
g_PlayerStartStrength = 100

local gameplayerhealth = {}

function gameplayerhealth.startgame(invulnerablemode,value)
 g_PlayerInvulnerable = invulnerablemode
 g_PlayerStartStrength = value
 g_PlayerHealth = value
 SetPlayerHealthCore(g_PlayerHealth)
end

function gameplayerhealth.set(value)
 g_PlayerHealth = value
 SetPlayerHealthCore(g_PlayerHealth)
end

function gameplayerhealth.add(value)
 g_PlayerHealth = g_PlayerHealth + value
 if g_PlayerHealth > g_PlayerStartStrength then 
  g_PlayerHealth = g_PlayerStartStrength
 end
 SetPlayerHealthCore(g_PlayerHealth)
end

function gameplayerhealth.subtract(damage)

 -- detect extra user defined global for MYARMOUR
 if g_UserGlobal ~= nil then
  local user_defined_global_current = "MyArmour"
  if user_defined_global_current > "" then 
   if _G["g_UserGlobal['"..user_defined_global_current.."']"] ~= nil then
    local myarmour = _G["g_UserGlobal['"..user_defined_global_current.."']"]
	local originaldamage = damage
	if myarmour > 0 then
     damage = damage - myarmour
     if damage < 0 then damage = 0 end
	 -- chance of damaging armour
	 local chanceofarmourdegredation = 0
     local user_defined_global_toughness = "MyArmourToughness"
     if user_defined_global_toughness > "" then 
      if _G["g_UserGlobal['"..user_defined_global_toughness.."']"] ~= nil then 
	   chanceofarmourdegredation = math.random(1,10 / _G["g_UserGlobal['"..user_defined_global_toughness.."']"])
	   if chanceofarmourdegredation ~= 1 then 
	    myarmour = myarmour - 1 
	    PromptDuration("Armour took damage!",2000)
	   end
	   if myarmour < 0 then myarmour = 0 end
	   _G["g_UserGlobal['"..user_defined_global_current.."']"] = myarmour
	  end
	 end
     if myarmour > 0 and damage > 0 then 
      PromptDuration("Armour protected you! Only " .. damage .. " damage got through",2000)
	 else
	  if originaldamage > 0 and damage <=0 then
       PromptDuration("Armour prevented all damage!",2000)
	  end
     end
	end
   end
  end 
 end
 
 -- deduct the final damage
 g_PlayerHealth = g_PlayerHealth - damage
 
 -- if g_PlayerInvulnerable, ensure health is not affected
 if g_PlayerInvulnerable == 1 then
  g_PlayerHealth = g_PlayerStartStrength
 end

 -- ensure engine knows latest health value 
 SetPlayerHealthCore(g_PlayerHealth)
 
end

function gameplayerhealth.main()
  
 -- Screen REDNESS effect, and heartbeat, player is healthy, so fade away from redness
 if ( g_PlayerHealth >= 100 ) then 
  if ( GetGamePlayerControlRedDeathFog() > 0 ) then 
   SetGamePlayerControlRedDeathFog(GetGamePlayerControlRedDeathFog() - GetElapsedTime())
   if ( GetGamePlayerControlRedDeathFog() < 0 ) then SetGamePlayerControlRedDeathFog(0) end
  end
 else
  -- only for first person perspectives
  if ( GetGamePlayerControlThirdpersonEnabled() == 0 ) then 
   -- player is dead, so fade to full redness
   if ( g_PlayerHealth <= 0 ) then 
    if ( GetGamePlayerStateGameRunAsMultiplayer() == 0 ) then 
     if ( GetGamePlayerControlRedDeathFog() < 1 ) then 
      SetGamePlayerControlRedDeathFog(GetGamePlayerControlRedDeathFog() + GetElapsedTime())
      if ( GetGamePlayerControlRedDeathFog() > 1 ) then GetGamePlayerControlRedDeathFog(1) end
     end
    end
   else
    -- player is in injured state, so play low health heart beat and fade screen proportional to health
    if ( GetGamePlayerControlHeartbeatTimeStamp() ~= -1 ) then
     if ( GetGamePlayerControlHeartbeatTimeStamp() < Timer() ) then 
      ttsnd = GetGamePlayerControlSoundStartIndex()+17
      if ( RawSoundExist ( ttsnd ) == 1 ) then
       PlayRawSound ( ttsnd )
      end
      SetGamePlayerControlHeartbeatTimeStamp(Timer()+1000)
     end
     ttTargetRed = 0.5 - (g_PlayerHealth/200.0)
     if ( GetGamePlayerControlRedDeathFog() <= ttTargetRed ) then 
      SetGamePlayerControlRedDeathFog(GetGamePlayerControlRedDeathFog() + GetElapsedTime())
      if ( GetGamePlayerControlRedDeathFog() > ttTargetRed ) then SetGamePlayerControlRedDeathFog(ttTargetRed) end
     else
      SetGamePlayerControlRedDeathFog(GetGamePlayerControlRedDeathFog() - GetElapsedTime())
      if ( GetGamePlayerControlRedDeathFog() < ttTargetRed ) then SetGamePlayerControlRedDeathFog(ttTargetRed) end
     end
    end
   end
  end
 end 
end

return gameplayerhealth
