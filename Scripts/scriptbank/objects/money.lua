-- Money v6
-- DESCRIPTION: The object will give the player money.
-- DESCRIPTION: [PICKUP_TEXT$="E to Collect"]
-- DESCRIPTION: [COLLECTED_TEXT$="Money Collected"]
-- DESCRIPTION: [QUANTITY=10(0,100)]
-- DESCRIPTION: [PICKUP_RANGE=80(1,100)]
-- DESCRIPTION: [@PICKUP_STYLE=1(1=Automatic, 2=Manual)]
-- DESCRIPTION: [USER_GLOBAL_AFFECTED$="MyMoney"]
-- DESCRIPTION: [@EFFECT=1(1=Add, 2=Deduct)]
-- DESCRIPTION: [@PROMPT_DISPLAY=1(1=Local,2=Screen)]
-- DESCRIPTION: <Sound0> for collection sound.

local module_misclib = require "scriptbank\\module_misclib"
local U = require "scriptbank\\utillib"
g_tEnt = {}

local money = {}
local pickup_text = {}
local collected_text = {}
local quantity = {}
local pickup_range = {}
local pickup_style = {}
local user_global_affected = {}
local effect = {}
local prompt_display = {}

local tEnt = {}
local selectobj = {}
local played = {}
local currentvalue = {}

function money_properties(e, pickup_text, collected_text, quantity, pickup_range, pickup_style, user_global_affected, effect, prompt_display)
	money[e].pickup_text = pickup_text
	money[e].collected_text = collected_text
	money[e].quantity = quantity
	money[e].pickup_range = pickup_range
	money[e].pickup_style = pickup_style
	money[e].user_global_affected = "MyMoney"
	money[e].effect = effect
	money[e].prompt_display = prompt_display
end

function money_init(e)
	money[e] = {}
	money[e].pickup_text = "E to harvest"
	money[e].collected_text = "money harvested"
	money[e].quantity = 1
	money[e].pickup_range = 80
	money[e].pickup_style = 1
	money[e].user_global_affected = "MyMoney"
	money[e].effect = 1
	money[e].prompt_display = 1
	
	currentvalue[e] = 0
	played[e] = 0
	tEnt[e] = 0
	g_tEnt = 0
	selectobj[e] = 0
end

function money_main(e)
	local PlayerDist = GetPlayerDistance(e)	
	
	if money[e].pickup_style == 1 and PlayerDist < money[e].pickup_range then
		if money[e].prompt_display == 1 then PromptLocal(e,money[e].collected_text) end
		if money[e].prompt_display == 2 then Prompt(money[e].collected_text) end
		PerformLogicConnections(e)
		if played[e] == 0 then
			PlaySound(e,0)
			played[e] = 1
		end
		if money[e].user_global_affected > "" then
			if money[e].effect == 1	then
				if _G["g_UserGlobal['"..money[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..money[e].user_global_affected.."']"] end
				_G["g_UserGlobal['"..money[e].user_global_affected.."']"] = currentvalue[e] + money[e].quantity
			end	
			if money[e].effect == 2	then
				if _G["g_UserGlobal['"..money[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..money[e].user_global_affected.."']"] end
				_G["g_UserGlobal['"..money[e].user_global_affected.."']"] = currentvalue[e] - money[e].quantity
			end	
		end	
		Destroy(e)
		tEnt[e] = 0		
	end
	
	if money[e].pickup_style == 2 and PlayerDist < money[e].pickup_range then
		--pinpoint select object--
		module_misclib.pinpoint(e,money[e].pickup_range,300)
		tEnt[e] = g_tEnt
		--end pinpoint select object--
		
		if PlayerDist < money[e].pickup_range and tEnt[e] ~= 0 and GetEntityVisibility(e) == 1 then
			if money[e].prompt_display == 1 then PromptLocal(e,money[e].pickup_text) end
			if money[e].prompt_display == 2 then Prompt(money[e].pickup_text) end
			if g_KeyPressE == 1 then
				if money[e].prompt_display == 1 then PromptLocal(e,money[e].collected_text) end
				if money[e].prompt_display == 2 then Prompt(money[e].collected_text) end
				PerformLogicConnections(e)
				if played[e] == 0 then
					PlaySound(e,0)
					played[e] = 1
				end
				if money[e].user_global_affected > "" then
					if money[e].effect == 1	then
						if _G["g_UserGlobal['"..money[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..money[e].user_global_affected.."']"] end
						_G["g_UserGlobal['"..money[e].user_global_affected.."']"] = currentvalue[e] + money[e].quantity
					end	
					if money[e].effect == 2	then
						if _G["g_UserGlobal['"..money[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..money[e].user_global_affected.."']"] end
						_G["g_UserGlobal['"..money[e].user_global_affected.."']"] = currentvalue[e] - money[e].quantity
					end	
				end	
				Destroy(e)
				tEnt[e] = 0
			end
		end
	end	
end
