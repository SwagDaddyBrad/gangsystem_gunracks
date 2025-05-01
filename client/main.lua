local ox_inventory = exports.ox_inventory
Racks = {}
local rackModel = `xm_prop_xm_gunlocker_01a`
local tempRackObj = nil

local Keys = {
	["Q"] = 44, ["E"] = 38, ["ENTER"] = 18, ["X"] = 73
}

local ox_items = exports.ox_inventory:Items()
for item, data in pairs(ox_items) do
    if Config.RackableWeapons[item] then
        Config.RackableWeapons[item].label = data.label
    end
end

local function storeWeapon(rack, slot, name)
    TriggerServerEvent('cb-gangsystem:server:storeWeapon', rack, slot, name)
    lib.showContext('GunRackMenu')
end

local function storeAmmo(rack, slot, name, amount)
    TriggerServerEvent('cb-gangsystem:server:storeAmmo', rack, slot, name, amount)
    lib.showContext('GunRackMenu')
end

local function takeWeapon(rack, rackSlot, name)
    TriggerServerEvent('cb-gangsystem:server:takeWeapon', rack, rackSlot, name)
    lib.showContext('GunRackMenu')
end

local function GetRackPositionOffset(rackIndex, slot, weapon)
    local rack = Racks[rackIndex].object
    local weaponType = Config.RackableWeapons[weapon].weaponType
    local xOffset = ({
        rifles = {-0.395, -0.28, -0.17, -0.06, 0.06},
        pistols = {-0.32, -0.17, 0.00, 0.15, 0.30}
    })[weaponType][slot] or 0.0

    local weaponData = Config.RackableWeapons[weapon]
    local zOffset = weaponData.offset.z or 0.0
    local yOffset = weaponData.offset.y or 0.0

    local xRotation = weaponData.rotation.x or 1
    local yRotation = weaponData.rotation.y or 260
    local rackHeading = Racks[rackIndex].coords.w
    local weaponZRotation = weaponData.rotation.z or 90
    local zRotation = rackHeading - weaponZRotation

    return {
        offset = GetOffsetFromEntityInWorldCoords(rack, xOffset, yOffset, zOffset),
        rot = {x = xRotation, y = yRotation, z = zRotation}
    }
end

local function hasVarMod(hash, components)
    for i = 1, #components do
        local component = ox_items[components[i]]

        if component.type == 'skin' or component.type == 'upgrade' then
            local weaponComp = component.client.component
            for j = 1, #weaponComp do
                local weaponComponent = weaponComp[j]
                if DoesWeaponTakeWeaponComponent(hash, weaponComponent) then
                    return GetWeaponComponentTypeModel(weaponComponent)
                end
            end
        end
    end
end

local function getWeaponComponents(name, hash, components)
    local weaponComponents = {}
    local amount = 0
    local hadClip = false
    local varMod = hasVarMod(hash, components)

    for i = 1, #components do
        local weaponComp = ox_items[components[i]]
        for j = 1, #weaponComp.client.component do
            local weaponComponent = weaponComp.client.component[j]
            if DoesWeaponTakeWeaponComponent(hash, weaponComponent) and varMod ~= weaponComponent then
                amount += 1
                weaponComponents[amount] = weaponComponent

                if weaponComp.type == 'magazine' then
                    hadClip = true
                end
                break
            end
        end
    end

    if not hadClip then
        amount += 1
        weaponComponents[amount] = joaat(('COMPONENT_%s_CLIP_01'):format(name:sub(8)))
    end

    return varMod, weaponComponents, hadClip
end

local showDefaultsOverride = {
    ['WEAPON_STUNGUN'] = true,
}

