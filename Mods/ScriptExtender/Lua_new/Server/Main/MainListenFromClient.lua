Ext.RegisterNetListener('CreateLight', function(channel, payload)
    local data = Ext.Json.Parse(payload)
    DPrint('Recieved UUID: ' .. data.lightUuid .. '  and type: ' .. data.lightType)
end)