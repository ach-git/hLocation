TriggerEvent('esx:getSharedObject', function(obj)   ESX = obj   end)

RegisterNetEvent("hLocation:location")
AddEventHandler("hLocation:location", function(veh, ped)
    if #(GetEntityCoords(GetPlayerPed(source)) - ped.pos) < 5 then
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer.getMoney() > veh.price then
            xPlayer.removeMoney(veh.price)
            TriggerClientEvent("hLocation:spawnVeh", source, veh, ped)
            xPlayer.showNotification("<C>Location</C>\n~g~Vous avez bien louez votre "..veh.name.." pour "..veh.price.."$")
        else
            xPlayer.showNotification("<C>Location</C>\n~r~Vous n\'avez pas assez d\'argent pour "..veh.name)
        end
    else
        DropPlayer(source, "Kick reason: cheating")
    end
end)