local function spawnGun(rackId, slot, weaponType)
    local rack = Racks[rackId]
    if not rack or not rack[weaponType][slot] then return end

    local rackSlot = rack[weaponType][slot]
    local modelHash = GetHashKey(rackSlot.name)

    local _, hash = pcall(function()
		return lib.requestWeaponAsset(modelHash, 5000, 31, 0)
	end)

    if hash and hash ~= 0 then
        local hasLuxeMod, components, hadClip = getWeaponComponents(rackSlot.name, hash, rackSlot.metadata.components)
        if hasLuxeMod then
            lib.requestModel(hasLuxeMod, 500)
        end

        local showDefault = true

        if (hasLuxeMod and hadClip) or showDefaultsOverride[rackSlot.name] then
            showDefault = false
        end

        local position = GetRackPositionOffset(rackId, slot, rackSlot.name)
        lib.requestWeaponAsset(hash, 5000, 31, 0)
        rackSlot.object = CreateWeaponObject(hash, 50, position.offset.x, position.offset.y, position.offset.z, showDefault, 1.0, hasLuxeMod or 0, false, true)
        while not DoesEntityExist(rackSlot.object) do Wait(1) end
        SetEntityCoords(rackSlot.object, position.offset.x, position.offset.y, position.offset.z, false, false, false, true)
        
        if components then
            for i = 1, #components do
                GiveWeaponComponentToWeaponObject(rackSlot.object, components[i])
            end
        end

        if rackSlot.tint then
            SetWeaponObjectTintIndex(rackSlot.object, rackSlot.tint)
        end
        FreezeEntityPosition(rackSlot.object, true)
        SetEntityRotation(rackSlot.object, position.rot.x, position.rot.y, position.rot.z)
    end
end


local function fadeGun(rackId, slot, weaponType)
    local rack = Racks[rackId]
    if not rack then return end
    local object = rack[weaponType][slot].object
    if object then
        DeleteEntity(object)
    end
end

local function fadeGunRack(id)
    local rack = Racks[id]
    if DoesEntityExist(rack.object) then
        print("Fading Gun Rack")
        for i=1, #rack.rifles do
            local object = rack.rifles[i].object
            if object then
                DeleteEntity(object)
            end
        end
        for i=1, #rack.pistols do
            local object = rack.pistols[i].object
            if object then
                DeleteEntity(object)
            end
        end
        exports.ox_target:removeLocalEntity(rack.object)
        DeleteEntity(rack.object)
        rack.object = nil
        rack.isRendered = false
    end
end

local function displayPlayerWeapons(data)
    local registeredMenu = {
        id = 'StoreWeaponsMenu',
        title = Translations.GunRacks.storeWeapon.title,
        options = {},
        menu = "GunRackMenu"
    }
    local options = {}

    local items = ox_inventory:GetPlayerItems()
    for k, v in pairs(items) do
        if Config.RackableWeapons[v.name] then
            if Config.RackableWeapons[v.name].weaponType ~= 'ammo' then
                local metadata = {}
                for i=1, #v.metadata.components do
                    metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.component, value = ox_items[v.metadata.components[i]].label}
                end
                metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.ammo, value = v.metadata.ammo}
                metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.durability, value = v.metadata.durability..'%'}
                if v.metadata.serial then
                    metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.serial, value = v.metadata.serial}
                end
                options[#options+1] = {
                    title = string.format(Translations.GunRacks.storeGun.title, v.label),
                    icon = Translations.GunRacks.storeGun.icon,
                    iconColor = Translations.GunRacks.storeGun.iconColor,
                    arrow = Translations.GunRacks.storeGun.arrow,
                    onSelect = function()
                        storeWeapon(data.args.rack, v.slot, v.name)
                    end,
                    metadata = metadata,
                }
            else
                local ammoAmount = v.count
                options[#options+1] = {
                    title = string.format(Translations.GunRacks.storeAmmo.title, v.label),
                    description = string.format(Translations.GunRacks.storeAmmo.description, ammoAmount),
                    icon = Translations.GunRacks.storeAmmo.icon,
                    iconColor = Translations.GunRacks.storeAmmo.iconColor,
                    arrow = Translations.GunRacks.storeAmmo.arrow,
                    onSelect = function()
                        storeAmmo(data.args.rack, v.slot, v.name, ammoAmount)
                    end,
                }
            end
        end
    end

    if #options == 0 then
        options[#options+1] = {
            title = Translations.GunRacks.storeGun.noWeapons,
            disabled = true
        }
    end

    registeredMenu["options"] = options

    lib.registerContext(registeredMenu)
    lib.showContext('StoreWeaponsMenu')
