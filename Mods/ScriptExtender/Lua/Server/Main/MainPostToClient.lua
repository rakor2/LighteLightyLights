-- Sync lights to clients function _ai
function SyncSpawnedLightsToClients()
    -- Add position data to lights before sending _ai
    local lightsWithPosition = {}
    for _, light in ipairs(ServerSpawnedLights) do
        local x, y, z = Osi.GetPosition(light.uuid)
        local lightData = {
            name = light.name,
            template = light.template,
            uuid = light.uuid,
            type = light.type,
            slotIndex = light.slotIndex,
            color = light.color,
            position = {x = x, y = y, z = z}
        }
        table.insert(lightsWithPosition, lightData)
    end
    
    -- Send both lights data and used slots to clients _ai
    local syncData = {
        lights = lightsWithPosition,
        usedSlots = UsedLightSlots
    }
    
    Ext.Net.BroadcastMessage("SyncSpawnedLights", Ext.Json.Stringify(syncData))
end