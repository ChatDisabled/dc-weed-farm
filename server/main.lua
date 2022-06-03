QBCore = exports['qb-core']:GetCoreObject()
local StartedTrimming = {}
local StartedCutting = {}
local StartedDrying = {}
Trimmed = {}
WeedProp = nil

RegisterNetEvent('qb-weed-farm:server:trim', function(CoordsX, CoordsY)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
    local CoordsX = round(CoordsX, 2)
    local CoordsY = round(CoordsY, 2)

    if #(PlayerCoords - vector3(2225.06, 5576.38, 53.8)) > 20 then CreateLog(1, source, Player) return end
    if CoordsX >= 2250 or CoordsX <= 2210 then CreateLog(1, source, Player) return end
    if CoordsY >= 5590 or CoordsY <= 5570 then CreateLog(1, source, Player) return end
    if IsWeedTrimmed(CoordsX, CoordsY) then TriggerClientEvent('QBCore:Notify', src, 'The plant still needs to regrow', 'error', 3000) return end
    if not Player.Functions.GetItemByName(Config.trimmer) then TriggerClientEvent('QBCore:Notify', src, 'You don\'t have anything to trim this with', 'error', 3000) return end

    Trimmed[#Trimmed + 1] = {x = CoordsX, y = CoordsY}
    StartedTrimming[src] = true
    local Scissors = CreateObject(`v_ret_gc_scissors`, 0, 0, 0, true, true)
    while not DoesEntityExist(Scissors) do Wait(0) end
    TriggerClientEvent('qb-weed-farm:client:trim-start', src, NetworkGetNetworkIdFromEntity(Scissors))
    RegrowWeed(CoordsX, CoordsY)
end)

RegisterNetEvent('qb-weed-farm:server:trim-finished', function(SucceededAttempts, NeededAttempts)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
    local WeedSort = Config.weedsorts[math.random(1, #Config.weedsorts)]
    local Luck = math.random(1, 100)

    if #(PlayerCoords - vector3(2225.06, 5576.38, 53.8)) > 20 then CreateLog(1, source, Player) return end
    if SucceededAttempts + 1 < NeededAttempts then CreateLog(2, source, Player) return end
    if SucceededAttempts >= 4 then CreateLog(2, source, Player) return end
    if not StartedTrimming[src] then CreateLog(2, source, Player) return end
    if not Player.Functions.GetItemByName(Config.trimmer) then TriggerClientEvent('QBCore:Notify', src, 'You don\'t have anything to trim this with', 'error', 3000) return end

    StartedTrimming[src] = false
    Player.Functions.AddItem(WeedSort..'_plant', 1)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[WeedSort..'_plant'], "add")
    if Luck >= 98 then
        Player.Functions.AddItem(WeedSort..'_seed', 1)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[WeedSort..'_seed'], "add")
    end
end)

RegisterServerEvent('qb-weed-farm:server:cutting', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))

    if #(PlayerCoords - Config.locations['cutweed']) > 6 then CreateLog(3, source, Player) return end
    if not HasWeed(Player) then TriggerClientEvent('QBCore:Notify', src, 'You don\'t have any weed to cut leaves from', 'error', 3000) return end

    StartedCutting[src] = true
    local Scissors = CreateObject(`v_ret_gc_scissors`, 0, 0, 0, true, true)
    local Plant = CreateObject(`prop_weed_02`, 0, 0, 0, true, true)
    while not DoesEntityExist(Scissors) do Wait(0) end
    while not DoesEntityExist(Plant) do Wait(0) end
    TriggerClientEvent('qb-weed-farm:client:cutting-start', src, NetworkGetNetworkIdFromEntity(Scissors), NetworkGetNetworkIdFromEntity(Plant))
end)

RegisterServerEvent('qb-weed-farm:server:cutting-finished', function(Faults)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
    local LeavesAmount = math.random(1, 3)
    local HasWeed, WeedPlant, WeedLeave = HasWeed(Player)

    if #(PlayerCoords - Config.locations['cutweed']) > 6 then CreateLog(4, source, Player) return end
    if not StartedCutting[src] then CreateLog(4, source, Player) return end
    if not HasWeed then return end
    if Faults >= 3 then 
        TriggerClientEvent('QBCore:Notify', src, 'That wasn\'t really a good cut was it?', 'error', 3000)
        Player.Functions.RemoveItem(WeedPlant, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[WeedPlant], 'remove')
        return
    end

    StartedCutting[src] = false
    if Player.Functions.RemoveItem(WeedPlant, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[WeedPlant], 'remove')
        Player.Functions.AddItem(WeedLeave, LeavesAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[WeedLeave], 'add')
        TriggerClientEvent('QBCore:Notify', src, 'I like your cut G', 'success', 3000)
    end
end)

RegisterServerEvent('qb-weed-farm:server:drying', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
    local Has, Leaves, DriedLeaves = HasLeaves(Player)

    if #(PlayerCoords - Config.locations['dryweed']) > 6 then CreateLog(5, source, Player) return end
    if not Has then TriggerClientEvent('QBCore:Notify', src, 'You don\'t have any leaves to dry', 'error', 3000) return end

    if Player.Functions.RemoveItem(Leaves, 1) then
        StartedDrying[src] = true
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Leaves], 'remove')
        TriggerClientEvent('qb-weed-farm:client:drying-start', src, DriedLeaves)
        CreateProp()
    end
end)

RegisterServerEvent('qb-weed-farm:server:drying-finished', function(DriedLeaves)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))

    if #(PlayerCoords - Config.locations['dryweed']) > 6 then CreateLog(6, source, Player) return end
    if not StartedDrying[src] then CreateLog(6, source, Player) return end
    if DriedLeaves == nil then return end

    Player.Functions.AddItem(DriedLeaves, 1)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[DriedLeaves], "add")
    DeleteEntity(WeedProp)
end)

RegisterNetEvent('qb-weed-farm:server:drying-updateprop', function()
    if DoesEntityExist(WeedProp) then DeleteEntity(WeedProp) end
    WeedProp = CreateObject(`bkr_prop_weed_drying_02a`, Config.dryingprop.x, Config.dryingprop.y, Config.dryingprop.z - 0.30, true, true)
    FreezeEntityPosition(WeedProp, true)
end)
