QBCore = exports['qb-core']:GetCoreObject()
WeedPlant = nil
WeedCoords = nil
NearbyPlant = false
DoingSomething = false
DryingWeed = false
WeedCollected = false
DriedLeaves = nil
LoopParticle = false

--- Distance Check On Weed Prop
CreateThread(function()
	while true do
        local WaitTime = 300
		local PlayerCoords = GetEntityCoords(PlayerPedId())
        WeedPlant = GetClosestObjectOfType(PlayerCoords, 1.6, 452618762, false, false, false)
        if WeedPlant ~= 0 then
            WeedCoords = GetEntityCoords(WeedPlant)
            if not DoingSomething then 
                if #(PlayerCoords - WeedCoords) < 1.4 then
                    NearbyPlant = true
                else 
                    NearbyPlant = false
                end 
            else
                NearbyPlant = false
            end
        end
        Wait(WaitTime)
	end
end)

--- Weed Prop Interaction check
CreateThread(function()
	while true do
        local WaitTime = 300
        if NearbyPlant then
            WaitTime = 0
            DrawText3D(WeedCoords.x, WeedCoords.y, WeedCoords.z + 1, "~o~E~w~ - Trim Weed")
            if IsControlJustReleased(0, 38) then
                TriggerServerEvent('qb-weed-farm:server:trim', WeedCoords.x, WeedCoords.y)
            end
        end
        Wait(WaitTime)
    end
end)

--- All the interaction locations
CreateThread(function()
    while true do 
        local WaitTime = 750
        local PlayerCoords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.locations) do
            if not DoingSomething then
                if k == 'cutweed' then
                    if #(PlayerCoords - v) <= 1.5 then
                        WaitTime = 0
                        DrawText3D(v.x, v.y, v.z + 0.4, "~o~E~w~ - Cut Weed")
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent('qb-weed-farm:server:cutting')
                        end
                    elseif #(PlayerCoords - v) <= 2.8 then
                        WaitTime = 0
                        DrawText3D(v.x, v.y, v.z + 0.4, "Cut Weed")
                    end
                elseif k == 'dryweed' then
                    if not DryingWeed then
                        if not WeedCollected then
                            if #(PlayerCoords - v) <= 1.5 then
                                WaitTime = 0
                                DrawText3D(v.x, v.y, v.z + 0.4, "~o~E~w~ - Dry Weed")
                                if IsControlJustReleased(0, 38) then
                                    TriggerServerEvent('qb-weed-farm:server:drying')
                                end
                            elseif #(PlayerCoords - v) <= 3.4 then
                                WaitTime = 0
                                DrawText3D(v.x, v.y, v.z + 0.4, "Dry Weed")
                            end
                        else
                            if #(PlayerCoords - v) <= 2 then
                                WaitTime = 0
                                DrawText3D(v.x, v.y, v.z + 0.4, "~o~E~w~ - Collect Weed")
                                if IsControlJustReleased(0, 38) then
                                    CollectWeed()
                                end
                            end
                        end
                    else
                        if #(PlayerCoords - v) <= 2 then
                            WaitTime = 0
                            DrawText3D(v.x, v.y, v.z + 0.4, "Weed is dry over: ~o~"..WeedTimer)
                        end
                    end
                end
            end
        end
        Wait(WaitTime)
    end
end)

RegisterNetEvent('qb-weed-farm:client:trim-start', function(Scissors)
    DoingSomething = true
    TrimWeedMinigame(NetworkGetEntityFromNetworkId(Scissors))
end)

RegisterNetEvent('qb-weed-farm:client:cutting-start', function(Scissors, Plant)
    DoingSomething = true
    LoopParticle = true
    local PropScissors = NetworkGetEntityFromNetworkId(Scissors)
    local PropPlant = NetworkGetEntityFromNetworkId(Plant)
    StartCuttingWeed(PropScissors, PropPlant)
    local Dictionary = 'core'
    local ParticleName = 'bul_leaves'
    CreateThread(function()
        RequestNamedPtfxAsset(Dictionary)
        while not HasNamedPtfxAssetLoaded(Dictionary) do Wait(0) end
        while LoopParticle do
            UseParticleFxAssetNextCall(Dictionary)
            StartNetworkedParticleFxNonLoopedOnEntity(ParticleName, PropPlant, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0)
            RemoveNamedPtfxAsset(Dictionary)
            Wait(1000)
        end
        DeleteEntity(PropScissors)
        DeleteEntity(PropPlant)
    end)
end)

RegisterNetEvent('qb-weed-farm:client:drying-start', function(Leaves)
    DoingSomething = true
    DriedLeaves = Leaves
    StartDryingWeed()
end)
