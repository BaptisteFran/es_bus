-- ped = ig_trafficwarden, 0x5719786d, GetHashkey("ig_trafficwarden")
-- bus = bus, -713569950, 0xD577C962, GetHashkey("bus")

local player = GetPlayerPed(-1)


-- Creating bus and peds spawn
local bus = {
    {hash= 0xD577C962, x= 463.358, y= -641.627, z= 27.958, a=28.954}
    
    }

local ped = {
   {type=4, hash= 0x5719786d, x= 458.246, y= -637.092, z= 27.958, a= 46.395}
    }


-- Loading at map start
AddEventHandler('onClientMapStart', function()


-- Making Bus & peds spawn
RequestModel(0xD577C962) -- Bus
while not HadModelLoaded(0xD577C962) do
   Wait(1)
end
    
RequestModel(0x5719786d) -- Ped
while not HadModelLoaded(0x5719786d) do
   Wait(1)
end
         
-- Spawning the BUS     
         
for _, item in pairs(bus) do
	buses =  CreateVehicle(item.hash, item.x, item.y, item.z, item.a, false, false)
	SetVehicleOnGroundProperly(buses)
end
         
         

-- Spawning the PEDS and giving them weapons and 'relationship'
         
for _, item in pairs(ped) do
	peds = CreatePed(item.type, item.hash, item.x, item.y, item.z, item.a, false, true)
	GiveWeaponToPed(peds, 0x99B507EA, 2800, false, true) -- knives
	SetPedCombatAttributes(peds, 46, true)
	SetPedFleeAttributes(peds, 0, 0)
	SetPedArmour(peds, 100)
	SetPedMaxHealth(peds, 100)
	SetPedRelationshipGroupHash(peds, GetHashKey("CIVMALE"))
	TaskStartScenarioInPlace(peds, "WORLD_HUMAN_GUARD_STAND_PATROL", 0, true)
	SetPedCanRagdoll(peds, false)
	SetPedDiesWhenInjured(peds, false)
	end     
         

-- vehicle_generator bus { -405.24, -650.09, 28.18, heading = 28.53 } // Is it better?

			
-- Bus station blip
busstation = AddBlipForCoord(-463.358, -641.092, 27.958)
SetBlipSprite(busstation, 66)
SetBlipDisplay(busstation, 4)
SetBlipColor(busstation, 2)

      
end)
	


