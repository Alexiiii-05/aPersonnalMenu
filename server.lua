
local ESX = nil
ESX = exports["es_extended"]:getSharedObject()

local AllowedAdvantages = Config.Advantages.AllowedSteam

function GetPlayerSteam(source)
    for _, id in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, 6) == "steam:" then
            return id
        end
    end
    return nil
end

ESX.RegisterServerCallback('anf:hasAdvantagesAccess', function(source, cb)
    local steam = GetPlayerSteam(source)

    if not steam then
        cb(false)
        return
    end

    local allowed = (Config.Advantages and Config.Advantages.AllowedSteam) or {}
    cb(allowed[steam] == true)
end)

RegisterNetEvent('anf:showIdentityToPlayer')
AddEventHandler('anf:showIdentityToPlayer', function(target)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local identity = {
        firstname = xPlayer.get('firstName'),
        lastname  = xPlayer.get('lastName'),
        dateofbirth = xPlayer.get('dateofbirth'),
        sex = xPlayer.get('sex'),
        height = xPlayer.get('height')
    }
    TriggerClientEvent('anf:showIdentity', target, identity)
    TriggerClientEvent('anf:showArrow', -1, target)
end)

RegisterNetEvent('anf:showLicensesToPlayer')
AddEventHandler('anf:showLicensesToPlayer', function(target, licenses)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local identity = {
        firstname = xPlayer.get('firstName'),
        lastname = xPlayer.get('lastName')
    }

    TriggerClientEvent('anf:receiveLicenses', target, licenses, identity)
end)

ESX.RegisterServerCallback('anf:getPlayerLicenses', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()

    MySQL.query('SELECT type FROM user_licenses WHERE owner = ?', {
        identifier
    }, function(result)

        local licenses = {}

        for i = 1, #result do
            licenses[#licenses+1] = { type = result[i].type }
        end

        MySQL.query('SELECT ppa FROM users WHERE identifier = ?', {
            identifier
        }, function(result2)

            local ppa = result2[1] and result2[1].ppa

if ppa == 1 or ppa == true or ppa == "1" then
    licenses[#licenses+1] = { type = "ppa" }
end

            cb(licenses)
        end)
    end)
end)

RegisterNetEvent("anf:giveMoney")
AddEventHandler("anf:giveMoney", function(target, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(target)

    if not xPlayer or not xTarget then return end

    amount = tonumber(amount)
    if not amount or amount <= 0 then return end

    local distance = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target)))
    if distance > 3.0 then
        TriggerClientEvent("esx:showNotification", src, "~r~Trop loin du joueur")
        return
    end

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        xTarget.addMoney(amount)

        TriggerClientEvent('esx:setAccountMoney', src, {
            name = 'money',
            money = xPlayer.getMoney()
        })

        TriggerClientEvent('esx:setAccountMoney', target, {
            name = 'money',
            money = xTarget.getMoney()
        })

        TriggerClientEvent("esx:showNotification", src, "~g~Vous avez donné "..amount.."$")
        TriggerClientEvent("esx:showNotification", target, "~g~Vous avez reçu "..amount.."$")
    else
        TriggerClientEvent("esx:showNotification", src, "~r~Pas assez d'argent")
    end
end)

RegisterNetEvent('anf:giveWeapon')
AddEventHandler('anf:giveWeapon', function(target, weaponName, ammo)
    local source = source

    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)

    if not xPlayer or not xTarget then return end

    TriggerClientEvent('anf:removeWeapon', source, weaponName)

    xTarget.addWeapon(weaponName, ammo)

    TriggerClientEvent('esx:showNotification', source, "~g~Arme donnée avec succès.")
    TriggerClientEvent('esx:showNotification', target, "~g~Tu as reçu une arme par le joueur proche.")
end)