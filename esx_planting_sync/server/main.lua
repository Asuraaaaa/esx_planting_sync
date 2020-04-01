ESX = nil
local lastTime = nil
local spawnedWeeds = 0
local weedPlants = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

for item_name in pairs(options) do
    ESX.RegisterUsableItem(item_name, function(source)
        local _source = source
        local currentTime = os.time(os.date("!*t"))
        if lastTime and currentTime - lastTime < 10 then
            TriggerClientEvent("pNotify:SendNotification", source, {
                text = '沒有力氣種植，稍微休息一下',
                type = "error",
                timeout = 2000,
                layout = "centerLeft"
            })
            do return end
        end
        lastTime = os.time(os.date("!*t"))
		TriggerClientEvent('esx_planting_sync:RequestStart', _source, item_name, lastTime)
    end)
end

RegisterServerEvent("esx_planting_sync:addplants")
AddEventHandler("esx_planting_sync:addplants", function(obj)
    table.insert(weedPlants, obj)
    spawnedWeeds = spawnedWeeds + 1
    for i=1, #weedPlants, 1 do
        print(weedPlants[i])
    end
    TriggerClientEvent('esx_planting_sync:updatePlants', -1, weedPlants)
end)

RegisterServerEvent("esx_planting_sync:removeplants")
AddEventHandler("esx_planting_sync:removeplants", function(nearbyID)
    table.remove(weedPlants, nearbyID)
    spawnedWeeds = spawnedWeeds - 1
    for i=1, #weedPlants, 1 do
        print(weedPlants[i])
    end
    TriggerClientEvent('esx_planting_sync:updatePlants', -1, weedPlants)
end)


RegisterServerEvent("esx_planting_sync:RemoveItem")
AddEventHandler("esx_planting_sync:RemoveItem", function(item_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.removeInventoryItem(item_name, 1)
end)


RegisterServerEvent("esx_planting_sync:statusSuccess")
AddEventHandler("esx_planting_sync:statusSuccess", function(message, min, max, item)
    TriggerClientEvent('esx:showNotification', source, message)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    math.randomseed(os.time())
    local amount = math.random(min, max)
    local itemProps = xPlayer.getInventoryItem(item)
    if not (xPlayer.canCarryItem(item, amount)) then
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = '背包已滿',
            type = "error",
            timeout = 2000,
            layout = "centerLeft"
        })
    else
        xPlayer.addInventoryItem(item, amount)
    end
end)


ESX.RegisterServerCallback('esx_planting_sync:canPickUp', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.canCarryItem(item, 1))
end)

ESX.RegisterServerCallback('esx_planting_sync:spawnedWeeds', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(spawnedWeeds)
end)

ESX.RegisterServerCallback('esx_planting_sync:weedPlants', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(weedPlants)
end)