end

local function takeRackWeapons(data)
    local rack = Racks[data.args.rack]
    local registeredMenu = {
        id = 'TakeWeaponsMenu',
        title = Translations.GunRacks.takeWeapon.title,
        options = {},
        menu = "GunRackMenu"
    }
    local options = {}

    for i=1, #rack.rifles do
        local item = rack.rifles[i]
        if item.name then
            local metadata = {}
            for i=1, #item.metadata.components do
                metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.component, value = ox_items[item.metadata.components[i]].label}
            end
            metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.ammo, value = item.metadata.ammo}
            metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.durability, value = item.metadata.durability ..'%'}
            if item.metadata.serial then
                metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.serial, value = item.metadata.serial}
            end
            options[#options+1] = {
                title = 'Take ' .. Config.RackableWeapons[item.name].label,
                icon = Translations.GunRacks.takeGun.icon,
                iconColor = Translations.GunRacks.takeGun.iconColor,
                arrow = Translations.GunRacks.takeGun.arrow,
                onSelect = function()
                    takeWeapon(data.args.rack, i, item.name)
                end,
                metadata = metadata,
            }
        end
    end

    for i=1, #rack.pistols do
        local item = rack.pistols[i]
        if item.name then
            local metadata = {}
            for i=1, #item.metadata.components do
                metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.component, value = ox_items[item.metadata.components[i]].label}
            end
            metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.ammo, value = item.metadata.ammo}
            metadata[#metadata+1] = {label = Translations.GunRacks.gunDetails.durability, value = item.metadata.durability ..'%'}
            options[#options+1] = {
                title = string.format(Translations.GunRacks.takeGun.title, Config.RackableWeapons[item.name].label),
                icon = Translations.GunRacks.takeGun.icon,
                iconColor = Translations.GunRacks.takeGun.iconColor,
                arrow = Translations.GunRacks.takeGun.arrow,
                onSelect = function()
                    takeWeapon(data.args.rack, i, item.name)
                end,
                metadata = metadata,
            }
        end
    end

    for i=1, #rack.ammo do
        local item = rack.ammo[i]
        for k, v in pairs(item) do
            print(k, v)
        end
        if item.name then
            options[#options+1] = {
                title = string.format("Take %s", Config.RackableWeapons[item.name].label),
                description = string.format("%.0f Rounds", item.count),
                icon = Translations.GunRacks.takeGun.icon,
                iconColor = Translations.GunRacks.takeGun.iconColor,
                arrow = Translations.GunRacks.takeGun.arrow,
                onSelect = function()
                    takeWeapon(data.args.rack, i, item.name)
                end,
            }
        end
    end

    if #options == 0 then
        options[#options+1] = {
            title = Translations.GunRacks.takeGun.noWeapons,
            disabled = true
        }
    end

    registeredMenu["options"] = options

    lib.registerContext(registeredMenu)
    lib.showContext('TakeWeaponsMenu')
end

local function destroyGunRack(data)
    local rack = data.args.rack
    local confirm = lib.alertDialog({
        header = 'Destroy the gun rack?',
        content = 'Are you sure that you want to destroy this build? You will lose all the contents.',
        centered = true,
        cancel = true
    })
    if confirm == 'cancel' then return end
    TriggerServerEvent('cb-gangsystem:server:destroyGunRack', rack)
end

local function CodeCorrect(code)
    if not code then return true end
    local input = lib.inputDialog( "Enter Passcode", {
        { type = 'input', password = true, label = "Passcode" , min = 1},
    })
    if not input then return end
    if input[1] ~= code then
        lib.notify({type = 'error', description = 'Invalid passcode'})
        return false
    end
    return true
end

local function AccessRack(rackId)
    local options = {
        {
            title = Translations.GunRacks.storeWeapon.title,
            description = Translations.GunRacks.storeWeapon.description,
            icon = Translations.GunRacks.storeWeapon.icon,
            iconColor = Translations.GunRacks.storeWeapon.iconColor,
            arrow = Translations.GunRacks.storeWeapon.arrow,
            distance = 1.5,
            onSelect = function()
                displayPlayerWeapons({args = {rack = rackId}})
            end,
        },
        {
            title = Translations.GunRacks.takeWeapon.title,
            description = Translations.GunRacks.takeWeapon.description,
            icon = Translations.GunRacks.takeWeapon.icon,
            iconColor = Translations.GunRacks.takeWeapon.iconColor,
            arrow = Translations.GunRacks.takeWeapon.arrow,
            distance = 1.5,
            onSelect = function()
                takeRackWeapons({args = {rack = rackId}})
            end,
        },
        {
            title = Translations.GunRacks.destroyRack.title,
            description = Translations.GunRacks.destroyRack.description,
            icon = Translations.GunRacks.destroyRack.icon,
            iconColor = Translations.GunRacks.destroyRack.iconColor,
            arrow = Translations.GunRacks.destroyRack.arrow,
            distance = 1.5,
            onSelect = function()
                destroyGunRack({args = {rack = rackId}})
            end,
        },
        {
            title = "Change Passcode",
            description = "Change the passcode for this gun rack",
            icon = "fa-solid fa-laptop-code",
            iconColor = "teal",
            arrow = true,
            distance = 1.5,
            onSelect = function()
                local oldCode = lib.inputDialog("Enter Current Passcode", {
                    { type = 'input', password = true, label = "Passcode" , min = 1},
                })
                if not oldCode then return end
                local newCode = lib.inputDialog("Enter New Passcode", {
                    { type = 'input', password = true, label = "Passcode" , min = 1},
                })
                if not newCode then return end
                TriggerServerEvent('cb-gangsystem:server:ChangePasscodeGunRack', rackId, oldCode[1], newCode[1])
            end,
        }
    }
    lib.registerContext({
        id = 'GunRackMenu',
        title = string.format(Translations.GunRacks.title, rackId),
        options = options,
    })
    lib.showContext('GunRackMenu')
end

local function ConfirmMoveRack(id)
    local confirm = lib.alertDialog({
        header = 'Move Gun Rack?',
        content = 'Are you sure that you want to move this gun rack?',
        centered = true,
        cancel = true
    })
    if confirm == 'cancel' then return end
    MoveRack(id)
end

local function spawnGunRack(id)
    local rack = Racks[id]
    lib.requestModel(rackModel)
    rack.object = CreateObject(rackModel, rack.coords.x, rack.coords.y, rack.coords.z, false, false, false)
    SetEntityHeading(rack.object, rack.coords.w)
    SetEntityAlpha(rack.object, 0)
    PlaceObjectOnGroundProperly(rack.object)
    FreezeEntityPosition(rack.object, true)
    SetModelAsNoLongerNeeded(rack.object)

    exports.ox_target:addLocalEntity(rack.object, {
        {
            label = 'Access Gunrack',
            name = 'gunrack:storeWeapon',
            icon = 'fa-solid fa-hand-holding',
            distance = 1.5,
            onSelect = function()
                if not CodeCorrect(Racks[id].code) then return end
                AccessRack(id)
            end,
        },
        {
            label = 'Move Gun Rack',
            name = 'gunrack:storeWeapon',
            icon = 'fa-solid fa-up-down-left-right',
            distance = 1.5,
            onSelect = function()
                ConfirmMoveRack(id)
            end,
        },
        {
            label = 'Crack Code',
            name = 'gunrack:storeWeapon',
            icon = 'fa-solid fa-laptop-code',
            distance = 1.5,
            onSelect = function()
                -- TODO: Crack Code Minigame, let the admins choose the minigame
            end,
            canInteract = function()
                if not Config.GunRacks.crackCode.enabled then return false end
                return HasItemClient(Config.GunRacks.crackCode.item, Config.GunRacks.crackCode.itemAmount)
            end,
        },
    })

    for i = 0, 255, 51 do
        Wait(50)
        SetEntityAlpha(rack.object, i, false)
    end
    rack.isRendered = true
    for i=1, #rack.rifles do
        if not rack.rifles[i].available then
            spawnGun(id, i, 'rifles')
        end
    end
    for i=1, #rack.pistols do
        if not rack.pistols[i].available then
            spawnGun(id, i, 'pistols')
        end
    end
end

local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestSweptSphere(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 0.2, 339, PlayerPedId(), 4))
	return b, c, e
