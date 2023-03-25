-- Quest Poster v1
-- DESCRIPTION: When player is within [RANGE=100] distance, show [QUEST_PROMPT$="Press E to view this quest"] and when E is pressed, player will be shown the [QUEST_SCREEN$="HUD Screen 8"].
-- DESCRIPTION: [@QuestChoice=1(0=QuestList)]
-- DESCRIPTION: <Sound0> when viewing the quest.

local g_quest_poster = {}

function quest_poster_init(e)
	g_quest_poster[e] = {}
	quest_poster_properties(e,100,"Press E to view this quest","HUD Screen 8","")
end

function quest_poster_properties(e, range, questprompt, questscreen, questchoice)
	g_quest_poster[e]['range'] = range
	g_quest_poster[e]['questprompt'] = questprompt
	g_quest_poster[e]['questscreen'] = questscreen
	g_quest_poster[e]['questchoice'] = questchoice
	g_quest_poster[e]['questtitle'] = ""
	g_quest_poster[e]['questdescription1'] = ""
	g_quest_poster[e]['questdescription2'] = ""
	g_quest_poster[e]['questdescription3'] = ""
	g_quest_poster[e]['questobject'] = ""
end

function quest_poster_main(e)

	if g_quest_poster[e]['questtitle'] == "" then
		local totalquests = GetCollectionQuestQuantity()
		if totalquests ~= nil then
			local i = tonumber(g_quest_poster[e]['questchoice'])-1
			if i ~= nil then
				if i > 0 and i < totalquests then
					g_quest_poster[e]['questtitle'] = GetCollectionQuestAttribute(i,"title")
					g_quest_poster[e]['questdescription1'] = GetCollectionQuestAttribute(i,"task1")
					g_quest_poster[e]['questdescription2'] = GetCollectionQuestAttribute(i,"task2")
					g_quest_poster[e]['questdescription3'] = GetCollectionQuestAttribute(i,"task3")
					g_quest_poster[e]['questobject'] = GetCollectionQuestAttribute(i,"object")
					local a = GetCollectionQuestAttribute(i,"level")
					local b = GetCollectionQuestAttribute(i,"points")
					local c = GetCollectionQuestAttribute(i,"value")
					local d = GetCollectionQuestAttribute(i,"status")
				end
			else
				PromptDuration(g_quest_poster[e]['questchoice'],5000)
			end
		end
	end
	
	if g_UserGlobalQuestTitleActive ~= nil then
		if g_quest_poster[e]['questtitle'] ~= g_UserGlobalQuestTitleActive then
			-- show in the game, not our current one
			Show(e)
			PlayerDist = GetPlayerDistance(e)
			if PlayerDist < g_quest_poster[e]['range'] then
				PromptDuration(g_quest_poster[e]['questprompt'] ,1000)	
				if g_KeyPressE == 1 then
					_G["g_UserGlobal['".."MyQuestShowTitle".."']"] = g_quest_poster[e]['questtitle']
					_G["g_UserGlobal['".."MyQuestShowTask1".."']"] = g_quest_poster[e]['questdescription1']
					_G["g_UserGlobal['".."MyQuestShowTask2".."']"] = g_quest_poster[e]['questdescription2']
					_G["g_UserGlobal['".."MyQuestShowTask3".."']"] = g_quest_poster[e]['questdescription3']
					g_UserGlobalQuestTitleShowing = g_quest_poster[e]['questtitle']
					g_UserGlobalQuestTitleShowingObject = g_quest_poster[e]['questobject']
					ScreenToggle(g_quest_poster[e]['questscreen'])
				end
			end
		else
			-- hide in game, we have accepted this one and doing it now
			Hide(e)
			if g_UserGlobalQuestTitleActiveE > 0 then
				if g_Entity[g_UserGlobalQuestTitleActiveE]['active'] == 0 then
					-- collect reward 
					local myMoney = 0
					if _G["g_UserGlobal['".."MyMoney".."']"] ~= nil then myMoney = _G["g_UserGlobal['".."MyMoney".."']"] end
					_G["g_UserGlobal['".."MyMoney".."']"] = myMoney + 1000
					-- and reset quest
					g_UserGlobalQuestTitleActive = ""
					g_UserGlobalQuestTitleActiveObject = ""
					g_UserGlobalQuestTitleActiveE = 0
					-- finished with quest_poster_init
					--Destroy(e)
				end
			end
		end
	end
end

