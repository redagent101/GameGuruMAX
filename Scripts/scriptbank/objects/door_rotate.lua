-- Door Rotate v22 - Necrym59 and AmenMoses and Lee
-- DESCRIPTION: Rotates a non-animating door when player interacts with it. When door is initially opened, play <Sound0>. When the door is closing, play <Sound1>.
-- DESCRIPTION: Customize the [LockedText$="Door is locked. Find a way to unlock it"] 
-- DESCRIPTION: and optionally [!IsUnlocked=1]
-- DESCRIPTION: [UnLockedText$="Press E to open door"] 
-- DESCRIPTION: [CloseText$="Press E to close door"] 
-- DESCRIPTION: [@DOOR_TYPE=2(1=Auto, 2=Manual)]
-- DESCRIPTION: [DOOR_RANGE=100(0,500)]

local Q = require "scriptbank\\quatlib"
local U = require "scriptbank\\utillib"
local NAVMESH = require "scriptbank\\navmeshlib"

local deg = math.deg
local rad = math.rad

local names = {}
local keyPressed = false

local timeLastFrame = nil
local timeDiff      = 1
local controlEnt    = nil
local tEnt = {}
local selectobj = {}

local defaultLockedText   = "Door is locked. Find a way to open it"
local defaultIsUnlocked = true
local defaultUnLockedText = "Press E to open door"
local defaultCloseText = "Press E to close door"
local defaultDoorType     = 'Manual'
local defaultDoorRange    = 100

g_door_rotate = {}

local doorTypesRotation = { 'Auto', 'Manual' }

function door_rotate_properties( e, lockedtext, isunlocked, unlockedtext, closetext, door_type, door_range )
	local door = g_door_rotate[ e ]
	if door == nil then return end
	if lockedtext ~= nil then
		door.lockedtext = lockedtext
	end
	if isunlocked ~= nil then
		door.isunlocked = isunlocked == 1
	end
	if unlockedtext ~= nil then
		door.unlockedtext = unlockedtext
	end
	if closetext ~= nil then
		door.closetext = closetext
	end
	if door_type ~= nil then
		door.door_type = doorTypesRotation[ door_type ]    
	end
	door.door_range = door_range or defaultDoorRange
end 

function door_rotate_init_name( e, name )
	Include( "quatlib.lua" )
	Include( "utillib.lua" )
	names[ e ] = name
	g_door_rotate[ e ] =  { obj = nil,
							timer = math.huge,
							state = 'Closed',
							angle = 0,
							quat = Q.FromEuler( 0, 0, 0 ),
							blocking = 1,
							originalx = -1,
							originaly = -1,
							originalz = -1,
							lockedtext = defaultLockedText,
							IsUnlocked = defaultIsUnlocked,
							unlockedtext = defaultUnLockedText,
							closetext = defaultCloseText,		
							door_type = defaultDoorType,
							door_range = defaultDoorRange,
					      }
	tEnt[e] = 0
	selectobj[e] = 0						  
end

