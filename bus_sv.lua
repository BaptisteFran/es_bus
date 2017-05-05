
RegisterServerEvent('busJob:addMoney')
AddEventHandler('busJob:addMoney', function(amount)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    user:addMoney((amount))
     end)
end)
