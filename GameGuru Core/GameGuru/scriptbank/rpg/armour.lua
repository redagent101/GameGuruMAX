-- DESCRIPTION: The object will give the player an armour boost or deduction if used.
-- Armour v7
-- DESCRIPTION: [PROMPT_TEXT$="E to consume"]
-- DESCRIPTION: [PROMPT_IF_COLLECTABLE$="E to collect"]
-- DESCRIPTION: [USEAGE_TEXT$="Armour worn"]
-- DESCRIPTION: [QUANTITY=10(1,100)]
-- DESCRIPTION: [PICKUP_RANGE=80(1,100)]
-- DESCRIPTION: [@PICKUP_STYLE=2(1=Automatic, 2=Manual)]
-- DESCRIPTION: [@EFFECT=1(1=Add, 2=Deduct)]
-- DESCRIPTION: [USER_GLOBAL_AFFECTED$="MyArmour"]
-- DESCRIPTION: <Sound0> for collection sound.

local armour = {}
local use_item_now = {}

function armour_properties(e, prompt_text, prompt_if_collectable, useage_text, quantity, pickup_range, pickup_style, effect, user_global_affected)
	armour[e] = g_Entity[e]	
	armour[e].prompt_text = prompt_text
	armour[e].prompt_if_collectable = prompt_if_collectable
	armour[e].useage_text = useage_text
	armour[e].quantity = quantity
	armour[e].pickup_range = pickup_range
	armour[e].pickup_style = pickup_style
	armour[e].effect = effect
	armour[e].user_global_affected = user_global_affected
end

function armour_init(e)
	armour[e] = g_Entity[e]
	armour[e].prompt_text = "E to Use"
	armour[e].prompt_if_collectable = "E to collect"
	armour[e].useage_text = "Armour worn"
	armour[e].quantity = 10
	armour[e].pickup_range = 80
	armour[e].pickup_style = 1
	armour[e].effect = 1
	armour[e].user_global_affected = "MyArmour"
	use_item_now[e] = 0
end

function armour_main(e)
	armour[e] = g_Entity[e]
	PlayerDist = GetPlayerDistance(e)	
	if armour[e].pickup_style == 1 then
		if PlayerDist < armour[e].pickup_range then
			PromptDuration(armour[e].useage_text,1000)
			use_item_now[e] = 1
		end
	end
	if armour[e].pickup_style == 2 then
		local LookingAt = GetPlrLookingAtEx(e,1)
		if LookingAt == 1 and PlayerDist < armour[e].pickup_range then
			if GetEntityCollectable(e) == 0 then				
				PromptDuration(armour[e].prompt_text,1000)
				if g_KeyPressE == 1 then				
					use_item_now[e] = 1
				end
			else
				if GetEntityCollected(e) == 0 then
					Prompt(armour[e].prompt_if_collectable)
					if g_KeyPressE == 1 then
						SetEntityCollected(e,1,-1)
					end
				end
			end
		end
	end
	local tusedvalue = GetEntityUsed(e)
	if tusedvalue > 0 then
		PromptDuration(armour[e].useage_text,2000)
		use_item_now[e] = 1
		SetEntityUsed(e,tusedvalue*-1)
	end
	local addquantity = 0
	if use_item_now[e] == 1 then
		PlaySound(e,0)
		PerformLogicConnections(e)
		if armour[e].effect == 1 then addquantity = 1 end
		if armour[e].effect == 2 then addquantity = 2 end
		Destroy(e)
	end
	local currentvalue = 0
	if addquantity == 1 then
		if armour[e].user_global_affected > "" then 
			if _G["g_UserGlobal['"..armour[e].user_global_affected.."']"] ~= nil then currentvalue = _G["g_UserGlobal['"..armour[e].user_global_affected.."']"] end
			_G["g_UserGlobal['"..armour[e].user_global_affected.."']"] = currentvalue + armour[e].quantity
		end
	end
	if addquantity == 2 then
		if armour[e].user_global_affected > "" then 
			if _G["g_UserGlobal['"..armour[e].user_global_affected.."']"] ~= nil then currentvalue = _G["g_UserGlobal['"..armour[e].user_global_affected.."']"] end
			_G["g_UserGlobal['"..armour[e].user_global_affected.."']"] = currentvalue - armour[e].quantity
		end
	end
end
