-- DESCRIPTION: Allows to receive information about an object.
-- Investigate v8
-- DESCRIPTION: [PROMPT_TEXT$="E to investigate"]
-- DESCRIPTION: [USE_RANGE=80(1,100)]
-- DESCRIPTION: [@INVESTIGATION_STYLE=1(1=Text, 2=Text+Sound, 3=Image+Sound, 4=Text+Image+Sound)]
-- DESCRIPTION: [INVESTIGATION_TEXT$="Evidence"]
-- DESCRIPTION: [TEXT_POSITION_Y=90(1,100)]
-- DESCRIPTION: [@FREEZE_SCREEN=2(1=Yes, 2=No)]
-- DESCRIPTION: [EXIT_TEXT$="Q to exit"]
-- DESCRIPTION: [IMAGEFILE$="imagebank\\misc\\testimages\\investigate_01.png"]
-- DESCRIPTION: [@PROMPT_DISPLAY=1(1=Local,2=Screen)]
-- DESCRIPTION: <Sound0> investigate narration sound file

local module_misclib = require "scriptbank\\module_misclib"
local U = require "scriptbank\\utillib"
g_tEnt = {}

local investigate = {}
local prompt_text = {}
local use_range = {}
local investigate_style = {}
local investigate_text = {}
local text_position_y = {}
local freeze_screen = {}
local exit_text = {}
local investigate_image = {}
local prompt_display = {}

local investigatesp = {}
local status = {}
local looking = {}
local imagesize = {}
local played = {}
local tEnt = {}
local selectobj = {}

function investigate_properties(e, prompt_text, use_range, investigation_style, investigation_text, text_position_y, freeze_screen, exit_text, investigation_image, prompt_display)
	investigate[e].prompt_text = prompt_text
	investigate[e].use_range = use_range
	investigate[e].investigation_style = investigation_style
	investigate[e].investigation_text = investigation_text
	investigate[e].text_position_y = text_position_y
	investigate[e].freeze_screen = freeze_screen
	investigate[e].exit_text = exit_text	
	investigate[e].investigation_image = investigation_image or imagefile
	investigate[e].prompt_display = prompt_display
end

function investigate_init(e)
	investigate[e] = {}
	investigate[e].prompt_text = "E to investigate"
	investigate[e].use_range = 80
	investigate[e].investigation_style = 1
	investigate[e].investigation_text = ""
	investigate[e].text_position_y = 90
	investigate[e].freeze_screen = 2
	investigate[e].exit_text = exit_text	
	investigate[e].investigation_image = ""
	investigate[e].prompt_display = 1
	imagesize[e] = 8
	played[e] = 0
	looking[e] = 0
	tEnt[e] = 0
	g_tEnt = 0	
	selectobj[e] = 0
	status[e] = "init"
end

function investigate_main(e)

	if status[e] == "init" then
		if investigate[e].investigation_style == 3 or investigate[e].investigation_style == 4 then
			if investigate[e].investigation_image > "" then 
				local imgAspectRatio = GetImageHeight(investigate[e].investigation_image) / GetImageWidth(investigate[e].investigation_image)
				local imgWidth = imagesize[e]
				local imgHeight = imgWidth * imgAspectRatio
				investigatesp[e] = CreateSprite(LoadImage(investigate[e].investigation_image))
				SetSpriteSize(investigatesp[e],imgWidth,imgHeight)
				SetSpritePosition(investigatesp[e],500,500)
			end
		end
		status[e] = "search"
	end
	
	if status[e] == "search" then
		local PlayerDist = GetPlayerDistance(e)
		if PlayerDist < investigate[e].use_range then
			--pinpoint select object--
			module_misclib.pinpoint(e,investigate[e].use_range,300)
			tEnt[e] = g_tEnt
			--end pinpoint select object--
		end
		if PlayerDist < investigate[e].use_range and tEnt[e] ~= 0 and GetEntityVisibility(e) == 1 then
			if investigate[e].prompt_display == 1 then PromptLocal(e,investigate[e].prompt_text) end
			if investigate[e].prompt_display == 2 then Prompt(investigate[e].prompt_text) end
			if g_KeyPressE == 1 then
				status[e] = "investigate"
				looking[e] = 1
				if investigate[e].freeze_screen == 1 then SetCameraOverride(3) end
			end			
		end
	end
	
	if status[e] == "investigate" then
		PromptLocal(e,"")
		if investigate[e].investigation_style == 1 then
			TextCenterOnX(50,investigate[e].text_position_y,3,investigate[e].investigation_text)
			if GetPlayerDistance(e) > investigate[e].use_range*3 and looking[e] == 1 then SetGamePlayerStatePlrKeyForceKeystate(16) end
			Prompt(investigate[e].exit_text)
		end
		if investigate[e].investigation_style == 2 then
			TextCenterOnX(50,investigate[e].text_position_y,3,investigate[e].investigation_text)			
			if played[e] == 0 then
				PlaySound(e,0)
				played[e] = 1
			end
			if GetPlayerDistance(e) > investigate[e].use_range*3 and looking[e] == 1 then SetGamePlayerStatePlrKeyForceKeystate(16) end
			Prompt(investigate[e].exit_text)
		end
		if investigate[e].investigation_style == 3 then
			if investigate[e].investigation_image > "" then
				PasteSpritePosition(investigatesp[e],50-(imagesize[e]/2),50-(imagesize[e]/2))	
			end
			if played[e] == 0 then
				PlaySound(e,0)
				played[e] = 1
			end			
			if GetPlayerDistance(e) > investigate[e].use_range*3 and looking[e] == 1 then SetGamePlayerStatePlrKeyForceKeystate(16) end			
			Prompt(investigate[e].exit_text)
		end
		if investigate[e].investigation_style == 4 then
			TextCenterOnX(50,investigate[e].text_position_y,3,investigate[e].investigation_text)
			if investigate[e].investigation_image > "" then
				PasteSpritePosition(investigatesp[e],50-(imagesize[e]/2),60-(imagesize[e]/2))
			end
			if played[e] == 0 then
				PlaySound(e,0)
				played[e] = 1
			end
			if GetPlayerDistance(e) > investigate[e].use_range*3 and looking[e] == 1 then SetGamePlayerStatePlrKeyForceKeystate(16) end
			Prompt(investigate[e].exit_text)
		end			
		if g_KeyPressQ == 1 then
			if investigate[e].investigation_style == 3 or investigate[e].investigation_style == 4 and investigate[e].investigation_image > "" then SetSpritePosition(investigatesp[e],500,500) end
			SetGamePlayerStatePlrKeyForceKeystate(0)
			Prompt("")
			SetCameraOverride(0)
			status[e] = "search"
			played[e] = 0
			looking[e] = 0
		end		
	end
end
