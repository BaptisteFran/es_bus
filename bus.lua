onJob = 0
local player = PlayerId()

-- Configure the coordinates where the bus should be placed.
local bus = {
   { hash=0xD577C962, x=918.592, y=-166.732, z=74.250, a=100.938 }, -- changer coordonnées pour dépot bus
   { hash=0xD577C962, x=917.207, y=-171.100, z=74.489, a=85.422 },  -- changer coordonnées pour dépot bus
  }

	-- Configure the coordinates where the bus drivers (npc) should be placed.
local peds = {
  {type=4, hash=0x7e6a64b7, x=894.422, y=-182.196, z=74.700, a=269.449}, -- changer les coordonnées
  {type=4, hash=0x7e6a64b7, x=895.422, y=-180.234, z=74.700, a=260.402}, -- changer les coordonnées
  {type=4, hash=0x7e6a64b7, x=900.742, y=-174.138, z=73.936, a=265.213}, -- changer les coordonnées
  }

AddEventHandler('onClientMapStart', function()
RequestModel(0xD577C962)
while not HasModelLoaded(0xD577C962) do
	Wait(1)
end

RequestModel(0x7e6a64b7)
while not HasModelLoaded(0x7e6a64b7) do
	Wait(1)
end

-- Set a blip on the map for Bus station -- 
downtownc = AddBlipForCoord(900.461, -181.466, 73.89) -- /////// AJOUTER BLIP BUS STATION COORD //////
SetBlipSprite(Busstation, 66)
SetBlipDisplay(Busstation, 3)
SetBlipNameFromTextFile(Busstation, "BUS_BLIP")

-- Spawn the bus to Bus station
for _, item in pairs(bus) do
	bus =  CreateVehicle(item.hash, item.x, item.y, item.z, item.a, false, false)
	SetVehicleOnGroundProperly(bus)
end

-- Spawn the Bus drivers to the coordinates (testing)
for _, item in pairs(peds) do
	ped = CreatePed(item.type, item.hash, item.x, item.y, item.z, item.a, false, true)
	GiveWeaponToPed(ped, 0x99B507EA, 2800, false, true)
	SetPedCombatAttributes(ped, 46, true)
	SetPedFleeAttributes(ped, 0, 0)
	SetPedArmour(ped, 100)
	SetPedMaxHealth(ped, 100)
	SetPedRelationshipGroupHash(ped, GetHashKey("CIVMALE"))  -- //// LES FAIRE ATTAQUER QUAND ON PREND BUS? ///////
	TaskStartScenarioInPlace(ped, "WORLD_HUMAN_GUARD_STAND_PATROL", 0, true)
	SetPedCanRagdoll(ped, false)
	SetPedDiesWhenInjured(ped, false)
	end

end)

jobs = {peds = {}, flag = {}, blip = {}, cars = {}, coords = {cx={}, cy={}, cz={}}}

function StartJob(jobid)
	if jobid == 1 then -- bus
		showLoadingPromt("Loading bus mission", 2000, 3)
		jobs.coords.cx[1],jobs.coords.cy[1],jobs.coords.cz[1] = 293.476,-590.163,42.7371
		jobs.coords.cx[2],jobs.coords.cy[2],jobs.coords.cz[2] = 253.404,-375.86,44.0819
		jobs.coords.cx[3],jobs.coords.cy[3],jobs.coords.cz[3] = 120.808,-300.416,45.1399
		 -- ///// METTRE LES COORDS DES ARRETS DE BUS //////

		jobs.cars[1] = GetVehiclePedIsUsing(GetPlayerPed(-1))
		jobs.flag[1] = 0
		jobs.flag[2] = 59+GetRandomIntInRange(1, 61)
		Wait(2000)
		DrawMissionText("Drive to a bus stop and wait for ~h~~y~passengers~w~.", 10000)
		onJob = jobid
	end
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function DrawMissionText(m_text, showtime)
    ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

function showLoadingPromt(showText, showTime, showType) -- /////////// ARRET ICI ///////////////
	Citizen.CreateThread(function()
		Citizen.Wait(0)
		N_0xaba17d7ce615adbf("STRING") -- set type
		AddTextComponentString(showText) -- sets the text
		N_0xbd12f8228410d9b4(showType) -- show promt (types = 3)
		Citizen.Wait(showTime) -- show time
		N_0x10d373323e5b9c0d() -- remove promt
	end)
end

