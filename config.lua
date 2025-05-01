Config = {}

Config.GunRacks = { -- Gun Racks ONLY work with Ox Inventory. Do not enable this if you are using any other inventory system.
    enabled = true, -- Do you want to enable Gang Members to place and use Gun Racks inside their hideout? More about this in the documentation.
    crackCode = {
        enabled = true, -- Do you want to enable a crack code for Gun Racks? More about this in the documentation.
        item = "laptop", -- The item name of the crack item.
        itemAmount = 1, -- The amount of crack items needed to unlock the Gun Rack.
        minigame = function()
            -- TODO: Minigame stuff here
        end
    }
}

Config.RackableWeapons = {
    ['WEAPON_STUNGUN'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols', varModOverride = true},
    ['WEAPON_PISTOL'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_PISTOL_MK2'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_COMBATPISTOL'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_APPISTOL'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_PISTOL50'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_SNSPISTOL'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_SNSPISTOL_MK2'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_HEAVYPISTOL'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_VINTAGEPISTOL'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_MARKSMANPISTOL'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_REVOLVER'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_REVOLVER_MK2'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_DOUBLEACTION'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_MICROSMG'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_SMG'] = {offset = {z = 0.72}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_SMG_MK2'] = {offset = {z = 0.50}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_ASSAULTSMG'] = {offset = {z = 0.75}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_COMBATPDW'] = {offset = {z = 0.7}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_MACHINEPISTOL'] = {offset = {z = 1.36}, rotation = {x = 270.0, y = 1.0, z = 320.0}, weaponType = 'pistols'},
    ['WEAPON_MINISMG'] = {offset = {z = 0.50}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_ASSAULTRIFLE'] = {offset = {z = 0.65}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_ASSAULTRIFLE_MK2'] = {offset = {z = 0.75}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_CARBINERIFLE'] = {offset = {z = 0.60}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_CARBINERIFLE_MK2'] = {offset = {z = 0.68}, rotation = {z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_ADVANCEDRIFLE'] = {offset = {z = 0.77}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_SPECIALCARBINE'] = {offset = {z = 0.7}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_BULLPUPRIFLE'] = {offset = {z = 0.80}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_BULLPUPRIFLE_MK2'] = {offset = {z = 0.67}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_COMPACTRIFLE'] = {offset = {z = 0.5}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_MG'] = {offset = {z = 0.6}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_COMBATMG'] = {offset = {z = 0.7}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_COMBATMG_MK2'] = {offset = {z = 0.7}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_GUSENBERG'] = {offset = {z = 0.68}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_SNIPERRIFLE'] = {offset = {z = 0.72}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_HEAVYSNIPER'] = {offset = {z = 0.72}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_HEAVYSNIPER_MK2'] = {offset = {z = 0.72}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_MARKSMANRIFLE'] = {offset = {z = 0.72}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},
    ['WEAPON_MARKSMANRIFLE_MK2'] = {offset = {z = 0.72}, rotation = {y = -100.0, z = 90.0}, weaponType = 'rifles'},

    -- Ammo
    ['ammo-9'] = {weaponType = 'ammo'},
    ['ammo-45'] = {weaponType = 'ammo'},
    ['ammo-shotgun'] = {weaponType = 'ammo'},
}