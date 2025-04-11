-- Position source toggle _ai
UseClientPosition = false

-- Store client position _ai
hostPosClient = nil

-- Origin point data _ai
originPoint = {
    entity = nil,
    enabled = false
}

-- Update origin point state _ai
Ext.RegisterNetListener("UpdateOriginPointState", function(_, payload)
    local data = Ext.Json.Parse(payload)
    originPoint.entity = data.entity
    originPoint.enabled = data.enabled
end)

-- Get host character position from server _ai
function GetHostPositionServer()
    local x, y, z = Osi.GetPosition(GetHostCharacter())
    return {
        x = x,
        y = y,
        z = z
    }
end

-- Handle client position update _ai
Ext.RegisterNetListener("UpdateClientPosition", function(_, payload)
    hostPosClient = Ext.Json.Parse(payload)
end)

Ext.RegisterNetListener("UpdateCutscenePosition", function(_, payload)
    dummyPlayerPosition = Ext.Json.Parse(payload)
end)


-- Handle UseClientPosition toggle _ai
Ext.RegisterNetListener("SetUseClientPosition", function(_, payload)
    UseClientPosition = payload == "true"
end)


Ext.RegisterNetListener("SetUseCutscenePosition", function(_, payload)
    UseCutscenePosition = payload == "true"
end)

-- Get client position _ai
function GetHostPositionClient()
    return hostPosClient
end

function GetPlayerCutscenePosition()
    return dummyPlayerPosition
end


-- Get host position _ai
function GetHostPosition()
    if originPoint.enabled then
        local x, y, z = Osi.GetPosition(originPoint.entity)
        return {
            x = x,
            y = y,
            z = z
        }
    end

    if UseClientPosition then
        local clientPos = GetHostPositionClient()
        if clientPos then
            return clientPos
        end
    end
    

    if UseCutscenePosition then
        local clientPos = GetPlayerCutscenePosition()
        if clientPos then
            return clientPos
        end
    end
    
    local serverPos = GetHostPositionServer()
    -- DPrint("[Server][DEBUG] Server position: x=", serverPos.x, "y=", serverPos.y, "z=", serverPos.z) -- _ai
    return serverPos
end

-- Get light position _ai
function GetLightPosition(lightUUID)
    local x, y, z = Osi.GetPosition(lightUUID)
    return {
        x = x,
        y = y,
        z = z
    }
end

-- Get light rotation _ai
function GetLightRotation(lightUUID)
    local rx, ry, rz = Osi.GetRotation(lightUUID)
    return {
        x = rx or 0,
        y = ry or 0,
        z = rz or 0
    }
end