if GetResourceState('qbx_core') == 'started' then
    Framework = "qbox"
elseif GetResourceState('qb-core') == 'started' then
    Framework = "qb-core"
    QBCore = exports['qb-core']:GetCoreObject()
end
if GetResourceState('qb-target') == 'started' then
    Target = "qb"
elseif GetResourceState('ox_target') == 'started' then
    Target = "ox"
end
UsingOxInventory = GetResourceState('ox_inventory') == 'started'

function GetPlayerData()
    if Framework == "qb-core" then
        return QBCore.Functions.GetPlayerData()
    elseif Framework == "qbox" then
        return QBX.PlayerData
    end
end