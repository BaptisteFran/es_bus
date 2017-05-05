require "resources/essentialmode/lib/MySQL"
MySQL:open("localhost", "gta5_gamemode_essential", "root", "password")


function nameJob(id)
  local executed_query = MySQL:executeQuery("SELECT * FROM jobs WHERE job_id = '@namejob'", {['@namejob'] = id})
  local result = MySQL:getResults(executed_query, {'job_name'}, "job_id")
  return result[1].job_name
end


RegisterServerEvent('busJob:addMoney')
AddEventHandler('busJob:addMoney', function(amount)
  TriggerEvent('es:getPlayerFromId', source, function(user)
        local nameJob = nameJob(id)
       if nameJob == 6 then -- Bus driver job ID  
    user:addMoney((amount))
     end)
end)
