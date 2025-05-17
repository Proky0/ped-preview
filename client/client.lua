local Interface = {}

Interface.distance = 0.38
Interface.scalePed = 0.10

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

function Interface.createPed()
	if DoesEntityExist( pedPreview ) then
		DeleteEntity( pedPreview )
		pedPreview = nil
	end

	local playerPed   = cache.ped
	local playerModel = GetEntityModel( playerPed )

	local camCoords   = GetGameplayCamCoord()
	local camRot      = GetGameplayCamRot( 2 )
	local camHeading  = GetGameplayCamRelativeHeading()

	local forward = vector3(
		-math.sin( math.rad( camRot.z ) ) * math.abs( math.cos( math.rad( camRot.x ) ) ),
		math.cos( math.rad( camRot.z ) ) * math.abs( math.cos( math.rad( camRot.x ) ) ),
		math.sin( math.rad( camRot.x ) )
	)

	local posX = camCoords.x + forward.x * Interface.distance
	local posY = camCoords.y + forward.y * Interface.distance
	local posZ = camCoords.z + forward.z * Interface.distance

	pedPreview = CreatePed( 4, playerModel, posX, posY, posZ - 1.0, 0.0, false, true )

	ClonePedToTarget( playerPed, pedPreview )

	SetEntityInvincible( pedPreview, true )
	FreezeEntityPosition( pedPreview, false ) -- Changed to false to allow movement
	SetEntityCollision( pedPreview, false, true )

	SetBlockingOfNonTemporaryEvents( pedPreview, true )
	TaskSetBlockingOfNonTemporaryEvents( pedPreview, true )

	-- Make the ped cross arms
	RequestAnimDict( "anim@amb@nightclub@peds@" )
	while not HasAnimDictLoaded( "anim@amb@nightclub@peds@" ) do
		Wait( 100 )
	end

	TaskPlayAnim( pedPreview, "anim@amb@nightclub@peds@", "rcmme_amanda1_stand_loop_cop", 8.0, -8.0, -1, 1, 0, false, false, false )

	-- Set network properties
	NetworkSetEntityInvisibleToNetwork( pedPreview, true )
	SetEntityVisible( pedPreview, true )

	-- Create a thread to constantly update ped position and rotation
	CreateThread( function ()
		while DoesEntityExist( pedPreview ) do
			local camCoords = GetGameplayCamCoord()
			local camRot = GetGameplayCamRot( 2 )

			local heading = math.rad( camRot.z )
			local pitch = math.rad( camRot.x )

			local forwardX = -math.sin( heading ) * math.abs( math.cos( pitch ) )
			local forwardY = math.cos( heading ) * math.abs( math.cos( pitch ) )
			local forwardZ = math.sin( pitch )

			local pos = vector3(
				camCoords.x + forwardX * Interface.distance,
				camCoords.y + forwardY * Interface.distance,
				camCoords.z + forwardZ * Interface.distance - 1.0 -- Ajustement hauteur
			)

			SetEntityCoords( pedPreview, pos.x, pos.y, pos.z )
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
	if DoesEntityExist( pedPreview ) then
		local playerPed = cache.ped or PlayerPedId()
		ClonePedToTarget( playerPed, pedPreview )
	end
end

exports( "createPed", function () Interface.createPed() end )
exports( "deletePed", function () Interface.deletePed() end )
exports( "refreshPed", function () Interface.refreshPed() end )