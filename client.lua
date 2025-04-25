local ESX = exports["es_extended"]:getSharedObject()

-- Mülleimer Festlegen welche durchsucht werden können
local bins = {
    `prop_bin_01a`,
    `prop_bin_05a`,
    `prop_bin_07a`,
    `prop_bin_08a`,
}

local searchedBins = {}

for _, model in pairs(bins) do
    exports.ox_target:addModel(model, {
        label = 'Mülleimer durchsuchen',
        icon = 'fas fa-trash',
        onSelect = function(data)
            local entity = data.entity
            local coords = GetEntityCoords(entity)
            local binId = string.format('%s_%s_%s', math.floor(coords.x), math.floor(coords.y), math.floor(coords.z))

            if searchedBins[binId] then
                ESX.ShowNotification('Dieser Mülleimer wurde bereits durchsucht.')
                return
            end

            -- Animation laden und abspielen
            RequestAnimDict("amb@prop_human_bum_bin@base")
            while not HasAnimDictLoaded("amb@prop_human_bum_bin@base") do
                Wait(10)
            end
            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)

            -- Fortschrittsanzeige
            lib.progressCircle({
                duration = 5000,
                label = 'Durchsuche Mülleimer...',
                useWhileDead = false,
                canCancel = false,
                position = 'bottom',
            })

            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('trashsearch:searchBin', binId, coords)
        end
    })
end
