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

function HasItemClient(item, amount)
    if not UsingOxInventory and Framework == "qb-core" then
        return QBCore.Functions.HasItem(item, amount)
    elseif UsingOxInventory then
        if UsingOxInventory then
            local itemCount = exports.ox_inventory:Search("count", item)
            if type(itemCount) == "table" then
                for k, v in pairs(itemCount) do
                    itemCount = v
                end
            end
            if not itemCount then
                return false
            elseif itemCount >= amount then
                return true
            else
                return false
            end
        else
            return QBCore.Functions.HasItem(item, amount)
        end
    end
    return false
end