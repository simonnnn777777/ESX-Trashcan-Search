ESX = exports["es_extended"]:getSharedObject()

local searchedBins = {}
local binCooldowns = {}
local BIN_COOLDOWN_SECONDS = 300 -- 5 Minuten Cooldown pro Mülleimer

local Config = {}

Config.Items = {
    {name = "bread", chance = 30},
    {name = "water", chance = 25},
    {name = "weapon_pistol", chance = 15},
    {name = "iron", chance = 10},
    {name = "powerade1", chance = 20}
}

Config.FindChance = 80 -- 80% Chance, überhaupt was zu finden
Config.Webhook = "" -- Your Discord webhook

RegisterServerEvent("trashsearch:searchBin")
AddEventHandler("trashsearch:searchBin", function(binId, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local currentTime = os.time()

    -- Check: Hat dieser Mülleimer gerade Cooldown?
    if binCooldowns[binId] and binCooldowns[binId] > currentTime then
        local remaining = binCooldowns[binId] - currentTime
        TriggerClientEvent('esx:showNotification', source, 'Dieser Mülleimer ist leer. Warte noch ' .. remaining .. ' Sekunden.')
        return
    end

    -- Cooldown setzen
    binCooldowns[binId] = currentTime + BIN_COOLDOWN_SECONDS

    local foundSomething = math.random(100) <= Config.FindChance

    if not foundSomething then
        TriggerClientEvent('esx:showNotification', source, 'Du hast nichts gefunden.')
        sendToDiscord(xPlayer.getName(), 'Hat nichts im Mülleimer gefunden.', coords)
        return
    end

    local roll = math.random(100)
    local itemToGive = nil

    for _, item in pairs(Config.Items) do
        if roll <= item.chance then
            itemToGive = item.name
            break
        else
            roll = roll - item.chance
        end
    end

    if itemToGive and itemToGive ~= "nothing" then
        xPlayer.addInventoryItem(itemToGive, 1)
        TriggerClientEvent('esx:showNotification', source, 'Du hast ~g~' .. itemToGive .. '~s~ gefunden.')
        sendToDiscord(xPlayer.getName(), 'Hat folgendes im Mülleimer gefunden: ' .. itemToGive, coords)
    else
        TriggerClientEvent('esx:showNotification', source, 'Du hast nichts gefunden.')
        sendToDiscord(xPlayer.getName(), 'Hat nichts im Mülleimer gefunden.', coords)
    end
end)

function sendToDiscord(name, message, coords)
    local embed = {
        {
            ["color"] = 16776960,
            ["title"] = "**Mülleimer durchsucht**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Spieler: " .. name .. "\nKoordinaten: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z
            }
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, "POST", json.encode({username = "Trash-Search", embeds = embed}), {["Content-Type"] = "application/json"})
end
