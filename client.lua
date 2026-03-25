local isMenuPersoOpen = false
local playerId = GetPlayerServerId(PlayerId())
local PlayerData = {}
local jobLabel = "Aucun"
local gradeLabel = "Aucun"
local bank = 0
local Bills = {}
local currentAnim = nil
local HasAdvantagesAccess = false
local pedIndex = 1
local savedSkin = nil
local isCustomPed = false
local showIdentityMarker = false
local savedClothes = {}
local savedProps = {}
local selectedColorIndex = 1
local arrowIndex = 1
local arrowColors = {"~r~",  "~o~",  "~y~",  "~g~",  "~c~",  "~b~",  "~p~",  "~m~",  "~w~",}

ESX = nil
Citizen.CreateThread(function() while ESX == nil do ESX = exports["es_extended"]:getSharedObject() Wait(50) end while ESX.GetPlayerData().job == nil do Wait(50) end PlayerData = ESX.GetPlayerData() end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    RefreshPlayerMoney()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

CreateThread(function()
    while true do
        arrowIndex = arrowIndex + 1
        if arrowIndex > #arrowColors then arrowIndex = 1 end
        Wait(500)
    end
end)

function AnimatedArrow()
    return arrowColors[arrowIndex]
end

function KeyboardInput(text, example, max)
    AddTextEntry("FMMC_KEY_TIP1", text)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", example or "", "", "", "", max or 64)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    if UpdateOnscreenKeyboard() == 1 then
        local result = GetOnscreenKeyboardResult()
        return result
    end
    return nil
end

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    local playerData = ESX.GetPlayerData()
    if not playerData.accounts then return end

    for i = 1, #playerData.accounts do
        if playerData.accounts[i].name == account.name then
            playerData.accounts[i].money = account.money
            break
        end
    end

    RefreshPlayerMoney()
end)

function RefreshBills()
    ESX.TriggerServerCallback('esx_billing:getBills', function(bills)
        Bills = bills or {}
    end)
end

function GetPlayerLicenses(cb)
    ESX.TriggerServerCallback('esx_license:getLicenses', function(licenses)
        cb(licenses)
    end)
end

function FormatLicenses(licenses)
    if not licenses then
        return "~r~Erreur : aucune donnée"
    end

    if #licenses == 0 then
        return "~r~Aucun permis enregistré"
    end

    local text = ""

    for _, lic in pairs(licenses) do
        text = text .. "• " .. tostring(lic.type) .. "\n"
    end

    return text
end


-- function ShowLicensesToPlayer()
--     local closestPlayer, distance = ESX.Game.GetClosestPlayer()

--     if closestPlayer == -1 or distance > 3.0 then
--         ESX.ShowNotification("~r~Aucun joueur à proximité")
--         return
--     end

--     ESX.TriggerServerCallback('anf:getPlayerLicenses', function(licenses)
--         TriggerServerEvent('anf:showLicensesToPlayer',GetPlayerServerId(closestPlayer),licenses)
--     end)
-- end

RegisterNetEvent('anf:receiveLicenses')
AddEventHandler('anf:receiveLicenses', function(licenses, identity)
    local firstname = identity.firstname or "Inconnu"
    local lastname = identity.lastname or "Inconnu"
    local labels = {drive = "Permis voiture",drive_bike = "Permis moto",drive_truck = "Permis camion",ppa = "Permis port d'arme"}
    local text = ""
    for _, lic in pairs(licenses) do
        local label = labels[lic.type] or lic.type
        text = text ..
        "📄 Type : " .. label ..
        "\n🟢 Validité : BON\n\n"
    end
    ESX.ShowAdvancedNotification("Permis",firstname .. " " .. lastname,text,"CHAR_DEFAULT",1)
end)

function RefreshPlayerMoney()
    blackMoney = 0
    cashMoney = 0
    bankMoney = 0

    local playerData = ESX.GetPlayerData()

    if playerData.accounts then
        for _, account in pairs(playerData.accounts) do
            if account.name == 'money' then
                cashMoney = account.money
            elseif account.name == 'black_money' then
                blackMoney = account.money
            elseif account.name == 'bank' then
                bankMoney = account.money
            end
        end
    end
end

function ChangePlayerPed(model)
    if not savedSkin then
        SaveCurrentSkin()
    end

    local modelHash = GetHashKey(model)
    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)

    isCustomPed = true
    ESX.ShowNotification("~g~Ped changé")
end
function ChangeVehiclePlateCustom()
    local ped = PlayerPedId()
    local vehiclevip = GetVehiclePedIsIn(ped, false)

    if vehiclevip == 0 then
        ESX.ShowNotification("~r~Vous devez être dans un véhicule")
        return
    end

    local plate = KeyboardInput("Nouvelle plaque", "", 8)
    if not plate or plate == "" then return end

    plate = string.upper(plate)

    SetVehicleNumberPlateText(vehiclevip, plate)
    ESX.ShowNotification("~g~Plaque changée : ~w~" .. plate)
end

function SaveCurrentSkin(cb)
    TriggerEvent('skinchanger:getSkin', function(skin)
        savedSkin = skin
        if cb then cb() end
    end)
