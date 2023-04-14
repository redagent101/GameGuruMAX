-- DESCRIPTION: The object will give the player a stamina boost or deduction if used.
-- Stamina v9
-- DESCRIPTION: [PROMPT_TEXT$="E to consume"]
-- DESCRIPTION: [PROMPT_IF_COLLECTABLE$="E to collect"]
-- DESCRIPTION: [USEAGE_TEXT$="Stamina consumed"]
-- DESCRIPTION: [QUANTITY=10(1,100)]
-- DESCRIPTION: [PICKUP_RANGE=80(1,100)]
-- DESCRIPTION: [@PICKUP_STYLE=1(1=Automatic, 2=Manual)]
-- DESCRIPTION: [@EFFECT=1(1=Add, 2=Deduct)]
-- DESCRIPTION: [USER_GLOBAL_AFFECTED$="MyStaminaMaximum"]
-- DESCRIPTION: <Sound0> for collection sound.

local U = require "scriptbank\\utillib"

local stamina = {}
local prompt_text = {}
local prompt_if_collectable = {}
local useage_text, quantity = {}
local pickup_range = {}
local pickup_style = {}
local effect = {}
local user_global_affected = {}
local use_item_now = {}
local tEnt = {}
local selectobj = {}

function stamina_properties(e, prompt_text, prompt_if_collectable, useage_text, quantity, pickup_range, pickup_style, effect, user_global_affected)
	stamina[e] = g_Entity[e]	
	stamina[e].prompt_text = prompt_text
	stamina[e].prompt_if_collectable = prompt_if_collectable
	stamina[e].useage_text = useage_text
	stamina[e].quantity = quantity
	stamina[e].pickup_range = pickup_range
	stamina[e].pickup_style = pickup_style
	stamina[e].effect = effect
	stamina[e].user_global_affected = user_global_affected
end

function stamina_init(e)
	stamina[e] = g_Entity[e]
	stamina[e].prompt_text = "E to consume"
	stamina[e].prompt_if_collectable = "E to collect"
	stamina[e].useage_text = "Stamina consumed"
	stamina[e].quantity = 10
	stamina[e].pickup_range = 80
	stamina[e].pickup_style = 1
	stamina[e].effect = 1
	stamina[e].user_global_affected = "MyStaminaMaximum"
	use_item_now[e] = 0
	tEnt[e] = 0
	selectobj[e] = 0
end

function stamina_main(e)
	stamina[e] = g_Entity[e]
	PlayerDist = GetPlayerDistance(e)	
	if stamina[e].pickup_style == 1 then
		if PlayerDist < stamina[e].pickup_range then
			PromptDuration(stamina[e].useage_text,1000)
			use_item_now[e] = 1
		end
	end
	if stamina[e].pickup_style == 2 and PlayerDist < stamina[e].pickup_range then
		--pinpoint select object--
		local px, py, pz = GetCameraPositionX(0), GetCameraPositionY(0), GetCameraPositionZ(0)
		local rayX, rayY, rayZ = 0,0,stamina[e].pickup_range
		local paX, paY, paZ = math.rad(GetCameraAngleX(0)), math.rad(GetCameraAngleY(0)), math.rad(GetCameraAngleZ(0))
		rayX, rayY, rayZ = U.Rotate3D(rayX, rayY, rayZ, paX, paY, paZ)
		selectobj[e]=IntersectAll(px,py,pz, px+rayX, py+rayY, pz+rayZ,e)
		if selectobj[e] ~= 0 or nil then
			if g_Entity[e]['obj'] == selectobj[e] then
				Text(50,50,3,"+") --highliting (with crosshair at present)
				tEnt[e] = e
			else
				tEnt[e] = 0
			end
		end	
		--end pinpoint select object--
		if PlayerDist < stamina[e].pickup_range and tEnt[e] ~= 0 or nil and GetEntityVisibility(e) == 1 then		
			if GetEntityCollectable(tEnt[e]) == 0 then
				PromptDuration(stamina[e].prompt_text,1000)
				if g_KeyPressE == 1 then				
					use_item_now[e] = 1
				end
			end
			if GetEntityCollectable(tEnt[e]) == 1 or GetEntityCollectable(tEnt[e]) == 2 then
				Prompt(stamina[e].prompt_if_collectable)
				-- if collectable or resource
				if g_KeyPressE == 1 then
					Hide(e)
					CollisionOff(e)
					SetEntityCollected(tEnt[e],1)
					PlaySound(e,1)
				end
			end
		end
	end
	local tusedvalue = GetEntityUsed(e)
	if tusedvalue > 0 then
		-- if this is a resource, it will deplete qty and set used to zero
		PromptDuration(stamina[e].useage_text,2000)		
		SetEntityUsed(e,tusedvalue*-1)
		use_item_now[e] = 1
	end
	local addquantity = 0
	if use_item_now[e] == 1 then
		PlaySound(e,0)
		PerformLogicConnections(e)
		if stamina[e].effect == 1 then addquantity = 1 end
		if stamina[e].effect == 2 then addquantity = 2 end
		Destroy(e) -- can only destroy resources that are qty zero
	end
	local currentvalue = 0
	if addquantity == 1 then
		if stamina[e].user_global_affected > "" then 
			if _G["g_UserGlobal['"..stamina[e].user_global_affected.."']"] ~= nil then currentvalue = _G["g_UserGlobal['"..stamina[e].user_global_affected.."']"] end
			_G["g_UserGlobal['"..stamina[e].user_global_affected.."']"] = currentvalue + stamina[e].quantity
		end
	end
	if addquantity == 2 then
		if stamina[e].user_global_affected > "" then 
			if _G["g_UserGlobal['"..stamina[e].user_global_affected.."']"] ~= nil then currentvalue = _G["g_UserGlobal['"..stamina[e].user_global_affected.."']"] end
			_G["g_UserGlobal['"..stamina[e].user_global_affected.."']"] = currentvalue - stamina[e].quantity
		end
	end
end