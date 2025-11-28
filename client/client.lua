local Interface = {}

Interface.distance = 1.10
Interface.scalePed = 0.30

Interface.offset = vector3( 0.0, 0.0, 0.0 )

Interface.animation = { dict = "anim@amb@nightclub@peds@", name = "rcmme_amanda1_stand_loop_cop" }
Interface.scenario = nil

Interface.positions = {
	LEFT = vector3( -0.5, 0.0, 0.0 ),
	RIGHT = vector3( 0.5, 0.0, 0.0 )
}

-- Thanks <3 : https://github.com/alberttheprince/rpemotes-reborn/blob/b6c9d41653a24589b1379ed2c5f853c3978615f7/client/Emote.lua#L28
Interface.scenarioObjects = {
	`p_amb_coffeecup_01`,
	`p_amb_joint_01`,
	`p_cs_ciggy_01`,
	`p_cs_ciggy_01b_s`,
	`p_cs_clipboard`,
	`prop_curl_bar_01`,
	`p_cs_joint_01`,
	`p_cs_joint_02`,
	`prop_acc_guitar_01`,
	`prop_amb_ciggy_01`,
	`prop_amb_phone`,
	`prop_beggers_sign_01`,
	`prop_beggers_sign_02`,
	`prop_beggers_sign_03`,
	`prop_beggers_sign_04`,
	`prop_bongos_01`,
	`prop_cigar_01`,
	`prop_cigar_02`,
	`prop_cigar_03`,
	`prop_cs_beer_bot_40oz_02`,
	`prop_cs_paper_cup`,
	`prop_cs_trowel`,
	`prop_fib_clipboard`,
	`prop_fish_slice_01`,
	`prop_fishing_rod_01`,
	`prop_fishing_rod_02`,
	`prop_notepad_02`,
	`prop_parking_wand_01`,
	`prop_rag_01`,
	`prop_scn_police_torch`,
	`prop_sh_cigar_01`,
	`prop_sh_joint_01`,
	`prop_tool_broom`,
	`prop_tool_hammer`,
	`prop_tool_jackham`,
	`prop_tennis_rack_01`,
	`prop_weld_torch`,
	`w_me_gclub`,
	`p_amb_clipboard_01`
}

local pedPreview = nil
local updateThread = nil
local focusCamera = nil

local mathRad = math.rad
local mathSin = math.sin
local mathCos = math.cos
local mathAbs = math.abs

--- @param entity number
--- @param scale number
function Interface.applyEntityScale( entity, scale )
	if not DoesEntityExist( entity ) then return end

	local pos = GetEntityCoords( entity )
	local f, r, u, a = GetEntityMatrix( entity )

	f = vector3( f.x * scale, f.y * scale, f.z * scale )
	r = vector3( r.x * scale, r.y * scale, r.z * scale )
	u = vector3( u.x * scale, u.y * scale, u.z * scale )

	SetEntityMatrix( entity,
		f.x, f.y, f.z,
		r.x, r.y, r.z,
		u.x, u.y, u.z,
		pos.x, pos.y, pos.z
	)
end

--- @param playerPed number
--- @param options Options
function Interface.createPed( playerPed, options )
	if DoesEntityExist( pedPreview ) then
		Interface.deletePed()
	end

	options = options or {}

	if options.offset then
		Interface.offset = vector3( options.offset.x or 0.0, options.offset.y or 0.0, options.offset.z or 0.0 )
	end

	if options.animation then
		Interface.animation.dict = options.animation.dict or Interface.animation.dict
		Interface.animation.name = options.animation.name or Interface.animation.name
	end

	playerPed = playerPed or PlayerPedId()

	local playerModel = GetEntityModel( playerPed )
	local playerCoords = GetEntityCoords( playerPed )

	pedPreview = CreatePed( 4, playerModel, playerCoords.x, playerCoords.y, playerCoords.z, 0.0, false, false )

	if not DoesEntityExist( pedPreview ) then
		print( "^1[ERROR] Échec de la création du ped preview^0" )
		return
	end

	ClonePedToTarget( playerPed, pedPreview )

	SetEntityInvincible( pedPreview, true )
	FreezeEntityPosition( pedPreview, true )
	SetEntityCollision( pedPreview, false, false )
	SetEntityCanBeDamaged( pedPreview, false )
	SetBlockingOfNonTemporaryEvents( pedPreview, true )
	TaskSetBlockingOfNonTemporaryEvents( pedPreview, true )
	SetEntityVisible( pedPreview, true, false )
	NetworkSetEntityInvisibleToNetwork( pedPreview, true )
	SetEntityAlpha( pedPreview, 255, false )

	DisablePedPainAudio( pedPreview, true )
	DisableIdleCamera( true )

	if options.scenario then
		Interface.setPedScenario( options.scenario )
	elseif options.animation then
		Interface.setPedAnimation( options.animation )
	else
		Interface.setPedAnimation( Interface.animation )
	end

	CreateThread( function ()
		while DoesEntityExist( pedPreview ) do
			local camCoords = GetGameplayCamCoord()
			local camRot = GetGameplayCamRot( 2 )

			local heading = mathRad( camRot.z )
			local pitch = mathRad( camRot.x )
			local cosPitch = mathAbs( mathCos( pitch ) )

			local forwardX = -mathSin( heading ) * cosPitch
			local forwardY = mathCos( heading ) * cosPitch
			local forwardZ = mathSin( pitch )

			local rightX = mathCos( heading )
			local rightY = mathSin( heading )

			local upZ = 1.0

			local distance = Interface.distance
			local camDistance = #(GetEntityCoords( playerPed ) - camCoords)

			if IsPedInAnyVehicle( playerPed, false ) then
				local vehicle = GetVehiclePedIsIn( playerPed, false )
				local speed = GetEntitySpeed( vehicle )

				distance = distance + (speed * 0.012) + (camDistance * 0.005)
			end

			local baseX = camCoords.x + forwardX * distance
			local baseY = camCoords.y + forwardY * distance
			local baseZ = camCoords.z + forwardZ * distance - 1.01

			local finalX = baseX + (rightX * Interface.offset.x) + (forwardX * Interface.offset.y)
			local finalY = baseY + (rightY * Interface.offset.x) + (forwardY * Interface.offset.y)
			local finalZ = baseZ + (upZ * Interface.offset.z)

			local position = vector3( finalX, finalY, finalZ )
			local rotationAdjustment = -Interface.offset.x * 50.0

			SetEntityCoords( pedPreview, position.x, position.y, position.z, false, false, false, true )
			SetEntityRotation( pedPreview, -camRot.x, camRot.y, camRot.z + 180.0 + rotationAdjustment, 2, true )

			Interface.applyEntityScale( pedPreview, Interface.scalePed )

			Wait( 0 )
		end
	end )