end

function RestoreOriginalSkin()
    if not savedSkin then
        ESX.ShowNotification("~r~Aucun skin sauvegardé")
        return
    end
    local model = savedSkin.sex == 0 and "mp_m_freemode_01" or "mp_f_freemode_01"
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end
    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)
    Wait(100)
    TriggerEvent('skinchanger:loadSkin', savedSkin)
    isCustomPed = false
    ESX.ShowNotification("~g~Skin original restauré")
end
function GetClosestVehiclePlayer()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
    return vehicle
end

function ShowIdentityCard(data)
    local ped = PlayerPedId()
    local mugshot = RegisterPedheadshot(ped)

    while not IsPedheadshotReady(mugshot) do
        Wait(0)
    end

    local mugshotTexture = GetPedheadshotTxdString(mugshot)

    local firstname = data and data.firstname or PlayerData.firstName
    local lastname = data and data.lastname or PlayerData.lastName
    local dob = data and data.dateofbirth or PlayerData.dateofbirth
    local sex = data and data.sex or PlayerData.sex
    local height = data and data.height or PlayerData.height
    ESX.ShowAdvancedNotification("Carte d'identité",firstname .. " " .. lastname,"📅 Naissance : " .. dob .."\n🚻 Sexe : " .. (sex == 'm' and "Homme" or "Femme") .."\n📏 Taille : " .. height .. " cm",mugshotTexture,1)
    UnregisterPedheadshot(mugshot)
end

function LoadPlayerClothes()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end

function ToggleClothe(component, emptyDrawable, textureKey)
    TriggerEvent('skinchanger:getSkin', function(skin)

        local clothes = {}
        if not savedClothes[component] then
            savedClothes[component] = {drawable = skin[component],texture = skin[textureKey]}
        end
        if skin[component] == emptyDrawable then
            clothes[component] = savedClothes[component].drawable
            clothes[textureKey] = savedClothes[component].texture
            savedClothes[component] = nil
        else
            clothes[component] = emptyDrawable
            clothes[textureKey] = 0
        end
        TriggerEvent('skinchanger:loadClothes', skin, clothes)
    end)
end

function ToggleProp(prop, indexKey, textureKey)
    TriggerEvent('skinchanger:getSkin', function(skin)
        if not savedProps[prop] then
            savedProps[prop] = {index = skin[indexKey],texture = skin[textureKey]}
        end
        if skin[indexKey] == -1 then
            TriggerEvent('skinchanger:loadClothes', skin, {[indexKey] = savedProps[prop].index,[textureKey] = savedProps[prop].texture})
            savedProps[prop] = nil
        else
            TriggerEvent('skinchanger:loadClothes', skin, {[indexKey] = -1})
        end
    end)
end

function PlayClotheAnim(dict, anim, time)
    local ped = PlayerPedId()
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, time or 1500, 48, 0, false, false, false)
    Wait(time or 1500)
    ClearPedTasks(ped)
end

function ToggleMask()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local clothes = {}
        if not savedClothes["mask"] then
            savedClothes["mask"] = {drawable = skin.mask_1,texture = skin.mask_2}
        end
        if skin.mask_1 == 0 then
            clothes["mask_1"] = savedClothes["mask"].drawable
            clothes["mask_2"] = savedClothes["mask"].texture
            savedClothes["mask"] = nil
        else
            clothes["mask_1"] = 0
            clothes["mask_2"] = 0
        end
        TriggerEvent('skinchanger:loadClothes', skin, clothes)
    end)
end

function ToggleRPAnim(dict, anim)
    local ped = PlayerPedId()
    if currentAnim == dict .. anim then
        ClearPedTasksImmediately(ped)
        currentAnim = nil
        return
    end
    ClearPedTasksImmediately(ped)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    TaskPlayAnim(ped,dict,anim,8.0,-8.0,-1,49,0,false,false,false)
    currentAnim = dict .. anim
end

function ToggleScenario(scenario)
    local ped = PlayerPedId()
    if currentAnim == scenario then
        ClearPedTasksImmediately(ped)
        currentAnim = nil
        return
    end
    ClearPedTasksImmediately(ped)
    TaskStartScenarioInPlace(ped, scenario, 0, true)
    currentAnim = scenario
end

function IsAnimActive(animKey)
    return currentAnim == animKey
end

