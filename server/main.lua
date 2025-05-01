local ox_inventory = exports.ox_inventory
Racks = {}
RacksLoaded = false

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    GetAllGunRacks()
end)

local function getWeaponSlot(rack, weaponName)
    local weaponType = Config.RackableWeapons[weaponName].weaponType
    if not weaponType then return false end
    for i=1, 5 do
        if not Racks[rack][weaponType][i] or Racks[rack][weaponType][i].available then
            return i
        end
    end
    return false
end

local function inDistanceOfGunRack(id, src)
    if not Racks[id] then return false end

    local ped = GetPlayerPed(src)
    if ped == 0 then return false end

    if #(GetEntityCoords(ped) - vec3(Racks[id].coords.x, Racks[id].coords.y, Racks[id].coords.z)) < 6 then
        return true
    end
    return false
end

RegisterServerEvent('cb-gangsystem:server:PlaceGunRack', function(coords, rot, code)
    local src = source
    local ped = GetPlayerPed(src)
    local sourceCoords = GetEntityCoords(ped)
    if #(sourceCoords - coords) > 5 then return end
    local Player = GetPlayer(src)
    if not Player then return end
    local inHideout = Player.PlayerData.metadata['gangHideout']
    if (inHideout == nil) or inHideout == 0 then
        return
    end
    if ox_inventory:RemoveItem(src, 'gunrack', 1) then
        local rackData = {
            coords = {x = coords.x, y = coords.y, z = coords.z, w = rot},
            rifles = {},
            pistols = {},
            ammo = {},
            code = code,
            taser = false,
            hideout_id = inHideout,
        }
        local result = SQLQuery('INSERT INTO gang_gunracks (hideout_id, coords, rifles, pistols, ammo, code, taser) VALUES (@hideout_id, @coords, @rifles, @pistols, @ammo, @code, @taser)', {
            ['@hideout_id'] = rackData.hideout_id,
            ['@coords'] = json.encode(rackData.coords),
            ['@rifles'] = json.encode(rackData.rifles),
            ['@pistols'] = json.encode(rackData.pistols),
            ['@ammo'] = json.encode(rackData.ammo),
            ['@code'] = rackData.code,
            ['@taser'] = rackData.taser and '1' or '0'
        })
        Racks[result.insertId] = rackData
        for k, v in pairs(GetPlayers()) do
            local xPlayer = GetPlayer(v)
            if xPlayer == nil then return end
            if xPlayer.PlayerData.metadata['gangHideout'] == inHideout then
                TriggerClientEvent('cb-gangsystem:client:spawnGunRack', v, result.insertId, rackData)
            end
        end
    end
end)

RegisterServerEvent('cb-gangsystem:server:MoveGunRack', function(coords, rot, id)
    local src = source
    local ped = GetPlayerPed(src)
    local sourceCoords = GetEntityCoords(ped)
    if #(sourceCoords - coords) > 5 then return end
    local Player = GetPlayer(src)
    if not Player then return end
    local inHideout = Player.PlayerData.metadata['gangHideout']
    if (inHideout == nil) or inHideout == 0 then
        return
    end
    Racks[id].coords = {x = coords.x, y = coords.y, z = coords.z, w = rot}
    SQLQuery('UPDATE gang_gunracks SET coords = @coords WHERE id = @id', {
        ['@coords'] = json.encode(Racks[id].coords),
        ['@id'] = id
    })
    for k, v in pairs(GetPlayers()) do
        local xPlayer = GetPlayer(v)
        if xPlayer == nil then return end
        if xPlayer.PlayerData.metadata['gangHideout'] == inHideout then
            TriggerClientEvent('cb-gangsystem:client:fadeGunRack', v, id)
            TriggerClientEvent('cb-gangsystem:client:spawnGunRack', v, id, Racks[id])
        end
    end
end)

AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    if name == "gunrack" then
        local Player = GetPlayer(playerId)
        if not Player then return end
        local inHideout = Player.PlayerData.metadata['gangHideout']
        if (inHideout == nil) or inHideout == 0 then
            print("Player is not in a hideout")
        else
            TriggerClientEvent('cb-gangsystem:client:PlaceGunRack', playerId)
        end
    end
end)

RegisterServerEvent('cb-gangsystem:server:storeWeapon', function(rackIndex, weaponSlot, weaponName)
    local src = source
    if not inDistanceOfGunRack(rackIndex, src) then return end
    while Racks[rackIndex].busy do Wait(10) end
    Racks[rackIndex].busy = true
    if not Config.RackableWeapons[weaponName] then return end
    local weaponType = Config.RackableWeapons[weaponName].weaponType
    local rackSlot = getWeaponSlot(rackIndex, weaponName)
    if rackSlot then
        local slot = exports.ox_inventory:GetSlot(src, weaponSlot)
        if slot.name ~= weaponName then return end
        if ox_inventory:RemoveItem(src, weaponName, 1, nil, weaponSlot) then
            local rackInfo = Racks[rackIndex]
            local data = {
                name = weaponName,
                available = false,
                metadata = slot.metadata
            }
            rackInfo[weaponType][rackSlot] = data
            SaveGunRack(rackIndex, rackInfo, weaponType)
            TriggerClientEvent('cb-gangsystem:client:storeWeapon', -1, rackIndex, rackSlot, weaponType, data)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                description = 'Weird, you don\'t have that weapon',
                type = 'error'
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'No more slots of that type left',
            type = 'error'
        })
    end
    Racks[rackIndex].busy = false
end)

RegisterServerEvent('cb-gangsystem:server:storeAmmo', function(rackIndex, weaponSlot, weaponName, amount)
    local src = source
    if not inDistanceOfGunRack(rackIndex, src) then return end
    while Racks[rackIndex].busy do Wait(10) end
    Racks[rackIndex].busy = true
    local weaponType = Config.RackableWeapons[weaponName].weaponType
    local rackSlot = getWeaponSlot(rackIndex, weaponName)
    if rackSlot then
        local slot = exports.ox_inventory:GetSlot(src, weaponSlot)
        if slot.name ~= weaponName then return end
        if ox_inventory:RemoveItem(src, weaponName, amount, nil, weaponSlot) then
            local rackInfo = Racks[rackIndex]
            local data = {
                name = weaponName,
                available = false,
                count = amount
            }
            rackInfo[weaponType][rackSlot] = data
            SaveGunRack(rackIndex, rackInfo, weaponType)
            TriggerClientEvent('cb-gangsystem:client:storeAmmo', -1, rackIndex, rackSlot, weaponType, data)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                description = 'Weird, you don\'t have that weapon',
                type = 'error'
            })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'No more slots of that type left',
            type = 'error'
        })
    end
    Racks[rackIndex].busy = false
end)

RegisterServerEvent('cb-gangsystem:server:takeWeapon', function(rackIndex, rackSlot, weaponName)
    local src = source
    if not inDistanceOfGunRack(rackIndex, src) then return end
    while Racks[rackIndex].busy do Wait(10) end
    Racks[rackIndex].busy = true
    local weaponType = Config.RackableWeapons[weaponName].weaponType
    if weaponType ~= 'ammo' then
        if Racks[rackIndex][weaponType][rackSlot].name == weaponName then
            if ox_inventory:AddItem(src, weaponName, 1, Racks[rackIndex][weaponType][rackSlot].metadata) then
                local rackInfo = Racks[rackIndex]
                rackInfo[weaponType][rackSlot] = nil
                SaveGunRack(rackIndex, rackInfo, weaponType)
                TriggerClientEvent('cb-gangsystem:client:takeWeapon', -1, rackIndex, rackSlot, weaponType)
            end
        else
            Notify(src, 'That weapon does not seem to be in this rack', 'error')
        end
    else
        if Racks[rackIndex][weaponType][rackSlot].name == weaponName then
            if AddItem(src, weaponName, Racks[rackIndex][weaponType][rackSlot].count) then
                local rackInfo = Racks[rackIndex]
                rackInfo[weaponType][rackSlot] = nil
                SaveGunRack(rackIndex, rackInfo, weaponType)
                TriggerClientEvent('cb-gangsystem:client:takeWeapon', -1, rackIndex, rackSlot, weaponType)
            end
        else
            Notify(src, 'That weapon does not seem to be in this rack', 'error')
        end
    end
    Racks[rackIndex].busy = false
end)

