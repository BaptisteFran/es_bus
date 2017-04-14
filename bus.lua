-- ped = ig_trafficwarden, 0x5719786d
-- bus = bus, -713569950, 0xD577C962


-- Creating bus and peds spawn
local bus = GetHashkey("bus")
local peds = GetHashkey("ig_trafficwarden")


-- Loading at map start
AddEventHandler('onClientMapStart', function()


-- Making Bus & peds spawn
RequestModel(0xD577C962)
while not HadModelLoaded(0xD577C962) do
   Wait(1)
end
    
RequestModel(0x5719786d)
while not HadModelLoaded(0x5719786d) do
   Wait(1)
end    

vehicle_generator bus { -405.24, -650.09, 28.18, heading = 28.53 }
spawnpoint peds { x = -402.24, y = -650.12, z = 28.18 }
-- create peds with weapons and 'relationship' 
    


    
end)