end

function SpawnGunRacksForHideout(hideoutId)
    local PlayerData = GetPlayerData()
    if PlayerData == nil then return end
    local metadata = PlayerData.metadata
    if metadata == nil then return end
    local playerHideoutID = metadata['gangHideout']
    if playerHideoutID ~= nil and playerHideoutID ~= 0 and playerHideoutID == hideoutId then
        Racks = lib.callback.await('cb-gangsystem:server:getRacks', false)
        if hideoutId ~= nil or hideoutId ~= 0 then
            for k, rack in pairs(Racks) do
                if rack.hideout_id == hideoutId then
                    if not rack.isRendered or rack.isRendered == nil then
                        spawnGunRack(k)
                    end
                end
            end
        end
    end
end
exports('SpawnGunRacksForHideout', SpawnGunRacksForHideout)

function HideGunRacksForHideout(hideoutId)
    for k, rack in pairs(Racks) do
        print(rack.hideout_id == hideoutId)
        if rack.hideout_id == hideoutId then
            fadeGunRack(k)
        end
    end
end
exports('HideGunRacksForHideout', HideGunRacksForHideout)

function MoveRack(id)
    fadeGunRack(id)
    if PlacingObject then return end
    local playerCoords = GetEntityCoords(cache.ped)
    lib.requestModel(rackModel)
    tempRackObj = CreateObject(rackModel, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
    local heading = 0.0
    SetEntityHeading(tempRackObj, 0)
    
    SetEntityAlpha(tempRackObj, 225)
    SetEntityCollision(tempRackObj, false, false)
    -- SetEntityInvincible(tempRackObj, true)
    FreezeEntityPosition(tempRackObj, true)

    PlacingObject = true
    local rackCoords = nil
    local inRange = false

    local function deleteRack()
        PlacingObject = false
        SetEntityDrawOutline(tempRackObj, false)
        DeleteEntity(tempRackObj)
        tempRackObj = nil
        lib.hideTextUI()
    end

    lib.showTextUI(
        '**[Q/E]**   -   Rotate  \n' ..
        '**[ENTER]**   -   Place Gun Rack  \n' ..
        '**[X]**   -   Abandon  \n'
    )

    Notify("Tip", "If you have trouble placing the gun rack, try looking through your eyes.", "info", 5000)

    CreateThread(function()
        while PlacingObject do
            local hit, coords, entity = RayCastGamePlayCamera(20.0)
            rackCoords = coords
            DisableControlAction( 0, Keys["Q"], true ) -- cover
            DisableControlAction( 0, Keys["E"], true ) -- cover

            if hit then
                SetEntityCoords(tempRackObj, coords.x, coords.y, coords.z)
                PlaceObjectOnGroundProperly(tempRackObj)
                SetEntityDrawOutline(tempRackObj, true)
            end

            if #(rackCoords - GetEntityCoords(cache.ped)) < 2.0 then
                SetEntityDrawOutlineColor(2, 241, 181, 255)
                inRange = true
            else --not in range
                inRange = false
                SetEntityDrawOutlineColor(244, 68, 46, 255)
            end

            if IsControlPressed(0, Keys["X"]) then
                deleteRack()
                spawnGunRack(id)
                PlacingObject = false
            end
            
            if IsDisabledControlPressed(0, Keys["Q"]) then
                heading = heading + 2
                if heading > 360 then heading = 0.0 end
            end
    
            if IsDisabledControlPressed(0, Keys["E"]) then
                heading = heading - 2
                if heading < 0 then heading = 360.0 end
            end

            SetEntityHeading(tempRackObj, heading)
            if IsControlJustPressed(0, Keys["ENTER"]) then
                if not IsPedOnFoot(cache.ped) then
                    deleteRack()
                    spawnGunRack(id)
                    return
                end
                if not inRange then
                    deleteRack()
                    spawnGunRack(id)
                    return
                end
                local rackRot = GetEntityHeading(tempRackObj)
                local rackCoords = GetEntityCoords(tempRackObj)
                deleteRack()
                TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_HAMMERING", 0, true)
                if lib.progressBar({
                    duration = 1000, -- TODO: Make this a config
                    label = Translations.GunRacks.building,
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                }) then
                    ClearPedTasks(cache.ped)
                    TriggerServerEvent('cb-gangsystem:server:MoveGunRack', rackCoords, rackRot, id)
                else
                    ClearPedTasks(cache.ped)
                    spawnGunRack(id)
                end
            end
        Wait(0)
        end
    end)
end

local PlacingObject = false
RegisterNetEvent('cb-gangsystem:client:PlaceGunRack', function()
    if PlacingObject then return end
    local playerCoords = GetEntityCoords(cache.ped)
    lib.requestModel(rackModel)
    tempRackObj = CreateObject(rackModel, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
    local heading = 0.0
    SetEntityHeading(tempRackObj, 0)
    
    SetEntityAlpha(tempRackObj, 225)
    SetEntityCollision(tempRackObj, false, false)
    -- SetEntityInvincible(tempRackObj, true)
    FreezeEntityPosition(tempRackObj, true)

    PlacingObject = true
    local rackCoords = nil
    local inRange = false

    local function deleteRack()
        PlacingObject = false
        SetEntityDrawOutline(tempRackObj, false)
        DeleteEntity(tempRackObj)
        tempRackObj = nil
        lib.hideTextUI()
    end

    lib.showTextUI(
        '**[Q/E]**   -   Rotate  \n' ..
        '**[ENTER]**   -   Place Gun Rack  \n' ..
        '**[X]**   -   Abandon  \n'
    )

    Notify("Tip", "If you have trouble placing the gun rack, try looking through your eyes.", "info", 5000)

    CreateThread(function()
        while PlacingObject do
            local hit, coords, entity = RayCastGamePlayCamera(20.0)
            rackCoords = coords
            DisableControlAction( 0, Keys["Q"], true ) -- cover
            DisableControlAction( 0, Keys["E"], true ) -- cover

            if hit then
                SetEntityCoords(tempRackObj, coords.x, coords.y, coords.z)
                PlaceObjectOnGroundProperly(tempRackObj)
                SetEntityDrawOutline(tempRackObj, true)
            end

            if #(rackCoords - GetEntityCoords(cache.ped)) < 2.0 then
                SetEntityDrawOutlineColor(2, 241, 181, 255)
                inRange = true
            else --not in range
                inRange = false
                SetEntityDrawOutlineColor(244, 68, 46, 255)
            end

            if IsControlPressed(0, Keys["X"]) then
                deleteRack()
                PlacingObject = false
            end
            
            if IsDisabledControlPressed(0, Keys["Q"]) then
                heading = heading + 2
                if heading > 360 then heading = 0.0 end
            end
    
            if IsDisabledControlPressed(0, Keys["E"]) then
                heading = heading - 2
                if heading < 0 then heading = 360.0 end
            end

            SetEntityHeading(tempRackObj, heading)
            if IsControlJustPressed(0, Keys["ENTER"]) then
                if not IsPedOnFoot(cache.ped) then
                    deleteRack()
                    return
                end
                if not inRange then
                    deleteRack()
                    return
                end
                local rackRot = GetEntityHeading(tempRackObj)
                local rackCoords = GetEntityCoords(tempRackObj)
                deleteRack()
                local alert = lib.alertDialog({
                    header = 'Set Passcode?',
                    content = 'Would you like to set a passcode for this gun rack?',
                    centered = true,
                    cancel = true
                })
                local passcode = nil
                if alert == 'confirm' then
                    local input = lib.inputDialog( "Enter Passcode", {
                        { type = 'input', password = true, label = "Passcode" , min = 1},
                    })
                    if not input then
                        return
                    end
                    passcode = input[1]
                end
                if lib.progressBar({
                    duration = 1000, -- TODO: Make this a config
                    label = 'Building Gun Rack',
                    useWhileDead = false,
                    canCancel = true,
                    scenario = 'WORLD_HUMAN_HAMMERING',
                    disable = {
                        car = true,
                    },
                }) then
                    ClearPedTasks(cache.ped)
                    TriggerServerEvent('cb-gangsystem:server:PlaceGunRack', rackCoords, rackRot, passcode)
                else
                    ClearPedTasks(cache.ped)
                end
            end
        Wait(0)
        end
    end)
end)

RegisterNetEvent('cb-gangsystem:client:spawnGunRack', function(id, data)
    if source == '' then return end
    Racks[id] = data
    spawnGunRack(id)
end)

RegisterNetEvent('cb-gangsystem:client:fadeGunRack', function(id)
    fadeGunRack(id)
end)

RegisterNetEvent('cb-gangsystem:client:storeWeapon', function(rackIndex, rackSlot, rackType, data)
    if source == '' then return end
    Racks[rackIndex][rackType][rackSlot] = data
    spawnGun(rackIndex, rackSlot, rackType)
end)

RegisterNetEvent('cb-gangsystem:client:storeAmmo', function(rackIndex, rackSlot, rackType, data)
    if source == '' then return end
    Racks[rackIndex][rackType][rackSlot] = data
end)

RegisterNetEvent('cb-gangsystem:client:takeWeapon', function(rackIndex, rackSlot, rackType)
    if source == '' then return end
    fadeGun(rackIndex, rackSlot, rackType)
    Racks[rackIndex][rackType][rackSlot] = {name = nil, available = true}
end)

RegisterNetEvent('cb-gangsystem:client:destroyGunRack', function(id)
    if source == '' then return end
    local rack = Racks[id]
    if rack.isRendered then
        fadeGunRack(id)
    end
    Racks[id] = nil
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, v in pairs(Racks) do
        for _, v in pairs(v.rifles) do
            if v.object then
                DeleteEntity(v.object)
            end
        end
        for _, v in pairs(v.pistols) do
            if v.object then
                DeleteEntity(v.object)
            end
        end
        exports.ox_target:removeLocalEntity(v.object)
        DeleteEntity(v.object)
    end
    if tempRackObj then
        DeleteEntity(tempRackObj)
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    local PlayerData = GetPlayerData()
    if PlayerData == nil then return end
    local metadata = PlayerData.metadata
    if metadata == nil then return end
    local hideoutId = metadata['gangHideout']
    if hideoutId ~= nil and hideoutId ~= 0 then
        SpawnGunRacksForHideout(hideoutId)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    local PlayerData = GetPlayerData()
    if PlayerData == nil then return end
    local hideoutId = GetPlayerData().metadata['gangHideout']
    if hideoutId ~= nil and hideoutId ~= 0 then
        HideGunRacksForHideout(hideoutId)
    end
end)