RMenu.Add('personnal', 'main', RageUI.CreateMenu("Personnel", "Menu personnel"))
RMenu:Get('personnal', 'main'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu', 'inventory', RageUI.CreateSubMenu(RMenu:Get('personnal', 'main'), "Inventaire", "Votre inventaire"))
RMenu:Get('personnalmenu', 'inventory'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu', 'portefeuille', RageUI.CreateSubMenu(RMenu:Get('personnal', 'main'), "Portefeuille", "Interaction"))
RMenu:Get('personnalmenu', 'portefeuille'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu', 'bills_pay', RageUI.CreateSubMenu(RMenu:Get('personnalmenu', 'portefeuille'),"Factures","Vos factures en attente"))
RMenu:Get('personnalmenu', 'bills_pay'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu', 'inventory_actions', RageUI.CreateSubMenu(RMenu:Get('personnalmenu', 'inventory'),"Objet","Actions disponibles"))
RMenu:Get('personnalmenu', 'inventory_actions'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu', 'managevehicle', RageUI.CreateSubMenu(RMenu:Get('personnal', 'main'), "Gestion", "Gestion vehicule"))
RMenu:Get('personnalmenu', 'managevehicle'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu','clothes',RageUI.CreateSubMenu(RMenu:Get('personnal', 'main'),"Vêtements","Gestion de votre tenue"))
RMenu:Get('personnalmenu', 'clothes'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu','divers',RageUI.CreateSubMenu(RMenu:Get('personnal', 'main'),"Divers","Options diverses"))
RMenu:Get('personnalmenu', 'divers'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu','avantages',RageUI.CreateSubMenu(RMenu:Get('personnal', 'main'),"Avantages","Listes d'avantages"))
RMenu:Get('personnalmenu', 'avantages'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu', 'licenses_show', RageUI.CreateSubMenu(RMenu:Get('personnalmenu', 'portefeuille'), "Permis", "Montrer un permis"))
RMenu:Get('personnalmenu', 'licenses_show'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu', 'licenses_watch', RageUI.CreateSubMenu(RMenu:Get('personnalmenu', 'portefeuille'), "Mes permis", "Consulter mes permis"))
RMenu:Get('personnalmenu', 'licenses_watch'):SetRectangleBanner(255, 218, 0, 200) 
RMenu.Add('personnalmenu', 'weapons', RageUI.CreateSubMenu(RMenu:Get('personnalmenu', 'inventory'), "Armes", "Vos armes"))
RMenu:Get('personnalmenu', 'weapons'):SetRectangleBanner(255, 218, 0, 200)
RMenu.Add('personnalmenu', 'weapon_actions', RageUI.CreateSubMenu(RMenu:Get('personnalmenu', 'weapons'), "Arme", "Actions"))
RMenu:Get('personnalmenu', 'weapon_actions'):SetRectangleBanner(255, 218, 0, 200)

function OpenPersonnalMenu()
    if isMenuPersoOpen then
        isMenuPersoOpen = false
        
        RageUI.Visible(RMenu:Get('personnal', 'main'), false)
        return
    else
        isMenuPersoOpen = true
        RefreshPlayerMoney()
        ESX.TriggerServerCallback('anf:hasAdvantagesAccess', function(hasAccess)
            HasAdvantagesAccess = hasAccess
        end)
        RageUI.Visible(RMenu:Get('personnal', 'main'), true)
        CreateThread(function()
            while isMenuPersoOpen do
                RageUI.IsVisible(RMenu:Get('personnal', 'main'), function()
                    RageUI.Separator("Votre id : [ ~b~" .. playerId .. "~s~ ]")
                    RageUI.Button(AnimatedArrow().."→ ~s~Inventaire", nil, {RightLabel = "→→"}, true, {}, RMenu:Get('personnalmenu', 'inventory'))
                        RageUI.Button(AnimatedArrow().."→ ~s~Portefeuille", nil, {RightLabel = "→→"}, true, {onSelected = function()end}, RMenu:Get('personnalmenu', 'portefeuille'))
                        RageUI.Button(AnimatedArrow().."→ ~s~Vêtements", nil, {RightLabel = "→→"}, true, {onSelected = function()end}, RMenu:Get('personnalmenu', 'clothes'))
                        RageUI.Button(AnimatedArrow().."→ ~s~Divers", nil, {RightLabel = "→→"}, true, {onSelected = function()end}, RMenu:Get('personnalmenu', 'divers'))
                        RageUI.Button(AnimatedArrow().."→ ~s~Gestion du véhicule", nil, {RightLabel = "→→"}, true, {onSelected = function() end},RMenu:Get('personnalmenu', 'managevehicle'))
                        RageUI.Button(AnimatedArrow().."→ ~s~Avantages","Accès réservé",{ RightLabel = HasAdvantagesAccess and "→→" or"~r~Bloqué" },HasAdvantagesAccess, {
                                onSelected = function()
                                  RageUI.Visible(RMenu:Get('personnalmenu', 'avantages'), true)
                                end
                            }
                        )
                        local isAdmin = true 

                        RageUI.Button(AnimatedArrow().."→ ~s~Administration", nil, {RightLabel = "→→"}, isAdmin, {
                            onSelected = function()
                                OpenAdminMenu()
                            end
                        })
                    end)

RageUI.IsVisible(RMenu:Get('personnalmenu', 'inventory'), function()
    local playerData = ESX.GetPlayerData()
    local inventory = playerData.inventory or {}

    -- Accès aux armes
    RageUI.Button("Armes", nil, {RightLabel = AnimatedArrow().."→→"}, true, {}, RMenu:Get('personnalmenu', 'weapons'))

    -- Poids
    RageUI.Separator("📦 Poids : ~b~" .. (playerData.weight or 0) .. " / " .. (playerData.maxWeight or 0) .. " kg")

    -- Items
    for _, v in pairs(inventory) do
        if v and v.count and v.count > 0 then
            RageUI.Button(
                AnimatedArrow().."→ ~s~"..(v.label or v.name).." (x~o~"..v.count.."~s~)",
                nil,
                {RightLabel = "→→"},
                true,
                {
                    onSelected = function()
                        SelectedItem = v
                    end
                },
                RMenu:Get('personnalmenu', 'inventory_actions')
            )
        end
    end
end)

        RageUI.IsVisible(RMenu:Get('personnalmenu', 'weapons'), function()
            local ped = PlayerPedId()

            RageUI.Separator("↓ ~r~Vos armes~s~ ↓")

            local hasWeapon = false
            local selectedWeaponHash = GetSelectedPedWeapon(ped)

            for _, weapon in pairs(PlayerData.loadout or {}) do
                local weaponHash = GetHashKey(weapon.name)

                if HasPedGotWeapon(ped, weaponHash, false) then
                    hasWeapon = true

                    local label = weapon.label or weapon.name
                    local ammo = GetAmmoInPedWeapon(ped, weaponHash)

                    if weaponHash == selectedWeaponHash then
                        RageUI.Button("→ "..label.." (~b~"..ammo.." munitions~s~)", "~g~Équipée", {RightLabel = "→→"}, true, {
                            onSelected = function()
                                SelectedWeapon = weapon.name
                                RageUI.Visible(RMenu:Get('personnalmenu', 'weapon_actions'), true)
                            end
                        })
                    else
                        RageUI.Button("→ "..label, "~c~Non équipée", {RightLabel = "→→"}, true, {
                            onSelected = function()
                                SelectedWeapon = weapon.name
                                RageUI.Visible(RMenu:Get('personnalmenu', 'weapon_actions'), true)
                            end
                        })
                    end
                end
            end

            if not hasWeapon then
                RageUI.Separator(AnimatedArrow().."Aucune arme")
            end
        end)

        RageUI.IsVisible(RMenu:Get('personnalmenu', 'weapon_actions'), function()

            if not SelectedWeapon then
                RageUI.Separator("Chargement...")
                return
            end

            RageUI.Separator(AnimatedArrow().."→ ~s~Arme sélectionné")

        RageUI.Button("Donner l'arme", nil, {RightLabel = "→→"}, true, {
            onSelected = function()
                local ped = PlayerPedId()
                local weaponHash = GetHashKey(SelectedWeapon)
                local ammo = GetAmmoInPedWeapon(ped, weaponHash)
                local closestPlayer, distance = ESX.Game.GetClosestPlayer()
                --print("Closest:", closestPlayer, "Distance:", distance)
                if closestPlayer == -1 then
                    ESX.ShowNotification("~r~Aucun joueur trouvé")
                    return
                end

                if distance > 3.0 then
                    ESX.ShowNotification("~r~Aucun joueur trouvé/pas assez proche.")
                    return
                end
                TriggerServerEvent('anf:giveWeapon', GetPlayerServerId(closestPlayer), SelectedWeapon, ammo)
                RageUI.CloseAll()
            end
        })

        end)


                    RageUI.IsVisible(RMenu:Get('personnalmenu', 'portefeuille'), function()

                    local playerData = ESX.GetPlayerData()

                    local cashMoney = 0
                    local blackMoney = 0
                    local bankMoney = 0

                    for _, account in pairs(playerData.accounts) do
                        if account.name == 'money' then
                            cashMoney = account.money
                        elseif account.name == 'black_money' then
                            blackMoney = account.money
                        elseif account.name == 'bank' then
                            bankMoney = account.money
                        end
                    end
                        showIdentityMarker = false

                        RageUI.Button("→ Factures", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                RefreshBills()
                            end
                        },RMenu:Get('personnalmenu', 'bills_pay'))
                        RageUI.Separator(AnimatedArrow().."↓~s~ Vos papiers "..AnimatedArrow().."↓")
                        RageUI.Button(AnimatedArrow().."→ ~s~Regarder sa carte d'identité", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                ShowIdentityCard()
                            end
                        })

                        
                    RageUI.Button(AnimatedArrow().."→ ~s~Montrer sa carte d'identité", nil, {RightLabel = "→→"}, true, {

                    onActive = function()
                        local closestPlayer, distance = ESX.Game.GetClosestPlayer()

                        if closestPlayer ~= -1 and distance <= 3.0 then
                            local ped = GetPlayerPed(closestPlayer)

                            if DoesEntityExist(ped) then
                                local coords = GetEntityCoords(ped)

                                DrawMarker(2,coords.x, coords.y, coords.z + 1.2,0.0, 0.0, 0.0, 0.0, 0.0, 0.0,0.3, 0.3, 0.3,0, 150, 255, 200,false, true, 2, false, nil, nil, false)
                            end
                        end
                    end,

                    onSelected = function()
                        local closestPlayer, distance = ESX.Game.GetClosestPlayer()

                        if closestPlayer ~= -1 and distance <= 3.0 then
                            TriggerServerEvent('anf:showIdentityToPlayer', GetPlayerServerId(closestPlayer))
                        else
                            ESX.ShowNotification("~r~Aucun joueur à proximité")
                        end
                    end
                })
                    RageUI.Button(AnimatedArrow().."→ ~s~Regarder ses permis", nil, {RightLabel = "→→"}, true, {}, RMenu:Get('personnalmenu', 'licenses_watch'))

                    RageUI.Button(AnimatedArrow().."→ ~s~Montrer ses permis", nil, {RightLabel = "→→"}, true, {

                        onActive = function()
                            local closestPlayer, distance = ESX.Game.GetClosestPlayer()

                            if closestPlayer ~= -1 and distance <= 3.0 then
                                local ped = GetPlayerPed(closestPlayer)

                                if DoesEntityExist(ped) then
                                    local coords = GetEntityCoords(ped)

                                    DrawMarker(2, coords.x, coords.y, coords.z + 1.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 150, 255, 200, false, true, 2, false, nil, nil, false)
                                end
                            end
                        end,

                        onSelected = function()
                            RageUI.Visible(RMenu:Get('personnalmenu', 'licenses_show'), true)
                        end

                        })

                    if PlayerData and PlayerData.job then
                        jobLabel = PlayerData.job.label or "Aucun"
                        gradeLabel = PlayerData.job.grade_label or "Aucun"
                    end

                    RageUI.Separator("Métier : [ ~b~" .. jobLabel.."~s~ ]")
                    RageUI.Separator("Grade : [ ~o~" .. gradeLabel.."~s~ ]")
                    RageUI.Separator(AnimatedArrow().."↓~s~ Finances "..AnimatedArrow().."↓")
                
                    indexCash = indexCash or 1

                    local playerData = ESX.GetPlayerData()
                    local cashMoney = 0

                    for _, account in pairs(playerData.accounts) do
                        if account.name == 'money' then
                            cashMoney = account.money
                        end
                    end

                    RageUI.List("Argent liquide : ~g~" .. ESX.Math.GroupDigits(cashMoney) .. "$",{ "Donner" },indexCash,nil,{},true,{
                            onListChange = function(i)
                                indexCash = i
                            end,
                            onSelected = function()
                                local amount = tonumber(KeyboardInput("Montant", "", 6))
                                if not amount or amount <= 0 then
                                    ESX.ShowNotification("~r~Montant invalide")
                                    return
                                end
                                if indexCash == 1 then
                                    local closestPlayer, distance = ESX.Game.GetClosestPlayer()
                                    if closestPlayer ~= -1 and distance <= 3.0 then
                                        TriggerServerEvent('anf:giveMoney', GetPlayerServerId(closestPlayer), amount)
                                    else
                                        ESX.ShowNotification("~r~Aucun joueur à proximité")
                                    end
                                end
                            end
                        }
                    )
                    indexBlack = indexBlack or 1

                    RageUI.List("Argent non déclaré : ~r~" .. ESX.Math.GroupDigits(blackMoney or 0) .. "$",{ "Donner" },indexBlack,nil,{},true,{
                            onListChange = function(i)
                                indexBlack = i
                            end,
                            onSelected = function()
                                local amount = tonumber(KeyboardInput("Montant", "", 6))
                                if not amount or amount <= 0 then
                                    ESX.ShowNotification("~r~Montant invalide")
                                    return
                                end

                                if indexBlack == 1 then
                                    local closestPlayer, distance = ESX.Game.GetClosestPlayer()
                                    if closestPlayer ~= -1 and distance <= 3.0 then
                                        TriggerServerEvent('esx:giveInventoryItem',GetPlayerServerId(closestPlayer),'item_account','black_money',amount)
                                    else
                                        ESX.ShowNotification("~r~Aucun joueur à proximité")
                                    end
                                end
                            end
                        }
                    )
                                            
                        for k,v in pairs(PlayerData.accounts) do
                            if v.name == 'bank' then
                                bank = v.money
                            end
                        end
                        RageUI.Button("Argent en banque~b~ : ".. ESX.Math.GroupDigits(bank or 0) .. " $",nil,{},false,{})
                end)

                 RageUI.IsVisible(RMenu:Get('personnalmenu', 'managevehicle'), function()
                        local ped = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        if vehicle ~= 0 then
                            RageUI.Separator("~g~Véhicule détecté")
                        else
                            RageUI.Separator("~r~Aucun véhicule")
                        end

                        RageUI.Button(AnimatedArrow().."→ ~s~Verrouiller / Déverrouiller",nil,{},vehicle ~= 0,{
                                onSelected = function()
                                    local lockStatus = GetVehicleDoorLockStatus(vehicle)

                                    if lockStatus == 1 or lockStatus == 0 then
                                        SetVehicleDoorsLocked(vehicle, 2)
                                        ESX.ShowNotification("~r~Véhicule verrouillé")
                                    else
                                        SetVehicleDoorsLocked(vehicle, 1)
                                        ESX.ShowNotification("~g~Véhicule déverrouillé")
                                    end

                                    SetVehicleLights(vehicle, 2)
                                    Wait(150)
                                    SetVehicleLights(vehicle, 0)
                                end
                            }
                        )

                        RageUI.Button(AnimatedArrow().."→ ~s~Moteur ON / OFF",nil,{},vehicle ~= 0,{
                                onSelected = function()
                                    local engine = GetIsVehicleEngineRunning(vehicle)
                                    SetVehicleEngineOn(vehicle, not engine, false, true)
                                    if engine then
                                        ESX.ShowNotification("~r~Moteur éteint")
                                    else
                                        ESX.ShowNotification("~g~Moteur allumé")
                                    end
                                end
                            }
                        )
                 end)

                 RageUI.IsVisible(RMenu:Get('personnalmenu', 'clothes'), function()
                    
                    RageUI.Separator("↓ Options ↓")

                    RageUI.Button(AnimatedArrow().."→ ~s~Remettre ma tenue", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, {
                        onSelected = function()
                            PlayClotheAnim("clothingtie", "try_tie_positive_a", 1500)
                            LoadPlayerClothes()
                            ESX.ShowNotification("~g~Tenue restaurée")
                        end
                    })

                    RageUI.Separator("↓ Vos vêtements ↓")

                    RageUI.Button(AnimatedArrow().."→ ~s~Haut", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, {
                        onSelected = function()
                            PlayClotheAnim("clothingtie", "try_tie_positive_a", 1500)
                            ToggleClothe('torso_1', 15, 'torso_2')
                        end
                    })
                    RageUI.Button(AnimatedArrow().."→ ~s~T-shirt", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, {
                    onSelected = function()
                        PlayClotheAnim("clothingtie", "try_tie_negative_a", 1500)
                        ToggleClothe('tshirt_1', 15, 'tshirt_2')
                    end
                    })

                    RageUI.Button(AnimatedArrow().."→ ~s~Pantalon", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, {
                        onSelected = function()
                            PlayClotheAnim("clothingtrousers", "try_trousers_neutral_a", 1500)
                            ToggleClothe('pants_1', 14, 'pants_2')
                        end
                    })

                    RageUI.Button(AnimatedArrow().."→ ~s~Chaussures", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, {
                        onSelected = function()
                            PlayClotheAnim("clothingshoes", "try_shoes_positive_a", 1500)
                            ToggleClothe('shoes_1', 34, 'shoes_2')
                        end
                    })

                    RageUI.Button(AnimatedArrow().."→ ~s~Sac", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, {
                        onSelected = function()
                            PlayClotheAnim("anim@heists@ornate_bank@grab_cash", "intro", 1200)
                            ToggleClothe('bags_1', 0, 'bags_2')
                        end
                    })

                        

                    RageUI.Button(AnimatedArrow().."→ ~s~Chapeau", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, {
                    onSelected = function()
                        PlayClotheAnim("missheist_agency2ahelmet", "take_off_helmet_stand", 1200)
                        ToggleProp("helmet", "helmet_1", "helmet_2")
                    end
                    })

                    RageUI.Button(AnimatedArrow().."→ ~s~Lunettes", nil, {RightBadge = RageUI.BadgeStyle.Clothes}, true, {
                    onSelected = function()
                        PlayClotheAnim("clothingspecs", "try_glasses_positive_a", 1200)
                        ToggleProp("glasses", "glasses_1", "glasses_2")
                    end
                    })

                    RageUI.Button(AnimatedArrow().."→ ~s~Masque", nil, {RightBadge = RageUI.BadgeStyle.Mask}, true, {
                    onSelected = function()
                        PlayClotheAnim("missfbi4", "takeoff_mask", 1200)
                        ToggleMask()
                    end
                    })
                 end)


                RageUI.IsVisible(RMenu:Get('personnalmenu', 'licenses_watch'), function()

                        RageUI.Button("→ Permis voiture", nil, {}, true, {
                            onSelected = function()
                                ShowMyLicense("drive")
                            end
                        })

                        RageUI.Button("→ Permis moto", nil, {}, true, {
                            onSelected = function()
                                ShowMyLicense("drive_bike")
                            end
                        })

                        RageUI.Button("→ Permis camion", nil, {}, true, {
                            onSelected = function()
                                ShowMyLicense("drive_truck")
                            end
                        })

                        RageUI.Button("→ Permis PPA", nil, {}, true, {
                            onSelected = function()
                                ShowMyLicense("ppa")
                            end
                        })

                    end)

                 RageUI.IsVisible(RMenu:Get('personnalmenu', 'licenses_show'), function()


                        RageUI.Button("→ Permis voiture", nil, {}, true, {
                            onSelected = function()
                                ShowSpecificLicense("drive")
                            end
                        })

                        RageUI.Button("→ Permis moto", nil, {}, true, {
                            onSelected = function()
                                ShowSpecificLicense("drive_bike")
                            end
                        })

                        RageUI.Button("→ Permis camion", nil, {}, true, {
                            onSelected = function()
                                ShowSpecificLicense("drive_truck")
                            end
                        })

                        RageUI.Button("→ Permis PPA", nil, {}, true, {
                            onSelected = function()
                                ShowSpecificLicense("ppa")
                            end
                        })

                    end)


                 RageUI.IsVisible(RMenu:Get('personnalmenu', 'divers'), function()

                        RageUI.Separator(AnimatedArrow().."↓ ~s~Actions RP "..AnimatedArrow().."↓")

                    RageUI.Button(AnimatedArrow().."→ ~s~Lever les mains",nil,{ RightLabel = IsAnimActive("missminuteman_1ig_2handsup_base") and "~g~ACTIF" or nil },true,{
                            onSelected = function()
                                ToggleRPAnim("missminuteman_1ig_2", "handsup_base")
                            end
                        }
                    )
                    RageUI.Button(AnimatedArrow().."→ ~s~Tomber inconscient", nil, {}, true, {
                        onSelected = function()
                            SetPedToRagdoll(PlayerPedId(), 5000, 5000, 0, false, false, false)
                        end
                    })

                        RageUI.Separator(AnimatedArrow().."↓ ~s~Animations "..AnimatedArrow().."↓")

                    RageUI.Button(AnimatedArrow().."→ ~s~Fumer",nil,{RightLabel = IsAnimActive("WORLD_HUMAN_SMOKING") and "~g~ACTIF" or nil},true,{
                        onSelected = function()
                            ToggleScenario("WORLD_HUMAN_SMOKING")
                        end
                    })

                    RageUI.Button(AnimatedArrow().."→ ~s~Téléphone",nil,{RightLabel = IsAnimActive("WORLD_HUMAN_STAND_MOBILE") and "~g~ACTIF" or nil},true,{
                        onSelected = function()
                            ToggleScenario("WORLD_HUMAN_STAND_MOBILE")
                        end
                    })

                    RageUI.Button(AnimatedArrow().."→ ~s~Bras croisés",nil,{RightLabel = IsAnimActive("amb@world_human_hang_out_street@female_arms_crossed@base|base") and "~g~ACTIF" or nil},true,{
                        onSelected = function()
                            ToggleRPAnim("amb@world_human_hang_out_street@female_arms_crossed@base","base")
                        end
                    })
                 end)

                 RageUI.IsVisible(RMenu:Get('personnalmenu', 'avantages'), function()

                    if not HasAdvantagesAccess then
                        RageUI.Separator("~r~Accès refusé")
                        return
                    end

                    RageUI.Separator("~y~Avantages spéciaux")

                    RageUI.List(AnimatedArrow().."→ ~s~Changer de ped",(function()
                            local labels = {}
                            for i = 1, #Config.pedList do
                                labels[i] = Config.pedList[i].label
                            end
                            return labels
                        end)(),
                        pedIndex,
                        nil,
                        {},
                        true,
                        {
                            onListChange = function(index)
                                pedIndex = index
                            end,
                            onSelected = function()
                                ChangePlayerPed(Config.pedList[pedIndex].model)
                            end
                        })


                    RageUI.Button(AnimatedArrow().."→ ~s~Reprendre son skin","Retour à votre apparence originale",{},isCustomPed,{
                        onSelected = function()
                            RestoreOriginalSkin()
                        end
                    })

                    RageUI.Separator("~y~Véhicule")


                    RageUI.Button(AnimatedArrow().."→ ~s~Changer la plaque","Définir une plaque personnalisée",{ RightLabel ="" },GetVehiclePedIsIn(PlayerPedId(), false) ~= 0,{
                        onSelected = function()
                            ChangeVehiclePlateCustom()
                        end
                    })
                 end)

                RageUI.IsVisible(RMenu:Get('personnalmenu', 'bills_pay'), function()
                    
                            if #Bills == 0 then
                                RageUI.Separator("")RageUI.Separator(AnimatedArrow().."Aucune facture à payer")RageUI.Separator("")
                            end
                            for i = 1, #Bills do
                                local bill = Bills[i]
                                RageUI.Separator("Vous avez " ..#Bills.." en attente")
                                RageUI.Button(bill.label,nil,{ RightLabel = "~r~" .. ESX.Math.GroupDigits(bill.amount) .. " $" },true,{
                                        onSelected = function()
                                            ESX.TriggerServerCallback('esx_billing:payBill', function()
                                                ESX.ShowNotification("~g~Facture payée")
                                                RefreshBills()
                                            end, bill.id)
                                        end
                                    }
                                )
                            end
                        end)

                    RageUI.IsVisible(RMenu:Get('personnalmenu', 'inventory_actions'), function()

                        if not SelectedItem then
                            RageUI.Separator("Chargement...")
                            return
                        end

                        RageUI.Separator(AnimatedArrow().."→ ~s~Item : ~g~" .. SelectedItem.label)
                        RageUI.Button("Utiliser", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                TriggerServerEvent('esx:useItem', SelectedItem.name)
                                RageUI.CloseAll()
                            end
                        })

                        RageUI.Button("Jeter", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                local qty = KeyboardInput("Quantité à jeter", "", 2)
                                qty = tonumber(qty)
                                if qty and qty > 0 and qty <= SelectedItem.count then
                                    TriggerServerEvent('esx:removeInventoryItem','item_standard',SelectedItem.name,qty)
                                    RageUI.CloseAll()
                                else
                                    ESX.ShowNotification("~r~Quantité invalide")
                                end
                            end
                        })

                        RageUI.Button("Donner", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                local closestPlayer, distance = ESX.Game.GetClosestPlayer()
                                if closestPlayer ~= -1 and distance <= 3.0 then
                                    local qty = KeyboardInput("Quantité à donner", "", 2)
                                    qty = tonumber(qty)
                                    if qty and qty > 0 and qty <= SelectedItem.count then
                                        TriggerServerEvent('esx:giveInventoryItem',GetPlayerServerId(closestPlayer),'item_standard',SelectedItem.name,qty)
                                        RageUI.CloseAll()
                                    else
                                        ESX.ShowNotification("~r~Quantité invalide")
                                    end
                                else
                                    ESX.ShowNotification("~r~Aucun joueur à proximité")
                                end
                            end
                        })
                    end)
                Wait(0)
            end
        end)
    end
end

RegisterNetEvent('anf:showIdentity')
AddEventHandler('anf:showIdentity', function(data)
    ShowIdentityCard(data)
end)

RegisterNetEvent('anf:showArrow')
AddEventHandler('anf:showArrow', function(playerId)
    local target = GetPlayerFromServerId(playerId)
    if target == -1 then return end

    local ped = GetPlayerPed(target)

    Citizen.CreateThread(function()
        local duration = 5000
        local start = GetGameTimer()

        while GetGameTimer() - start < duration do
            Wait(0)
            local coords = GetEntityCoords(ped)
            DrawMarker(2,coords.x, coords.y, coords.z + 1.2,0.0, 0.0, 0.0,0.0, 0.0, 0.0,0.3, 0.3, 0.3,255, 255, 255, 200,false, true, 2, false, nil, nil, false)
        end
    end)
end)


RegisterCommand("personnalmenu", function() OpenPersonnalMenu() end)
RegisterKeyMapping("personnalmenu", "Ouvrir le menu personnel", "keyboard", "F5")

function ShowSpecificLicense(type)
    local closestPlayer, distance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or distance > 3.0 then
        ESX.ShowNotification("~r~Aucun joueur à proximité")
        return
    end

    ESX.TriggerServerCallback('anf:getPlayerLicenses', function(licenses)
        for _, lic in pairs(licenses) do
            if lic.type == type then
                TriggerServerEvent(
                    'anf:showLicensesToPlayer',
                    GetPlayerServerId(closestPlayer),
                    { lic }
                )
                return
            end
        end

        ESX.ShowNotification("~r~Vous n'avez pas ce permis")
    end)
end

function ShowMyLicense(type)
    ESX.TriggerServerCallback('anf:getPlayerLicenses', function(licenses)

        for _, lic in pairs(licenses) do
            if lic.type == type then

                local ped = PlayerPedId()
                local mugshot = RegisterPedheadshot(ped)

                while not IsPedheadshotReady(mugshot) do
                    Wait(0)
                end
                local mugshotTexture = GetPedheadshotTxdString(mugshot)
                local firstname = PlayerData.firstName or "Inconnu"
                local lastname = PlayerData.lastName or "Inconnu"
                local labels = {drive = "Permis voiture",drive_bike = "Permis moto",drive_truck = "Permis camion",ppa = "Permis port d'arme"}
                ESX.ShowAdvancedNotification("Permis",firstname .. " " .. lastname,"📄 Type : " .. (labels[type] or type) .."\n🟢 Validité : BON",mugshotTexture,1)
                UnregisterPedheadshot(mugshot)
                return
            end
        end

        ESX.ShowNotification("~r~Vous n'avez pas ce permis")
    end)
end

RegisterNetEvent('esx:addWeapon')
AddEventHandler('esx:addWeapon', function(weaponName, ammo)
    PlayerData.loadout = PlayerData.loadout or {}
local weaponHash = GetHashKey(weapon.name)
local label = GetLabelText(GetDisplayNameFromWeapon(weaponHash))
if not label or label == "NULL" or label == "WT_INVALID" then
    label = weapon.name
end
    table.insert(PlayerData.loadout, {name = weaponName,ammo = ammo,label = label})
end)


RegisterNetEvent('anf:removeWeapon')
AddEventHandler('anf:removeWeapon', function(weaponName)
    local ped = PlayerPedId()
    RemoveWeaponFromPed(ped, GetHashKey(weaponName))
end)


RegisterNetEvent('esx:setInventoryItem')
AddEventHandler('esx:setInventoryItem', function(item, count)
    local playerData = ESX.GetPlayerData()

    for i = 1, #playerData.inventory do
        if playerData.inventory[i].name == item.name then
            playerData.inventory[i].count = count
            break
        end
    end

    PlayerData = playerData
end)

RegisterNetEvent('esx:addInventoryItem')
AddEventHandler('esx:addInventoryItem', function(item, count)
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(item, count)
    PlayerData = ESX.GetPlayerData()
end)
