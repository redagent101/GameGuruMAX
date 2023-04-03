-- Chest v3
-- DESCRIPTION: When player is within [USE_RANGE=100], show
-- DESCRIPTION: [USE_PROMPT$="Press E to open"] when use key is pressed,
-- DESCRIPTION: will display [CHEST_SCREEN$="HUD Screen 6"],
-- DESCRIPTION: using [CHEST_CONTAINER$="chestunique"].
-- DESCRIPTION: <Sound0> for opening chest.
-- DESCRIPTION: <Sound1> for closing chest.

local chest = {}
local use_range = {}
local use_prompt = {}
local chest_screen = {}
local chest_container = {}
local status = {}
local doonce = {}

function chest_properties(e, use_range, use_prompt, chest_screen, chest_container)
	chest[e].use_range = use_range
	chest[e].use_prompt = use_prompt
	chest[e].chest_screen = chest_screen
	chest[e].chest_container = chest_container
end

function chest_init(e)
	chest[e] = {}
	chest[e].use_range = 100
	chest[e].use_prompt = "Press E to open"
	chest[e].chest_screen = "HUD Screen 6"
	chest[e].chest_container = "chestunique"
	status[e] = "closed"
end

function chest_main(e)
	if GetCurrentScreen() == -1 and status[e] == "closed" then
		-- in the game
		PlayerDist = GetPlayerDistance(e)
		if PlayerDist < chest[e].use_range then
			PromptDuration(chest[e].use_prompt ,1000)
			if g_KeyPressE == 1 then
				SetAnimationName(e,"open")
				PlayAnimation(e)
				PlaySound(e,0)
				if chest[e].chest_container == "chestunique" then
					g_UserGlobalContainer = "chestuniquetolevelase"..tostring(e)
				else
					g_UserGlobalContainer = chest[e].chest_container
				end
				ScreenToggle(chest[e].chest_screen)
				status[e] = "opened"				
			end
		end
	else
		-- in chest screen
	end
	if GetCurrentScreen() == -1 and status[e] == "opened" then
		SetAnimationName(e,"close")
		PlayAnimation(e)
		PlaySound(e,1)
		status[e] = "closed"
	end		
end