RegisterServerEvent('cb-gangsystem:server:destroyGunRack', function(rackIndex)
    local src = source
    if not inDistanceOfGunRack(rackIndex, src) then return end
    if not Racks[rackIndex] then return end
    Racks[rackIndex] = nil
    DeleteGunRack(rackIndex)
    TriggerClientEvent('cb-gangsystem:client:destroyGunRack', -1, rackIndex)
end)

lib.callback.register('cb-gangsystem:server:getRacks', function(source)
    return Racks
end)

function GetAllGunRacks()
    Racks = {}
    
    local result = SQLQuery("SELECT * FROM gang_gunracks")
    for k, v in pairs(result) do        
        Racks[v.id] = {
            coords = json.decode(v.coords),
            rifles = json.decode(v.rifles),
            pistols = json.decode(v.pistols),
            ammo = json.decode(v.ammo),
            code = v.code or nil,
            taser = v.taser == 1 and true or false,
            hideout_id = v.hideout_id,
            isRendered = false
        }
    end
    RacksLoaded = true
    return Racks
end

function SaveGunRack(id, gunrackInfo, weaponType)
    if weaponType == 'pistols' then
        SQLQuery('UPDATE gang_gunracks SET pistols = @pistols WHERE id = @id', {
            ['@pistols'] = json.encode(gunrackInfo.pistols),
            ['@id'] = id
        })
        return
    end
    
    SQLQuery('UPDATE gang_gunracks SET rifles = @rifles WHERE id = @id', {
        ['@rifles'] = json.encode(gunrackInfo.rifles),
        ['@id'] = id
    })

    SQLQuery('UPDATE gang_gunracks SET ammo = @ammo WHERE id = @id', {
        ['@ammo'] = json.encode(gunrackInfo.ammo),
        ['@id'] = id
    })
end

function DeleteGunRack(id)
    SQLQuery('DELETE FROM gang_gunracks WHERE id = @id', {
        ['@id'] = id
    })
end

RegisterServerEvent('cb-gangsystem:server:ChangePasscodeGunRack', function(rackId, oldCode, code)
    print(rackId, oldCode, code)
    local rackCoords = Racks[rackId].coords
    local realRackCoords = vector3(rackCoords.x, rackCoords.y, rackCoords.z)
    local src = source
    local playerPed = GetPlayerPed(src)
    local coords = GetEntityCoords(playerPed)
    if #(coords - realRackCoords) > 4 then print("too Far away") return end
    if (oldCode == nil or oldCode == "") and (Racks[rackId].code == nil or Racks[rackId].code == "") then -- If the gun rack doesn't have a passcode, we do this
        Racks[rackId].code = code
        local query = SQLQuery("UPDATE gang_gunracks SET code = ? WHERE id = ?", {code, rackId})
        SendDataToAllClients("Racks", Racks)
        return
    end
    if oldCode ~= Racks[rackId].code then
        TriggerClientEvent('cb-gangsystem:client:Notify', src, "Wrong Passcode", "You entered the wrong passcode for the gun rack.", "error", 5000)
        return
    end
    if oldCode == code then
        TriggerClientEvent('cb-gangsystem:client:Notify', src, "Same Passcode", "You entered the same passcode for the gun rack.", "error", 5000)
        return
    end
    Racks[rackId].code = code
    local query = SQLQuery("UPDATE gang_gunracks SET code = ? WHERE id = ?", {code, rackId})
    SendDataToAllClients("Racks", Racks)
end)