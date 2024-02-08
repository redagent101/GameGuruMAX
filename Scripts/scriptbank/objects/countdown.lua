-- Countdown v10 by Necrym59
-- DESCRIPTION: Countdown timer to count down to an end action.
-- DESCRIPTION: Attach to an object. Set Always Active ON. Trigger from a zone or switch.
-- DESCRIPTION: [#MAXIMUM_TIME=1.00(0.25,60.00)]
-- DESCRIPTION: [@TIME_DISPLAY=1(1=On, 2=Off)]
-- DESCRIPTION: [DISPLAY_TEXT$="Time Left:"]
-- DESCRIPTION: [DISPLAY_X=10]
-- DESCRIPTION: [DISPLAY_Y=10]
-- DESCRIPTION: [DISPLAY_SIZE=3(1,5)]
-- DESCRIPTION: [@END_ACTION=1(1=Terminate Player, 2=Hurt Player, 3=Activate Entities, 4=Lose Game, 5=Win Game, 6=Display Hud Screen)]
-- DESCRIPTION: [USER_GLOBAL_MODIFIER$="MyGlobalModifier"]
-- DESCRIPTION: [@LAUNCH_WARNING=1(1=Off, 2=On)]
-- DESCRIPTION: [END_SCREEN$="HUD Screen #"]
-- DESCRIPTION: <Sound0> for commence sound
-- DESCRIPTION: <Sound1> for end sound

local countdown 			= {}
local maximum_time 			= {}
local time_display 			= {}
local display_text 			= {}
local display_x 			= {}
local display_y 			= {}
local display_size 			= {}
local end_action 			= {}
local user_global_modifier	= {}
local launch_warning		= {}
local launch_warning_x		= {}
local launch_warning_y		= {}
local launch_size			= {}

local secondsleft 	= {}
local minutesleft 	= {}
local timeleftsec	= {}
local startcount 	= {}
local maxcount 		= {}
local played		= {}
local status		= {}
local wait			= {}
local launch_stage	= {}
local launch_count	= {}
local currentvalue	= {}
local doonce		= {}

function countdown_properties(e,maximum_time, time_display, display_text, display_x, display_y, display_size, end_action, user_global_modifier, launch_warning, end_screen)
	countdown[e] = g_Entity[e]
	countdown[e].maximum_time = maximum_time
	countdown[e].time_display = time_display
	countdown[e].display_text = display_text	
	countdown[e].display_x = display_x
	countdown[e].display_y = display_y
	countdown[e].display_size = display_size
	countdown[e].end_action = end_action
	countdown[e].user_global_modifier = user_global_modifier
	countdown[e].launch_warning = launch_warning
	countdown[e].end_screen = end_screen
end

function countdown_init(e)
	countdown[e] = {}
	countdown[e].maximum_time = 10
	countdown[e].time_display = 1
	countdown[e].display_text = "Time Left:"
	countdown[e].display_x = 10
	countdown[e].display_y = 10
	countdown[e].display_size = 3
	countdown[e].end_action = 1
	countdown[e].user_global_modifier = ""
	countdown[e].launch_warning = 1
	countdown[e].end_screen = ""
	
	startcount[e] = 0
	maxcount[e] = 0
	secondsleft[e] = 0
	minutesleft[e] = 0
	timeleftsec[e] = 0
	played[e] = 0
	doonce[e] = 0
	launch_stage[e] = 0
	launch_count[e] = 600	
	currentvalue[e] = 0	
	wait[e] = math.huge	
	status[e] = "init"
end
 
function countdown_main(e)
	if status[e] == "init" then
		launch_stage[e] = 0
		if countdown[e].launch_warning == 1 then launch_stage[e] = 1 end
		startcount[e] = 0
		maxcount[e] = (countdown[e].maximum_time * 1000) * 60		
		status[e] = "endinit"
	end

	if g_Entity[e]['activated'] == 1 then
	
		if countdown[e].launch_warning == 2 and launch_stage[e] == 0 then
			if launch_stage[e] == 0 then 
				if launch_count[e] > 400  then TextCenterOnX(50,50,5,"READY") end
				if launch_count[e] > 200 and launch_count[e] <= 400 then TextCenterOnX(50,50,5,"SET") end
				if launch_count[e] <= 200  then TextCenterOnX(50,50,5,"GO") end
				if launch_count[e] <= 100 then
					launch_stage[e] = 1
					if played[e] == 0 then
						PlaySound(e,0)
						played[e] = 1
					end
				end
				launch_count[e] = launch_count[e] - 1
			end
		end		
		if startcount[e] == 0 and launch_stage[e] == 1 then
			played[e] = 0
			StartTimer(e)
			startcount[e] = 1
		end
		if startcount[e] == 1 then
			if countdown[e].user_global_modifier > "" then
				if _G["g_UserGlobal['"..countdown[e].user_global_modifier.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..countdown[e].user_global_modifier.."']"] end
				if currentvalue[e] > 0 then
					maxcount[e] = (maxcount[e] + currentvalue[e] * 1000)
					StartTimer(e)
					startcount[e] = 1
					_G["g_UserGlobal['"..countdown[e].user_global_modifier.."']"] = 0
				end	
			end
			secondsleft[e] = math.floor((maxcount[e]/1000)-GetTimer(e)/1000)
			minutesleft[e] = math.floor(((maxcount[e]/1000)/60)-((GetTimer(e)/1000)/60))
			timeleftsec[e] = secondsleft[e] - (minutesleft[e]*60)			
			if countdown[e].time_display == 1 then
				if countdown[e].display_x < 50 or countdown[e].display_x > 50 then
					if minutesleft[e] > 0 and secondsleft[e] > 9 then Text(countdown[e].display_x, countdown[e].display_y, countdown[e].display_size, countdown[e].display_text.. " " ..minutesleft[e].. " : " ..timeleftsec[e]) end
					if minutesleft[e] == 0 and secondsleft[e] > 9 then Text(countdown[e].display_x, countdown[e].display_y, countdown[e].display_size,countdown[e].display_text.. " 0 : " ..timeleftsec[e]) end
					if minutesleft[e] > 0 and secondsleft[e] < 10 then Text(countdown[e].display_x, countdown[e].display_y, countdown[e].display_size, countdown[e].display_text.. " " ..minutesleft[e].. " : 0" ..timeleftsec[e]) end
					if minutesleft[e] == 0 and secondsleft[e] < 10 then Text(countdown[e].display_x, countdown[e].display_y, countdown[e].display_size,countdown[e].display_text.. " 0 : 0" ..timeleftsec[e]) end
					
				end
				if countdown[e].display_x == 50 then
					if minutesleft[e] > 0 and secondsleft[e] > 9  then TextCenterOnX(countdown[e].display_x, countdown[e].display_y, countdown[e].display_size, countdown[e].display_text.. " " ..minutesleft[e].. " : " ..timeleftsec[e]) end
					if minutesleft[e] == 0 and secondsleft[e] > 9 then TextCenterOnX(countdown[e].display_x, countdown[e].display_y, countdown[e].display_size,countdown[e].display_text.. " 0 : " ..timeleftsec[e]) end
					if minutesleft[e] > 0 and secondsleft[e] < 10 then TextCenterOnX(countdown[e].display_x, countdown[e].display_y, countdown[e].display_size, countdown[e].display_text.. " " ..minutesleft[e].. " : 0" ..timeleftsec[e]) end
					if minutesleft[e] == 0 and secondsleft[e] < 10 then TextCenterOnX(countdown[e].display_x, countdown[e].display_y, countdown[e].display_size,countdown[e].display_text.. " 0 : 0" ..timeleftsec[e]) end
				end
			end
			if countdown[e].time_display == 2 then end
		
			if secondsleft[e] == 0 then
				if played[e] == 0 then
					PlaySound(e,1)
					played[e] = 1
				end
				if countdown[e].end_action == 1 then
					HurtPlayer(e,g_PlayerHealth)
				end
				if countdown[e].end_action == 2 then
					HurtPlayer(e,g_PlayerHealth/3)
				end
				if countdown[e].end_action == 3 then
					if doonce[e] == 0 then
						ActivateIfUsed(e)
						PerformLogicConnections(e)
						doonce[e] = 1
					end
				end
				if countdown[e].end_action == 4 then
					LoseGame()
				end
				if countdown[e].end_action == 5 then
					WinGame()
				end
				if countdown[e].end_action == 6 then
					ScreenToggle(countdown[e].end_screen)
				end
			end
		end
	end

	if g_Entity[e]['activated'] == 0 then
		status[e] = "init"
	end
end

function level_countdown_exit(e)
end

