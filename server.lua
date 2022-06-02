local QBCore = exports['qb-core']:GetCoreObject()
local Trimmed = {}
local Cutting = {}
local Drying = {}
local WeedProp = nil

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function IsWeedTrimmed(CoordsX, CoordsY)
    local Has = false
    for i = 1, #Trimmed do 
        if Trimmed[i].x == CoordsX and Trimmed[i].y == CoordsY then 
            Has = true
            break
        end
    end
    return Has
end

local function RegrowWeed(CoordsX, CoordsY)
    local Done = false
    Timer = Config.regrowtimer
    while Timer >= 1 do
        Timer = Timer - 1
        Wait(1000)
    end
    
    for i = 1, #Trimmed do
        if Done then
            break
        end
        if i then
            if Trimmed[i].x == CoordsX then
                if Trimmed[i].y == CoordsY then
                    table.remove(Trimmed, i)
                    Done = true
                end
            end
        end
    end
end

local function CreateLog(id, source, Player)
    local notifications = {
        [1] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to farm weed outside the weed farm. **qb-weed-farm:trim**')
        end,
        [2] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to farm weed outside the weed farm. **qb-weed-farm:trim:finished**')
        end,
        [3] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to cheat this event. **qb-weed-farm:trim:finished**')
        end,
        [4] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to cut outside the cutting zone. **qb-weed-farm:cutting**')
        end,
        [5] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to cut outside the cutting zone. **qb-weed-farm:cutting:finished**')
        end,
        [6] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to trigger an event he shouldn\'t be triggering. **qb-weed-farm:cutting:finished**')
        end,
        [7] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to dry outside the drying zone. **qb-weed-farm:drying**')
        end,
        [8] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to dry outside the drying zone. **qb-weed-farm:drying:finished**')
        end,
        [9] = function()
            TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..')  Tried to trigger an event he shouldn\'t be triggering. **qb-weed-farm:drying:finished**')
        end
    }
    local type = notifications[id]
	if type then
		type()
	else
		print("qb-weed-farm something is wrong with the logs")
	end
end

RegisterNetEvent('qb-weed-farm:trim', function(CoordsX, CoordsY)
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
    TriggerClientEvent('qb-weed-farm:trim:start', src)
    RegrowWeed(CoordsX, CoordsY)
end)

RegisterNetEvent('qb-weed-farm:trim:finished', function(SucceededAttempts, NeededAttempts)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
    local WeedSort = Config.weedsorts[math.random(1, #Config.weedsorts)]
    local Seed = WeedSort..'_seed'
    local Luck = math.random(1, 100)

    if #(PlayerCoords - vector3(2225.06, 5576.38, 53.8)) > 20 then CreateLog(2, source, Player) return end
    if SucceededAttempts + 1 < NeededAttempts then CreateLog(3, source, Player) return end
    if SucceededAttempts >= 4 then CreateLog(3, source, Player) return end
    if not Player.Functions.GetItemByName(Config.trimmer) then TriggerClientEvent('QBCore:Notify', src, 'You don\'t have anything to trim this with', 'error', 3000) return end

    Player.Functions.AddItem(WeedSort..'_plant', 1)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[WeedSort..'_plant'], "add")
    if Luck >= 98 then
        Player.Functions.AddItem(WeedSort..'_seed', 1)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[WeedSort..'_seed'], "add")
    end
end)

local function HasWeed(Player)
    local Has = false
    for k, v in pairs(Config.weedleaves) do
        local Item = Player.Functions.GetItemByName(k)
        if Item ~= nil then
            Has = true
            WeedPlant = k
            WeedLeave = v
            break
        end
    end
    return Has
end

local function StartedCutting(source)
    local Exists = false
    for i = 1, #Cutting do 
        if Cutting[i].Id == source then
            Exists = true
            Cutting[i].Started = true
            break
        end
    end
    if not Exists then
        Cutting[#Cutting + 1] = {Id = source, Started = true}
    end
end

RegisterServerEvent('qb-weed-farm:cutting', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))

    if #(PlayerCoords - Config.locations['cutweed']) > 6 then CreateLog(4, source, Player) return end
    if not HasWeed(Player) then TriggerClientEvent('QBCore:Notify', src, 'You don\'t have any weed to cut leaves from', 'error', 3000) return end

    StartedCutting(src)
    TriggerClientEvent('qb-weed-farm:cutting:start', src)