end

function Interface.deletePed()
	if not DoesEntityExist( pedPreview ) then
		return
	end

	DeleteEntity( pedPreview )
	pedPreview = nil

	Interface.offset = vector3( 0.0, 0.0, 0.0 )

	Interface.animation = { dict = "anim@amb@nightclub@peds@", name = "rcmme_amanda1_stand_loop_cop" }
	Interface.scenario = nil

	DisableIdleCamera( false )
end

--- @param animation table
function Interface.setPedAnimation( animation )
	if not DoesEntityExist( pedPreview ) then
		return
	end

	if Interface.scenario then
		Interface.CleanScenarioObjects()
		ClearPedTasks( pedPreview )

		Interface.scenario = nil
	end

	Interface.animation.dict = animation.dict or Interface.animation.dict
	Interface.animation.name = animation.name or Interface.animation.name

	RequestAnimDict( Interface.animation.dict )
	while not HasAnimDictLoaded( Interface.animation.dict ) do
		Wait( 0 )
	end

	TaskPlayAnim( pedPreview, Interface.animation.dict, Interface.animation.name, 8.0, -8.0, -1, 1, 0, false, false, false )
end

-- Thanks <3 : https://github.com/alberttheprince/rpemotes-reborn/blob/b6c9d41653a24589b1379ed2c5f853c3978615f7/client/Emote.lua#L179C16-L179C36
function Interface.CleanScenarioObjects()
	if not DoesEntityExist( pedPreview ) then
		return
	end

	local pedPreviewCoords = GetEntityCoords( pedPreview )

	for _, itemHash in pairs( Interface.scenarioObjects ) do
		local deleteScenarioObject = GetClosestObjectOfType( pedPreviewCoords.x, pedPreviewCoords.y, pedPreviewCoords.z, 1.0, itemHash, false, true, true )
		if DoesEntityExist( deleteScenarioObject ) then
			SetEntityAsMissionEntity( deleteScenarioObject, false, false )
			DeleteObject( deleteScenarioObject )
		end
	end
end

--- @param scenarioName string
function Interface.setPedScenario( scenarioName )
	if not DoesEntityExist( pedPreview ) then
		return
	end

	Interface.CleanScenarioObjects()
	ClearPedTasks( pedPreview )

	Interface.scenario = scenarioName
	TaskStartScenarioInPlace( pedPreview, scenarioName, 0, false )
end

--- @param offset vector3
function Interface.setPedOffset( offset )
	if not offset then
		Interface.offset = vector3( 0.0, 0.0, 0.0 )
		return
	end

	Interface.offset = vector3(
		offset.x or Interface.offset.x,
		offset.y or Interface.offset.y,
		offset.z or Interface.offset.z
	)
end

--- @param playerPed number
--- @param options Options
exports( "createPed", function ( playerPed, options )
	Interface.createPed( playerPed, options )
end )

exports( "deletePed", function ()
	Interface.deletePed()
end )

--- @param animation Animation
exports( "setPedAnimation", function ( animation )
	Interface.setPedAnimation( animation )
end )

--- @param scenarioName string
exports( "setPedScenario", function ( scenarioName )
	Interface.setPedScenario( scenarioName )
end )

--- @param offset vector3
exports( "setPedOffset", function ( offset )
	Interface.setPedOffset( offset )
end )