function StopJob(jobid)
	if jobid == 1 then
		if DoesEntityExist(jobs.peds[1]) then
			local pedb = GetBlipFromEntity(jobs.peds[1])
			if pedb ~= nil and DoesBlipExist(pedb) then
				SetBlipSprite(pedb, 2)
				SetBlipDisplay(pedb, 3)
			end
			ClearPedTasksImmediately(jobs.peds[1])
			if DoesEntityExist(jobs.cars[1]) and IsVehicleDriveable(jobs.cars[1], 0) then
				if IsPedSittingInVehicle(jobs.peds[1], jobs.cars[1]) then
					TaskLeaveVehicle(jobs.peds[1], jobs.cars[1], 0)
				end
			end
			Citizen.InvokeNative(0xB736A491E64A32CF,Citizen.PointerValueIntInitialized(jobs.peds[1]))
		end
		if jobs.blip[1] ~= nil and DoesBlipExist(jobs.blip[1]) then
			Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(jobs.blip[1]))
			jobs.blip[1] = nil
		end
		onJob = 0
		jobs.cars[1] = nil
		jobs.peds[1] = nil
		jobs.flag[1] = nil
		jobs.flag[2] = nil
	end
end

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if onJob == 0 then
			if IsControlJustPressed(1, 214) or IsDisabledControlJustPressed(1, 214) then -- DEL
				if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
					if IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey("bus", _r)) then
						StartJob(1)
					end
				end
			end
		elseif onJob == 1 then
			if DoesEntityExist(jobs.cars[1]) and IsVehicleDriveable(jobs.cars[1], 0) then
				if IsPedSittingInVehicle(GetPlayerPed(-1), jobs.cars[1]) then
					if DoesEntityExist(jobs.peds[1]) then
						if IsPedFatallyInjured(jobs.peds[1]) then
							Citizen.InvokeNative(0xB736A491E64A32CF,Citizen.PointerValueIntInitialized(jobs.peds[1]))
							local pedb = GetBlipFromEntity(jobs.peds[1])
							if pedb ~= nil and DoesBlipExist(pedb) then
								SetBlipSprite(pedb, 2)
								SetBlipDisplay(pedb, 3)
							end
							jobs.peds[1] = nil
							jobs.flag[1] = 0
							jobs.flag[2] = 59+GetRandomIntInRange(1, 90)
							if jobs.blip[1] ~= nil and DoesBlipExist(jobs.blip[1]) then
								Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(jobs.blip[1]))
								jobs.blip[1] = nil
							end
							DrawMissionText("The client is ~r~dead~w~. Find another one.", 5000)
						else
							if jobs.flag[1] == 1 and jobs.flag[2] > 0 then
								Wait(1000)
								jobs.flag[2] = jobs.flag[2]-1
								if jobs.flag[2] == 0 then
									local pedb = GetBlipFromEntity(jobs.peds[1])
									if pedb ~= nil and DoesBlipExist(pedb) then
										SetBlipSprite(pedb, 2)
										SetBlipDisplay(pedb, 3)
									end
									ClearPedTasksImmediately(jobs.peds[1])
									Citizen.InvokeNative(0xB736A491E64A32CF,Citizen.PointerValueIntInitialized(jobs.peds[1]))
									jobs.peds[1] = nil
									DrawMissionText("The client got ~r~tired of waiting~w~. Find another one.", 5000)
									jobs.flag[1] = 0
									jobs.flag[2] = 59+GetRandomIntInRange(1, 61)
								else
									if IsPedSittingInVehicle(GetPlayerPed(-1), jobs.cars[1]) then
										if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(jobs.peds[1]), true) < 8.0001 then
											local offs = GetOffsetFromEntityInWorldCoords(GetVehiclePedIsUsing(GetPlayerPed(-1)), 1.5, 0.0, 0.0)
											local offs2 = GetOffsetFromEntityInWorldCoords(GetVehiclePedIsUsing(GetPlayerPed(-1)), -1.5, 0.0, 0.0)
											if GetDistanceBetweenCoords(offs['x'], offs['y'], offs['z'], GetEntityCoords(jobs.peds[1]), true) < GetDistanceBetweenCoords(offs2['x'], offs2['y'], offs2['z'], GetEntityCoords(jobs.peds[1]), true) then
												TaskEnterVehicle(jobs.peds[1], jobs.cars[1], -1, 2, 2.0001, 1)
											else
												TaskEnterVehicle(jobs.peds[1], jobs.cars[1], -1, 1, 2.0001, 1)
											end
											jobs.flag[1] = 2
											jobs.flag[2] = 30
										end
									end
								end
							end
							if jobs.flag[1] == 2 and jobs.flag[2] > 0 then
								Wait(1000)
								jobs.flag[2] = jobs.flag[2]-1
								if jobs.flag[2] == 0 then
									local pedb = GetBlipFromEntity(jobs.peds[1])
									if pedb ~= nil and DoesBlipExist(pedb) then
										SetBlipSprite(pedb, 2)
										SetBlipDisplay(pedb, 3)
									end
									ClearPedTasksImmediately(jobs.peds[1])
									Citizen.InvokeNative(0xB736A491E64A32CF,Citizen.PointerValueIntInitialized(jobs.peds[1]))
									jobs.peds[1] = nil
									DrawMissionText("~r~The client is not going with you~w~. Find another one.", 5000)
									jobs.flag[1] = 0
									jobs.flag[2] = 59+GetRandomIntInRange(1, 61)
								else
									if IsPedSittingInVehicle(jobs.peds[1], jobs.cars[1]) then
										local pedb = GetBlipFromEntity(jobs.peds[1])
										if pedb ~= nil and DoesBlipExist(pedb) then
											SetBlipSprite(pedb, 2)
											SetBlipDisplay(pedb, 3)
										end
										jobs.flag[1] = 3
										jobs.flag[2] = GetRandomIntInRange(1, 62)
										local street = table.pack(GetStreetNameAtCoord(jobs.coords.cx[jobs.flag[2]],jobs.coords.cy[jobs.flag[2]],jobs.coords.cz[jobs.flag[2]]))
										if street[2] ~= 0 and street[2] ~= nil then
											local streetname = string.format("~w~Take me to~y~ %s~w~, nearby~y~ %s", GetStreetNameFromHashKey(street[1]),GetStreetNameFromHashKey(street[2]))
											DrawMissionText(streetname, 5000)
										else
											local streetname = string.format("~w~Take me to the~y~ %s", GetStreetNameFromHashKey(street[1]))
											DrawMissionText(streetname, 5000)
										end
										jobs.blip[1] = AddBlipForCoord(jobs.coords.cx[jobs.flag[2]],jobs.coords.cy[jobs.flag[2]],jobs.coords.cz[jobs.flag[2]])
										AddTextComponentString(GetStreetNameFromHashKey(street[1]))
										N_0x80ead8e2e1d5d52e(jobs.blip[1])
										SetBlipRoute(jobs.blip[1], 1)
									end
								end
							end
							if jobs.flag[1] == 3 then
								if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), jobs.coords.cx[jobs.flag[2]],jobs.coords.cy[jobs.flag[2]],jobs.coords.cz[jobs.flag[2]], true) > 4.0001 then
									DrawMarker(1, jobs.coords.cx[jobs.flag[2]],jobs.coords.cy[jobs.flag[2]],jobs.coords.cz[jobs.flag[2]]-1.0001, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
								else
									if jobs.blip[1] ~= nil and DoesBlipExist(jobs.blip[1]) then
										Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(jobs.blip[1]))
										jobs.blip[1] = nil
									end
									ClearPedTasksImmediately(jobs.peds[1])
									TaskLeaveVehicle(jobs.peds[1], jobs.cars[1], 0)
									Citizen.InvokeNative(0xB736A491E64A32CF,Citizen.PointerValueIntInitialized(jobs.peds[1]))
									jobs.peds[1] = nil
									Wait(6000)

                  TriggerServerEvent('taxi:success')
                  DrawMissionText("~g~You have delivered the client!", 5000)
									-- pay money on something
									Wait(8000)
									DrawMissionText("Drive around and look for new ~h~~y~customers~w~.", 10000)
									jobs.flag[1] = 0
									jobs.flag[2] = 59+GetRandomIntInRange(1, 90)
								end
							end
						end
					else

						if jobs.flag[1] > 0 then
							jobs.flag[1] = 0
							jobs.flag[2] = 59+GetRandomIntInRange(1, 61)
							DrawMissionText("Drive around and look for ~h~~y~customers~w~.", 10000)
							if jobs.blip[1] ~= nil and DoesBlipExist(jobs.blip[1]) then
								Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(jobs.blip[1]))
								jobs.blip[1] = nil
							end
						end
						if jobs.flag[1] == 0 and jobs.flag[2] > 0 then
							Wait(1000)
							jobs.flag[2] = jobs.flag[2]-1
							if jobs.flag[2] == 0 then
								local pos = GetEntityCoords(GetPlayerPed(-1))
								local rped = GetRandomPedAtCoord(pos['x'], pos['y'], pos['z'], 35.001, 35.001, 35.001, 6, _r)
								if DoesEntityExist(rped) then
									jobs.peds[1] = rped
									jobs.flag[1] = 1
									jobs.flag[2] = 19+GetRandomIntInRange(1, 21)
									ClearPedTasksImmediately(jobs.peds[1])
									SetBlockingOfNonTemporaryEvents(jobs.peds[1], 1)
									TaskStandStill(jobs.peds[1], 1000*jobs.flag[2])
									DrawMissionText("The ~g~customer~w~ is waiting for you. Drive nearby", 5000)
									local lblip = AddBlipForEntity(jobs.peds[1])
									SetBlipAsFriendly(lblip, 1)
									SetBlipColour(lblip, 2)
									SetBlipCategory(lblip, 3)
								else
									jobs.flag[1] = 0
									jobs.flag[2] = 59+GetRandomIntInRange(1, 90)
									DrawMissionText("Drive around and look for ~h~~y~customers~w~.", 10000)
								end
							end
						end
					end
				else
					if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(jobs.cars[1]), true) > 30.0001 then
						StopJob(1)
					else
						DrawMissionText("Get back in your bus to ~y~continue~w~. Or go away from the bus to ~r~stop~ the mission.", 1)
					end
				end
			else
				StopJob(1)
				DrawMissionText("The bus is ~h~~r~destroyed~w~.", 5000)
			end
		end
	
