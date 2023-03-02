-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- Arrow Trap v3 - by Necrym59 
-- DESCRIPTION: The Arrow-trap will fire arrows when in range. Always Active ON. Physics OFF
-- DESCRIPTION: When the player is within [TRAP_RANGE=50(10,500)] the traps [TRAP_SPEED=2(1,10)] and causing [TRAP_DAMAGE=3(0,500)]
-- DESCRIPTION: The [@TRAP_MODE=1(1=One shot, 2=Repeating)] the [HIT_DISTANCE=30(1,50)] and [RESET_DISTANCE=200(1,500)]
-- DESCRIPTION: <Sound0> Firing Sound 

	local arrowtrap = {}
	local trap_range = {}	
	local trap_speed = {}
	local trap_damage = {}
	local trap_mode = {}
	local hit_distance = {}
	local reset_distance = {}
	local startx = {}
	local starty = {}
	local startz = {}
	local startax = {}
	local startay = {}
	local startaz = {}
	local firing = {}
	local hit = {}
	local status = {}
	local movedist = {}
	
function arrowtrap_properties(e, trap_range, trap_speed, trap_damage, trap_mode, hit_distance, reset_distance)
	arrowtrap[e] = g_Entity[e]
	arrowtrap[e].trap_range 		= trap_range			--trigger trap_range
	arrowtrap[e].trap_speed			= trap_speed			--how fast the arrow will travel
	arrowtrap[e].trap_damage		= trap_damage			--trap_damage applied
	arrowtrap[e].trap_mode			= trap_mode				--1 for one time, 2 for repeating
	arrowtrap[e].hit_distance		= hit_distance			--how far away to determine a hit 
	arrowtrap[e].reset_distance		= reset_distance		--distance to reset
end

function arrowtrap_init(e)
	arrowtrap[e] = g_Entity[e]
	arrowtrap[e].trap_range 			= 50
	arrowtrap[e].trap_speed 			= 2
	arrowtrap[e].trap_damage 			= 3
	arrowtrap[e].trap_mode 				= 2
	arrowtrap[e].hit_distance 			= 70
	arrowtrap[e].reset_distance 		= 200
	CollisionOff(e)
	firing[e] = 0
	hit[e] = 0
	status[e] = "init"
	movedist[e] = 0
end

function arrowtrap_main(e)
	arrowtrap[e] = g_Entity[e]
	if status[e] == "init" then
		GravityOff(e)		
		if startx[e] == nil or starty[e] == nil or startz[e] == nil then		
			startx[e] = g_Entity[e]['x']
			starty[e] = g_Entity[e]['y']
			startz[e] = g_Entity[e]['z']
			startax[e] = g_Entity[e]['anglex']
			startay[e] = g_Entity[e]['angley']	
			startaz[e] = g_Entity[e]['anglez']	
		end
		status[e] = "alert"
	end
	
	if status[e] == "alert" then		
		if firing[e] == 0 then
			if GetPlayerDistance(e) <= arrowtrap[e].trap_range then
				hit[e] = 0
				firing[e] = 1
				PlaySound(e,0)
				status[e] = "firing"
			end
		end
	end	
	if status[e] == "firing" then
		if arrowtrap[e].trap_mode == 1 then
			if firing[e] == 1 then
				if movedist[e] < arrowtrap[e].reset_distance then
					MoveForward(e,arrowtrap[e].trap_speed*100)
					movedist[e] = movedist[e] + arrowtrap[e].trap_speed
					if GetPlayerDistance(e) < arrowtrap[e].trap_range * 2 then
						Show(e)
					end	
					if GetPlayerDistance(e) <= arrowtrap[e].hit_distance and hit[e] == 0 then						
						HurtPlayer(-1,arrowtrap[e].trap_damage)
						hit[e] = 1
					end
				else
					movedist[e] = 0
					Hide(e)
					Destroy(e)
				end
			end
		end	
		if arrowtrap[e].trap_mode == 2 then
			if firing[e] == 1 then
				if movedist[e] < arrowtrap[e].reset_distance then				
					MoveForward(e,arrowtrap[e].trap_speed*100)
					movedist[e] = movedist[e] + arrowtrap[e].trap_speed
					if GetPlayerDistance(e) < arrowtrap[e].trap_range * 2 then
						Show(e)
					end
					if GetPlayerDistance(e) <= arrowtrap[e].hit_distance and hit[e] == 0 then						
						HurtPlayer(-1,arrowtrap[e].trap_damage)
						hit[e] = 1
					end
				else
					firing[e] = 0					
					SetPosition(e,startx[e],starty[e],startz[e])					
					SetRotation(e,startax[e],startay[e],startaz[e])
					movedist[e] = 0
					status[e] = "alert"
				end
			end
		end		
	end
end

function arrowtrap_exit(e)
end