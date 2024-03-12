-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- Global Modifier v6: by Necrym59
-- DESCRIPTION: The attached object when activated will pass a global modifier value for use with other behaviors, such as countdowns or monitors.
-- DESCRIPTION: [PROMPT_TEXT$="E to collect"]
-- DESCRIPTION: [COLLECTED_TEXT$="Modifier collected"]
-- DESCRIPTION: [MODIFIER_LEVEL=10(1,30)]
-- DESCRIPTION: [PICKUP_RANGE=90(1,100)]
-- DESCRIPTION: [@ACTIVATION_STYLE=1(1=Automatic Pickup, 2=Manual Pickup, 3=External Triggered)]
-- DESCRIPTION: [USER_GLOBAL_AFFECTED$="MyGlobalModifier"]
-- DESCRIPTION: [@EFFECT=1(1=Add, 2=Deduct)]
-- DESCRIPTION: [HEALTH_MODIFIER=0(0,100)]
-- DESCRIPTION: [@WHEN ACTIVATED=1(1=Do Nothing, 2=Hide, 3=Show, 4=Destroy)]
-- DESCRIPTION: [@PROMPT_DISPLAY=1(1=Local,2=Screen)]
-- DESCRIPTION: Play the audio <Sound0> when picked up

local module_misclib = require "scriptbank\\module_misclib"
local U = require "scriptbank\\utillib"
g_tEnt = {}

local modifier 				= {}
local prompt_text 			= {}
local collected_text 		= {}
local modifier_level 		= {}
local pickup_range 			= {}
local activation_style 		= {}
local user_global_affected	= {}
local effect				= {}
local health_modifier		= {}
local when_activated		= {}
local prompt_display 		= {}

local currentvalue 		= {}
local pressed 			= {}
local played 			= {}
local status			= {}
local tEnt				= {}
local selectobj			= {}

function global_modifier_properties(e, prompt_text, collected_text, modifier_level, pickup_range, activation_style, user_global_affected, effect, health_modifier, when_activated, prompt_display)
	modifier[e] = g_Entity[e]
	modifier[e].prompt_text = prompt_text
	modifier[e].collected_text = collected_text
	modifier[e].modifier_level = modifier_level
	modifier[e].pickup_range = pickup_range
	modifier[e].activation_style = activation_style
	modifier[e].user_global_affected = user_global_affected
	modifier[e].effect = effect
	modifier[e].health_modifier = health_modifier
	modifier[e].when_activated = when_activated
	modifier[e].prompt_display = prompt_display
end

function global_modifier_init(e)
	modifier[e] = {}
	modifier[e].prompt_text = "E to collect"
	modifier[e].collected_text = "Collected modifier"
	modifier[e].modifier_level = 0
	modifier[e].pickup_range = 50
	modifier[e].activation_style = activation_style
	modifier[e].user_global_affected = "MyModifier"
	modifier[e].effect = 1
	modifier[e].health_modifier = 0
	modifier[e].when_activated = 1
	modifier[e].prompt_display = 1	

	played[e] = 0
	pressed[e] = 0
	currentvalue[e] = 0
	tEnt[e] = 0
	g_tEnt = 0
	selectobj[e] = 0
	status[e] = "init"
end

function global_modifier_main(e)

	if status[e] == "init" then
		status[e] = "endinit"
	end

	local PlayerDist = GetPlayerDistance(e)

	if modifier[e].activation_style == 1 and PlayerDist < modifier[e].pickup_range then
		if modifier[e].prompt_display == 1 then PromptLocal(e,modifier[e].collected_text) end
		if modifier[e].prompt_display == 2 then Prompt(modifier[e].collected_text) end	
		if played[e] == 0 then
			PlaySound(e,0)
			played[e] = 1
		end
		PerformLogicConnections(e)
		if modifier[e].user_global_affected > "" and modifier[e].effect == 1 then
			if _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] end
			_G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] = currentvalue[e] + modifier[e].modifier_level
			SetPlayerHealth(g_PlayerHealth + modifier[e].health_modifier)
		end
		if modifier[e].user_global_affected > "" and modifier[e].effect == 2 then
			if _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] end
			_G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] = currentvalue[e] - modifier[e].modifier_level
			SetPlayerHealth(g_PlayerHealth - modifier[e].health_modifier)
		end
		Hide(e)
		CollisionOff(e)
		Destroy(e)
		pressed[e] = 1
		tEnt[e] = 0
	end

	if modifier[e].activation_style == 2 and PlayerDist < modifier[e].pickup_range then
		--pinpoint select object--
		module_misclib.pinpoint(e,modifier[e].pickup_range,300)
		tEnt[e] = g_tEnt
		--end pinpoint select object--
	end

	if PlayerDist < modifier[e].pickup_range and tEnt[e] ~= 0 then
		if modifier[e].prompt_display == 1 then PromptLocal(e,modifier[e].prompt_text) end
		if modifier[e].prompt_display == 2 then Prompt(modifier[e].prompt_text) end	
		if g_KeyPressE == 1 and pressed[e] == 0 then
			if modifier[e].prompt_display == 1 then PromptLocal(e,modifier[e].collected_text) end
			if modifier[e].prompt_display == 2 then Prompt(modifier[e].collected_text) end			
			PlaySound(e,0)
			PerformLogicConnections(e)
			if modifier[e].user_global_affected > "" and modifier[e].effect == 1 then
				if _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] end
				_G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] = currentvalue[e] + modifier[e].modifier_level
				SetPlayerHealth(g_PlayerHealth + modifier[e].health_modifier)
			end
			if modifier[e].user_global_affected > "" and modifier[e].effect == 2 then
				if _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] end
				_G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] = currentvalue[e] - modifier[e].modifier_level
				SetPlayerHealth(g_PlayerHealth - modifier[e].health_modifier)
			end
			Hide(e)
			CollisionOff(e)
			Destroy(e)
			pressed[e] = 1
		end
	end
	
	if modifier[e].activation_style == 3 then
		if g_Entity[e].activated == 1 then
			if modifier[e].prompt_display == 1 then PromptLocal(e,modifier[e].collected_text) end
			if modifier[e].prompt_display == 2 then Prompt(modifier[e].collected_text) end
			if played[e] == 0 then
				PlaySound(e,0)
				played[e] = 1
			end
			PerformLogicConnections(e)
			if modifier[e].user_global_affected > "" and modifier[e].effect == 1 then
				if _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] end
				_G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] = currentvalue[e] + modifier[e].modifier_level
				SetPlayerHealth(g_PlayerHealth + modifier[e].health_modifier)
			end
			if modifier[e].user_global_affected > "" and modifier[e].effect == 2 then
				if _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] end
				_G["g_UserGlobal['"..modifier[e].user_global_affected.."']"] = currentvalue[e] - modifier[e].modifier_level
				SetPlayerHealth(g_PlayerHealth - modifier[e].health_modifier)
			end
			if modifier[e].when_activated == 1 then end	--do nothing
			if modifier[e].when_activated == 2 then		--hide
				CollisionOff(e)
				Hide(e)
			end
			if modifier[e].when_activated == 3 then 	--show
				Show(e)
			end
			if modifier[e].when_activated == 4 then 	--destroy	
				CollisionOff(e)
				Hide(e)				
				Destroy(e)
			end
			pressed[e] = 1
			tEnt[e] = 0
		end
	end
end