end)

local function HasStartedCutting(source)
    local Has = false
    for i = 1, #Cutting do 
        if Cutting[i].Id == source and Cutting[i].Started then
            Has = true
            Cutting[i].Started = false
            break
        end
    end
    return Has
end

RegisterServerEvent('qb-weed-farm:cutting:finished', function(faults)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
    local LeavesAmount = math.random(1, 3)
    
    if #(PlayerCoords - Config.locations['cutweed']) > 6 then CreateLog(5, source, Player) return end
    if not HasStartedCutting(src) then CreateLog(6, source, Player) return end
    if not HasWeed(Player) then return end
    if faults >= 3 then TriggerClientEvent('QBCore:Notify', src, 'That wasn\'t really a good cut was it?', 'error', 3000) return end

    if Player.Functions.RemoveItem(WeedPlant, 1) then
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[WeedPlant], "remove")
        Player.Functions.AddItem(WeedLeave, LeavesAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[WeedLeave], "add")
        TriggerClientEvent('QBCore:Notify', src, 'I like your cut G', 'success', 3000)
    end
end)

local function WhichLeaves(src)
    local Has = false
    local Plant = nil
    local Leaves = nil
    local Player = QBCore.Functions.GetPlayer(src)
    for k, v in pairs(Config.weeddryleaves) do
        local Item = Player.Functions.GetItemByName(k)
        if Item ~= nil then
            Has = true
            Plant = k
            Leaves = v
            break
        end
    end
    return Has, Plant, Leaves
end

local function StartedDrying(source)
    local Exists = false
    for i = 1, #Drying do 
        if Drying[i].Id == source then
            Exists = true
            Drying[i].Started = true
            break
        end
    end
    if not Exists then
        Drying[#Drying + 1] = {Id = source, Started = true}
    end
end

local function CreateProp()
    if DoesEntityExist(WeedProp) then return end
    WeedProp = CreateObject(`bkr_prop_weed_drying_01a`, vector3(1943.01, 4654.66, 43.15), true, true, true)
    FreezeEntityPosition(WeedProp, true)
end

RegisterServerEvent('qb-weed-farm:drying', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
    local Has, Leaves, DriedLeaves = WhichLeaves(src)
    
    if #(PlayerCoords - Config.locations['dryweed']) > 6 then CreateLog(7, source, Player) return end
    if not Has then TriggerClientEvent('QBCore:Notify', src, 'You don\'t have any leaves to dry', 'error', 3000) return end
    
    if Player.Functions.RemoveItem(Leaves, 1) then
        StartedDrying(src)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Leaves], "remove")
        TriggerClientEvent('qb-weed-farm:drying:start', src, DriedLeaves)
        CreateProp()
    end
end)

local function HasStartedDrying(source)
    local Has = false
    for i = 1, #Drying do 
        if Drying[i].Id == source and Drying[i].Started then
            Has = true
            Drying[i].Started = false
            break
        end
    end
    return Has
end

RegisterServerEvent('qb-weed-farm:drying:finished', function(DriedLeaves)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))

    if #(PlayerCoords - Config.locations['dryweed']) > 6 then CreateLog(8, source, Player) return end
    if not HasStartedDrying(src) then CreateLog(9, source, Player) return end
    if DriedLeaves == nil then return end
    
    Player.Functions.AddItem(DriedLeaves, 1)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[DriedLeaves], "add")
    DeleteEntity(WeedProp)
end)

RegisterNetEvent('qb-weed-farm:drying:updateprop', function()
    if DoesEntityExist(WeedProp) then DeleteEntity(WeedProp) end
    WeedProp = CreateObject(`bkr_prop_weed_drying_02a`, vector3(1943.01, 4654.66, 42.86), true, true, true)
    FreezeEntityPosition(WeedProp, true)
end)
