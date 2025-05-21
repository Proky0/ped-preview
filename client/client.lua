local Interface = {}

Interface.distance = 1.10
Interface.scalePed = 0.30

local pedPreview = nil

function Interface.applyEntityScale( entity, scale )
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

function Interface.createPed( playerPed )
	if DoesEntityExist( pedPreview ) then
		DeleteEntity( pedPreview )
		pedPreview = nil
	end

	playerPed = playerPed or PlayerPedId()
	local playerModel = GetEntityModel( playerPed )

	pedPreview = CreatePed( 4, playerModel, 0.0, 0.0, 0.0, 0.0, false, false )
	ClonePedToTarget( playerPed, pedPreview )

	SetEntityInvincible( pedPreview, true )
	FreezeEntityPosition( pedPreview, false )
	SetEntityCollision( pedPreview, false, true )

	SetEntityCanBeDamaged( pedPreview, false )
	SetBlockingOfNonTemporaryEvents( pedPreview, true )
	TaskSetBlockingOfNonTemporaryEvents( pedPreview, true )

	SetEntityVisible( pedPreview, true )
	NetworkSetEntityInvisibleToNetwork( pedPreview, true )

	DisableIdleCamera( true )

	RequestAnimDict( "anim@amb@nightclub@peds@" )
	while not HasAnimDictLoaded( "anim@amb@nightclub@peds@" ) do
		Wait( 100 )
	end

	TaskPlayAnim( pedPreview, "anim@amb@nightclub@peds@", "rcmme_amanda1_stand_loop_cop", 8.0, -8.0, -1, 1, 0, false, false, false )

	CreateThread( function ()
		while DoesEntityExist( pedPreview ) do
			local camCoords = GetGameplayCamCoord()
			local camRot = GetGameplayCamRot( 2 )

			local heading = math.rad( camRot.z )
			local pitch = math.rad( camRot.x )

			local forwardX = -math.sin( heading ) * math.abs( math.cos( pitch ) )
			local forwardY = math.cos( heading ) * math.abs( math.cos( pitch ) )
			local forwardZ = math.sin( pitch )

			local distance = Interface.distance
			local camDistance = #(GetEntityCoords( playerPed ) - camCoords)

			if IsPedInAnyVehicle( playerPed, false ) then
				local vehicle = GetVehiclePedIsIn( playerPed, false )
				local speed = GetEntitySpeed( vehicle )

				distance = Interface.distance + (speed * 0.012) + (camDistance * 0.005)
			end

			local position = vector3(
				camCoords.x + forwardX * distance,
				camCoords.y + forwardY * distance,
				camCoords.z + forwardZ * distance - 1.01
			)

			SetEntityCoords( pedPreview, position.x, position.y, position.z )
			SetEntityRotation( pedPreview, -camRot.x, camRot.y, camRot.z + 180.0, 2, true )

			Interface.applyEntityScale( pedPreview, Interface.scalePed )

			Wait( 0 )
		end
	end )
end

function Interface.deletePed()
	if DoesEntityExist( pedPreview ) then
		DeleteEntity( pedPreview )
	end

	pedPreview = nil
end

function Interface.refreshPed()
	if not DoesEntityExist( pedPreview ) then
		return
	end

	local playerPed = PlayerPedId() or cache.ped
	ClonePedToTarget( playerPed, pedPreview )
end

exports( "createPed", function () Interface.createPed() end )
exports( "deletePed", function () Interface.deletePed() end )
exports( "refreshPed", function () Interface.refreshPed() end )