function door_rotate_main(e)

	local PlayerDist = GetPlayerDistance(e)	
	
	local door = g_door_rotate[ e ]
	if door == nil then return end
	if door.obj == nil then
		-- initialise
		local Ent = g_Entity[ e ]
		local _, _, _, ax, ay, az = GetObjectPosAng( Ent.obj )
		g_door_rotate[ e ].obj = Ent.obj
		g_door_rotate[ e ].timer = math.huge
		g_door_rotate[ e ].state = 'Closed'
		g_door_rotate[ e ].angle = 0
		g_door_rotate[ e ].quat = Q.FromEuler( rad( ax ), rad( ay ), rad( az ) )
		g_door_rotate[ e ].blocking = 1
		g_door_rotate[ e ].originalx = -1
		g_door_rotate[ e ].originaly = -1
		g_door_rotate[ e ].originalz = -1
		return
	end
	
	if g_door_rotate[ e ].originalx == -1 then
		g_door_rotate[ e ].originalx = g_Entity[e]['x']
		g_door_rotate[ e ].originaly = g_Entity[e]['y']
		g_door_rotate[ e ].originalz = g_Entity[e]['z']
		return
	end

	if controlEnt == nil then controlEnt = e end
	
	local timeThisFrame = g_Time
	
	if controlEnt == e then
		if timeLastFrame == nil then 
			timeLastFrame = timeThisFrame
			timeDiff = 1
		else
			timeDiff = ( timeThisFrame - timeLastFrame ) / 20
			timeLastFrame = timeThisFrame
		end
	end

	local allowautoopenremotely = 0
	if door.isunlocked == false then 	
		if g_Entity[e]['haskey'] == 1 then 	
			door.isunlocked = true
		end
		-- if was spawned at start, and it was locked, and then activated, this means we want to unlock the door
		if GetEntitySpawnAtStart(e) == 1 and g_Entity[e]['activated'] == 1 then
			door.isunlocked = true
		end
	else
		-- if spawned, unlocked, then activated, and AUTO, can trigger an auto open!
		if GetEntitySpawnAtStart(e) == 1 and g_Entity[e]['activated'] == 1 then
			g_Entity[e]['activated'] = 0
			allowautoopenremotely = 1
			SetActivated(e,0)
		end
	end

	-- determine if local to door
	local tareweclose = 0
	local LookingAt = GetPlrLookingAtEx(e,1)
	if PlayerDist < door.door_range and GetEntityVisibility(e) == 1 and LookingAt == 1 then	
		--pinpoint select object--		
		local px, py, pz = GetCameraPositionX(0), GetCameraPositionY(0), GetCameraPositionZ(0)
		local rayX, rayY, rayZ = 0,0,door.door_range
		local paX, paY, paZ = math.rad(GetCameraAngleX(0)), math.rad(GetCameraAngleY(0)), math.rad(GetCameraAngleZ(0))
		rayX, rayY, rayZ = U.Rotate3D(rayX, rayY, rayZ, paX, paY, paZ)
		selectobj[e]=IntersectAll(px,py,pz, px+rayX, py+rayY, pz+rayZ,e)
		if selectobj[e] ~= 0 or selectobj[e] ~= nil then
			if g_Entity[e]['obj'] == selectobj[e] then
				TextCenterOnXColor(50-0.01,50,3,"+",255,255,255)--highliting (with crosshair at present)
				tEnt[e] = e
			end
			if g_Entity[e]['obj'] ~= selectobj[e] then selectobj[e] = 0 end
		end
		if selectobj[e] == 0 or selectobj[e] == nil then tEnt[e] = 0 end
		--end pinpoint select object--
	end
	
	if (PlayerDist < door.door_range and tEnt[e] ~= 0 and GetEntityVisibility(e) == 1) or allowautoopenremotely == 1 then	
		tareweclose = 1	
		-- handle door when closed
		if door.state == 'Closed' then
			local tcanopennow = 0
			if door.isunlocked == true then
				tcanopennow = 1
			else
				local Ent = g_Entity[ e ]
				if tareweclose == 1 then Prompt( door.lockedtext ) end
			end
			local tdotheopennow = 0
			if tcanopennow == 1 then
				if door.door_type == 'Auto' then
					tdotheopennow = 1
				elseif door.door_type == 'Manual' and tareweclose == 1 then
					Prompt( door.unlockedtext )
					if g_KeyPressE == 1 then
						if not keyPressed then
							tdotheopennow = 1
							keyPressed = true
						end
					else
						keyPressed = false
					end
				end
				if tdotheopennow == 1 then
					PlaySound( e, 0 )
					PerformLogicConnections(e)
					door.state = 'Knob'
					door.timer = timeThisFrame + 500
				end
			end
		elseif door.state == 'Open' then
			if door.door_type == 'Manual' and tareweclose == 1 then
				Prompt( door.closetext )
				if g_KeyPressE == 1 then
					if not keyPressed then
						door.state = 'Closing' 
						keyPressed = true
						PlaySound( e, 1 )
					end
				else
					keyPressed = false
				end
			end
		end
	end
	
	if door.state == 'Knob' and timeThisFrame > door.timer then
		door.state = 'Opening'
		door.timer = math.huge
	end
	
	if door.state == 'Opening' then
		if door.angle < 90 then
			door.angle = door.angle + timeDiff
			if door.angle > 90 then door.angle = 90 end
			local rotAng = door.angle
			if names[ e ] == 'Right' then rotAng = -rotAng end
			local rotq = Q.FromEuler( 0, rad( rotAng ), 0 )
			local ax, ay, az = Q.ToEuler( Q.Mul( door.quat, rotq ) )
			CollisionOff( e )
			ResetRotation( e, deg( ax ), deg( ay ), deg( az ) )
			CollisionOn( e )
		else
			door.state = 'Open' 
			door.blocking = 2
		end
		
	elseif door.state == 'Closing' then
		if door.angle > 0 then
			door.angle = door.angle - timeDiff
			if door.angle < 0 then door.angle = 0 end
			local rotAng = door.angle
			if names[ e ] == 'Right' then rotAng = -rotAng end
			local rotq = Q.FromEuler( 0, rad( rotAng ), 0 )
			local ax, ay, az = Q.ToEuler( Q.Mul( door.quat, rotq ) )
			CollisionOff( e )
			ResetRotation( e, deg( ax ), deg( ay ), deg( az ) )
			CollisionOn( e )
		else
			door.state = 'Closed' 
			door.blocking = 1
		end
	end
	
	-- navmesh blocker system
	door.blocking = NAVMESH.HandleBlocker(e,door.blocking,g_door_rotate[e].originalx,g_door_rotate[e].originaly,g_door_rotate[e].originalz)
	
end
