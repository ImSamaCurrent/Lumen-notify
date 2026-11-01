-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  lumen-notify · server/main.lua                                  ║
-- ╚══════════════════════════════════════════════════════════════════╝

exports('notify', function(source, text, duration, position)
    TriggerClientEvent('lumen-notify:notify', source, text, duration, position)
end)

exports('notifyAdvanced', function(source, options)
    TriggerClientEvent('lumen-notify:notifyAdvanced', source, options)
end)

exports('notifyAll', function(text, duration, position)
    TriggerClientEvent('lumen-notify:notify', -1, text, duration, position)
end)

exports('notifyAllAdvanced', function(options)
    TriggerClientEvent('lumen-notify:notifyAdvanced', -1, options)
end)

RegisterServerEvent('lumen-notify:sv:notify', function(text, duration, position)
    local src = source
    TriggerClientEvent('lumen-notify:notify', src, text, duration, position)
end)

RegisterServerEvent('lumen-notify:sv:notifyAdvanced', function(options)
    local src = source
    TriggerClientEvent('lumen-notify:notifyAdvanced', src, options)
end)
