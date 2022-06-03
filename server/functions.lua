function CreateLog(id, source, Player)
    local Log = {
        'Tried to farm weed outside the weed farm. [Log #1]',
        'Tried to cheat this event. **qb-weed-farm:server:trim-finished** [Log #2]',
        'Tried to cheat this event. **qb-weed-farm:server:cutting** [Log #3]',
        'Tried to cheat this event. **qb-weed-farm:server:cutting-finished** [Log #4]',
        'Tried to cheat this event. **qb-weed-farm:server:drying** [Log #5]',
        'Tried to cheat this event. **qb-weed-farm:server:drying-finished** [Log #6]',
    }
    if not Log[id] then TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', 'Tried to create a log which doesn\'t exist. #'..id) print('Tried to create a log which doesn\'t exist. #'..id) return end
    TriggerEvent('qb-log:server:CreateLog', 'weedfarm', 'Weed Farm', 'green', string.format("**%s** (CitizenID: %s | ID: %s) - %s", GetPlayerName(source), Player.PlayerData.citizenid, source, Log[id]))
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function IsWeedTrimmed(CoordsX, CoordsY)
    for i = 1, #Trimmed do 
        if Trimmed[i].x == CoordsX and Trimmed[i].y == CoordsY then return true end
    end
    return false
end

function RegrowWeed(CoordsX, CoordsY)
    local EndTime = os.time() + Config.regrowtimer

    while os.time() < EndTime do
        Wait(1000)
    end
    
    for i = 1, #Trimmed do
        if not Trimmed[i] then return end
        if Trimmed[i].x == CoordsX and Trimmed[i].y == CoordsY then
            table.remove(Trimmed, i)
            break
        end
    end
end

function HasWeed(Player)
    for k, v in pairs(Config.weedleaves) do
        local Item = Player.Functions.GetItemByName(k)
        if Item then
            return true, k, v
        end
    end
    return false
end

function HasLeaves(Player)
    for k, v in pairs(Config.weeddryleaves) do
        local Item = Player.Functions.GetItemByName(k)
        if Item then
            return true, k, v
        end
    end
    return false
end

function CreateProp()
    if DoesEntityExist(WeedProp) then return end
    WeedProp = CreateObject(`bkr_prop_weed_drying_01a`, Config.dryingprop, true, true)
    FreezeEntityPosition(WeedProp, true)
end
