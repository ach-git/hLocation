Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj)   ESX = obj   end)

    for _,v in pairs(Config.location) do
        local HashPed = GetHashKey(v.model)
        RequestModel(HashPed)
        while not HasModelLoaded(HashPed) do Wait(1) end
        ped = CreatePed(4, HashPed, v.pos, v.angle, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        TaskStartScenarioInPlace(ped, v.animation, 0, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        blips = AddBlipForCoord(v.pos)
        SetBlipSprite(blips, v.blip)
        SetBlipDisplay(blips,4)
        SetBlipScale(blips, 0.6)
        SetBlipColour(blips, v.color)
        SetBlipAsShortRange(blips, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blips)
    end

    local player = PlayerPedId()
    while true do
        interval = 1000
        local plypos = GetEntityCoords(player)
        for _,v in pairs(Config.location) do
            if #(plypos - v.pos) < 15 then
                interval = 100
                if #(plypos - v.pos) < 5 then
                    interval = 0
                    ESX.ShowFloatingHelpNotification(v.interact, vector3(v.pos.x, v.pos.y, v.pos.z + 1.85))
                    if IsControlJustPressed(1, 51) then
                        OpenLocation(v)
                    end
                end
            end
        end
        Wait(interval)
    end
end)

local LocationOpened = false
local LocationMenu = RageUI.CreateMenu("Location", "Description")
LocationMenu.Closed = function()
    LocationOpened = false
    RageUI.CloseAll()
end

OpenLocation = function(ped)
    if LocationOpened then
        return
    else
        LocationOpened = true
        local player = PlayerPedId()
        RageUI.Visible(LocationMenu, true)
        Citizen.CreateThread(function()
            while LocationOpened do
                local plypos = GetEntityCoords(player)
                if #(plypos - ped.pos) < 5 then
                    RageUI.IsVisible(LocationMenu, function()
                        for _,v in pairs(ped.Vehicule) do
                            RageUI.Button(v.name, nil, {RightLabel = "~g~"..v.price.."$"}, true, {
                                onSelected = function()
                                    LocationOpened = false
                                    RageUI.CloseAll()
                                    if ESX.Game.IsSpawnPointClear(ped.pos, 2) then
                                        TriggerServerEvent("hLocation:location", v, ped)
                                    else
                                        ESX.ShowNotification("~r~Un vehicule est deja sorti!", 0, 0)
                                    end
                                end
                            })
                        end
                    end)
                else
                    LocationOpened = false
                    RageUI.CloseAll()
                end
                Wait(0)
            end
        end)
    end
end

RegisterNetEvent("hLocation:spawnVeh")
AddEventHandler("hLocation:spawnVeh", function(veh, ped)
    local HashVeh = GetHashKey(veh.model)
    RequestModel(HashVeh)
    while not HasModelLoaded(HashVeh) do Wait(1) end
    local car = CreateVehicle(HashVeh, ped.spawn, ped.sapwnangle, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
    SetVehicleNumberPlateText(car, "Location")
end)
