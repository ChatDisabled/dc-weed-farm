local QBCore = exports['qb-core']:GetCoreObject()
local WeedPlant = nil
local WeedCoords = nil
local NearbyPlant = false
local DoingSomething = false
local DryingWeed = false
local WeedCollected = false
local DriedLeaves = nil

-- Distance Check On Weed Prop
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

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Show Text On Weed When Nearby And Check For Button Presses
-- Different Thread for optimization purposes (From 0.13ms to 0.04ms)
CreateThread(function()
	while true do
        local WaitTime = 300
        if NearbyPlant then
            WaitTime = 3
            DrawText3D(WeedCoords.x, WeedCoords.y, WeedCoords.z + 1, "~o~E~w~ - Trim Weed")
            if IsControlJustReleased(0, 38) then
                TriggerServerEvent('qb-weed-farm:trim', WeedCoords.x, WeedCoords.y)
            end
        end
        Wait(WaitTime)
    end
end)

local function CollectWeed()
    WeedCollected = false
    TriggerServerEvent('qb-weed-farm:drying:finished', DriedLeaves)
    DriedLeaves = nil
end

CreateThread(function()
    while true do 
        local WaitTime = 1000
        local PlayerCoords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.locations) do
            if not DoingSomething then 
                if k == 'cutweed' then 
                    if #(PlayerCoords - v) <= 1.5 then
                        WaitTime = 3
                        DrawText3D(v.x, v.y, v.z + 0.4, "~o~E~w~ - Cut Weed")
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent('qb-weed-farm:cutting')
                        end
                    elseif #(PlayerCoords - v) <= 2.8 then
                        WaitTime = 3
                        DrawText3D(v.x, v.y, v.z + 0.4, "Cut Weed")
                    end
                elseif k == 'dryweed' then 
                    if not DryingWeed then 
                        if not WeedCollected then
                            if #(PlayerCoords - v) <= 1.5 then
                                WaitTime = 3
                                DrawText3D(v.x, v.y, v.z + 0.4, "~o~E~w~ - Dry Weed")
                                if IsControlJustReleased(0, 38) then
                                    TriggerServerEvent('qb-weed-farm:drying')
                                end
                            elseif #(PlayerCoords - v) <= 3.4 then
                                WaitTime = 3
                                DrawText3D(v.x, v.y, v.z + 0.4, "Dry Weed")
                            end
                        else
                            if #(PlayerCoords - v) <= 2 then
                                WaitTime = 3
                                DrawText3D(v.x, v.y, v.z + 0.4, "~o~E~w~ - Collect Weed")
                                if IsControlJustReleased(0, 38) then
                                    CollectWeed()
                                end
                            end
                        end
                    else
                        if #(PlayerCoords - v) <= 2 then
                            WaitTime = 3
                            DrawText3D(v.x, v.y, v.z + 0.4, "Weed is dry over: ~o~"..WeedTimer)
                        end
                    end
                end
            end
        end
        Wait(WaitTime)
    end
end)

local function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(7)
    end    
end

local function TrimWeedMinigame()
    LoadAnimDict('anim@amb@business@weed@weed_inspecting_lo_med_hi@')
	TaskPlayAnim(PlayerPedId(), 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' ,'weed_crouch_checkingleaves_idle_03_inspector', 8.0, -8.0, -1, 48, 0, false, false, false)

    local NeededAttempts = 0
    local SucceededAttempts = 0
    local FailedAttemps = 0
    
    local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
    if NeededAttempts == 0 then
        NeededAttempts = math.random(1, 2)
    end
    Skillbar.Start({
        duration = math.random(650, 850),
        pos = math.random(10, 30),
        width = math.random(11, 16),
    }, function()
        if SucceededAttempts + 1 >= NeededAttempts then
            TriggerServerEvent('qb-weed-farm:trim:finished', SucceededAttempts, NeededAttempts)
            ClearPedTasks(PlayerPedId())
            FailedAttemps = 0
            SucceededAttempts = 0
            NeededAttempts = 0
            Wait(50)
            DoingSomething = false
        else
            SucceededAttempts = SucceededAttempts + 1
            Skillbar.Repeat({
                duration = math.random(750, 900),
                pos = math.random(10, 30),
                width = math.random(10, 15),
            })
        end
	end, function()
        QBCore.Functions.Notify('That wasn\'t really a good cut was it?', 'error', 3000)
        ClearPedTasks(PlayerPedId())
        FailedAttemps = 0
        SucceededAttempts = 0
        NeededAttempts = 0
        Wait(50)
        DoingSomething = false
    end)
end

RegisterNetEvent('qb-weed-farm:trim:start', function()
    DoingSomething = true
    TrimWeedMinigame()
end)

local function FinishMinigame(faults)
    DoingSomething = false
    DetachEntity(Scissors)
    DetachEntity(Plant)
    DeleteEntity(Scissors)
    DeleteEntity(Plant)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('qb-weed-farm:cutting:finished', faults)
end

local function StartCuttingWeed()
    local ped = PlayerPedId()
    LoadAnimDict('anim@amb@business@weed@weed_inspecting_lo_med_hi@')
	TaskPlayAnim(ped, 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' ,'weed_crouch_checkingleaves_idle_01_inspector' ,8.0, -8.0, -1, 48, 0, false, false, false)
    Scissors = CreateObject(GetHashKey('v_ret_gc_scissors'), 0, 0, 0, true, true, true)
    Plant = CreateObject(GetHashKey('prop_weed_02'), 0, 0, 0, true, true, true)
    AttachEntityToEntity(Scissors, ped, GetPedBoneIndex(ped, 57005), 0.18, 0.1, 0.0, 180.0, 0, 130.0, true, true, false, true, 1, true)
    AttachEntityToEntity(Plant, ped, GetPedBoneIndex(ped, 18905), 0.11, -0.22, 0.32, -40.0, 180.0, 0.0, true, true, false, true, 1, true)
    TriggerEvent('qb-keyminigame:show')
    TriggerEvent('qb-keyminigame:start', FinishMinigame)
end

RegisterNetEvent('qb-weed-farm:cutting:start', function()
    DoingSomething = true
    StartCuttingWeed()
end)

local function StartDryingWeed()
    local ped = PlayerPedId()
    LoadAnimDict('anim@amb@business@weed@weed_inspecting_lo_med_hi@')
	TaskPlayAnim(ped, 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' ,'weed_crouch_checkingleaves_idle_01_inspector' ,8.0, -8.0, -1, 48, 0, false, false, false)
    Wait(4500)
    ClearPedTasks(ped)
    DoingSomething = false
    DryingWeed = true
    
    WeedTimer = Config.weedtimer
    while WeedTimer > 0 do
        WeedTimer = WeedTimer - 1
        Wait(1000)
    end

    DryingWeed = false
    WeedCollected = true
    TriggerServerEvent('qb-weed-farm:drying:updateprop')
end

RegisterNetEvent('qb-weed-farm:drying:start', function(Leaves)
    DoingSomething = true
    DriedLeaves = Leaves
    StartDryingWeed()
end)
