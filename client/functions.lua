function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(7)
    end    
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function CollectWeed()
    WeedCollected = false
    TriggerServerEvent('qb-weed-farm:server:drying-finished', DriedLeaves)
    DriedLeaves = nil
end

function TrimWeedMinigame(Scissors)
    local Ped = PlayerPedId()
    LoadAnimDict('anim@amb@business@weed@weed_inspecting_lo_med_hi@')
	TaskPlayAnim(Ped, 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' ,'weed_crouch_checkingleaves_idle_03_inspector', 8.0, -8.0, -1, 48, 0)
    FreezeEntityPosition(Ped, true)
    AttachEntityToEntity(Scissors, Ped, GetPedBoneIndex(Ped, 57005), 0.18, 0.1, 0.0, 180.0, 0, 130.0, true, true, false, true, 1, true)

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
            TriggerServerEvent('qb-weed-farm:server:trim-finished', SucceededAttempts, NeededAttempts)
            ClearPedTasks(Ped)
            FreezeEntityPosition(Ped, false)
            DeleteEntity(Scissors)
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
        ClearPedTasks(Ped)
        FreezeEntityPosition(Ped, false)
        DeleteEntity(Scissors)
        FailedAttemps = 0
        SucceededAttempts = 0
        NeededAttempts = 0
        Wait(50)
        DoingSomething = false
    end)
end

function FinishMinigame(faults)
    DoingSomething = false
    LoopParticle = false
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('qb-weed-farm:server:cutting-finished', faults)
end

function StartCuttingWeed(Scissors, Plant)
    local Ped = PlayerPedId()
    LoadAnimDict('anim@amb@business@weed@weed_inspecting_lo_med_hi@')
	TaskPlayAnim(Ped, 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' ,'weed_crouch_checkingleaves_idle_01_inspector', 8.0, -8.0, -1, 48, 0)
    AttachEntityToEntity(Scissors, Ped, GetPedBoneIndex(Ped, 57005), 0.18, 0.1, 0.0, 180.0, 0, 130.0, true, true, false, true, 1, true)
    AttachEntityToEntity(Plant, Ped, GetPedBoneIndex(Ped, 18905), 0.11, -0.22, 0.32, -40.0, 180.0, 0.0, true, true, false, true, 1, true)
    TriggerEvent('qb-keyminigame:show')
    TriggerEvent('qb-keyminigame:start', FinishMinigame)
end

function StartDryingWeed()
    local Ped = PlayerPedId()
    LoadAnimDict('anim@amb@business@weed@weed_inspecting_lo_med_hi@')
	TaskPlayAnim(Ped, 'anim@amb@business@weed@weed_inspecting_lo_med_hi@' ,'weed_crouch_checkingleaves_idle_01_inspector', 8.0, -8.0, -1, 48, 0)
    Wait(4500)
    ClearPedTasks(Ped)
    DoingSomething = false
    DryingWeed = true
    
    WeedTimer = Config.weedtimer
    while WeedTimer > 0 do
        WeedTimer = WeedTimer - 1
        Wait(1000)
    end

    DryingWeed = false
    WeedCollected = true
    TriggerServerEvent('qb-weed-farm:server:drying-updateprop')
end
