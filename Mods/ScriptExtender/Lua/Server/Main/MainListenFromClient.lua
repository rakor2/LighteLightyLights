-- -- Test button _ai
-- Ext.RegisterNetListener("TestButtonClicked", function(channel, payload)
--     --DPrint("[MainServer]", "Test button clicked")
-- end)


-- Add marker visibility state tracking _ai
local markerVisible = {}
local secondaryMarkers = {}
local secondaryMarkersVisible = false
local currentMarker1Light = nil -- Track which light has marker1 _ai

-- Add table to track gobo masks for lights _ai
LightGoboMap = {}

-- Handle request for host position _ai
Ext.RegisterNetListener("RequestHostPosition", function(channel, payload)
    SendHostPositionToClient()
end)

-- Global counter for light names _ai
local globalLightCounter = 0

-- Helper function to generate unique light name _ai
local function GenerateUniqueLightName(lightType)
    globalLightCounter = globalLightCounter + 1
    return string.format("Light #%d %s", globalLightCounter, lightType)
end

-- Handle spawn light request from client _ai
Ext.RegisterNetListener("SpawnLight", function(channel, payload)
    -- DPrint("[Server] SpawnLight received with payload:", payload)
    local data = Ext.Json.Parse(payload)
    local posHost = GetHostPosition()
    
    -- Create light and save its UUID _ai
    local lightIndex = #ServerSpawnedLights + 1
    uuidServer[lightIndex] = Osi.CreateAt(data.template, posHost.x, posHost.y, posHost.z, 0, 1, "")
    -- DPrint(uuidServer[lightIndex])
    -- Mark slot as used _ai
    if data.type and data.slotIndex then
        -- DPrint(string.format("[Server] Marking slot %d as used for type %s", data.slotIndex, data.type))
        UsedLightSlots[data.type][data.slotIndex] = true
        
        -- Debug DPrint current slots state _ai
        -- DPrint("[Server] Current UsedLightSlots state for", data.type)
        for i, slot in ipairs(Light_Actual_Templates_Slots[data.type]) do
            -- DPrint(string.format("  Slot %d: Used: %s", i, UsedLightSlots[data.type][i] and "Yes" or "No"))
        end
    end
    
    -- Generate unique name _ai
    local uniqueName = GenerateUniqueLightName(data.type)
    
    -- Add light to list _ai
    table.insert(ServerSpawnedLights, {
        name = uniqueName,
        template = data.template,
        uuid = uuidServer[lightIndex],
        type = data.type,
        slotIndex = data.slotIndex,
        color = "white"  -- Set initial color to white _ai
    })
    
    -- DDump(ServerSpawnedLights)

    -- Create or move marker for the new light _ai
    CreateOrMoveLightMarker(uuidServer[lightIndex])
    -- First sync the list to update clients _ai
    SyncSpawnedLightsToClients()
    
    -- Then send color update _ai
    local updateData = {
        lights = ServerSpawnedLights,
        type = "color_update",
        targetUUID = uuidServer[lightIndex],
        color = "white"
    }
    
    -- Send color update _ai
    Ext.Net.BroadcastMessage("SyncSpawnedLights", Ext.Json.Stringify(updateData))
end)

-- Handle delete light request _ai
Ext.RegisterNetListener("Delete", function(channel, payload)
    local index = tonumber(payload)
    -- DPrint("[Server] Delete request received for index:", index)
    
    if index and index <= #ServerSpawnedLights then
        local lightData = ServerSpawnedLights[index]
        
        -- Free up the slot _ai
        if lightData.type and lightData.slotIndex then
            -- DPrint(string.format("[Server] Freeing up slot %d for type %s", lightData.slotIndex, lightData.type))
            UsedLightSlots[lightData.type][lightData.slotIndex] = nil
        end
        
        -- Delete secondary marker if exists _ai
        if secondaryMarkers[lightData.uuid] then
            Osi.RequestDelete(secondaryMarkers[lightData.uuid])
            secondaryMarkers[lightData.uuid] = nil
        end

        -- Delete associated gobo mask if exists _ai
        if LightGoboMap[lightData.uuid] then
            Osi.RequestDelete(LightGoboMap[lightData.uuid])
            LightGoboMap[lightData.uuid] = nil
        end
        
        Osi.RequestDelete(lightData.uuid)
        table.remove(ServerSpawnedLights, index)
        
        -- Handle marker after light deletion _ai
        if #ServerSpawnedLights == 0 then
            -- Reset counter if no lights left _ai
            globalLightCounter = 0
            
            -- Delete primary marker if no lights left _ai
            if lightMarker then
                Osi.RequestDelete(lightMarker)
                lightMarker = nil
            end
        else
            -- Move marker to the currently selected light _ai
            -- If we deleted last light in list, select previous one _ai
            local newIndex = math.min(index, #ServerSpawnedLights)
            local newLightUUID = ServerSpawnedLights[newIndex].uuid
            CreateOrMoveLightMarker(newLightUUID)
        end
        
        SyncSpawnedLightsToClients()
    end
end)

-- Handle color change request from client _ai
Ext.RegisterNetListener("ChangeLightColor", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    
    local lightFound = false
    for i, light in ipairs(ServerSpawnedLights) do
        if light.uuid == data.uuid then
            light.color = data.color
            lightFound = true
            break
        end
    end
    
    if not lightFound then
        return
    end
    
    -- Send color update _ai
    local updateData = {
        type = "color_update",
        targetUUID = data.uuid,
        color = data.color
    }
    
    Ext.Net.BroadcastMessage("SyncSpawnedLights", Ext.Json.Stringify(updateData))
end)

-- Handle rename request from client _ai
Ext.RegisterNetListener("RenameLight", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    
    for i, light in ipairs(ServerSpawnedLights) do
        if light.uuid == data.uuid then
            local lightNum = light.name:match("#(%d+)")
            light.name = string.format("Light #%s %s", 
                lightNum or "?",
                data.newName)
            break
        end
    end
    
    -- Send updated data to clients _ai
    SyncSpawnedLightsToClients()
end)

-- Handle light movement requests _ai
Ext.RegisterNetListener("MoveLightForwardBack", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID, x, y, z, rx, ry, rz = GetLightTransform(data.index)
    
    if lightUUID then
        lastMode[lightUUID] = "default"
        Osi.ToTransform(lightUUID, x, y, z + data.step, rx, ry, rz)
        UpdateMarkerPosition(lightUUID)
    end
end)

Ext.RegisterNetListener("MoveLightLeftRight", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID, x, y, z, rx, ry, rz = GetLightTransform(data.index)
    
    if lightUUID then
        Osi.ToTransform(lightUUID, x + data.step, y, z, rx, ry, rz)
        UpdateMarkerPosition(lightUUID)
    end
end)

Ext.RegisterNetListener("MoveLightUpDown", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID, x, y, z, rx, ry, rz = GetLightTransform(data.index)
    
    if lightUUID then
        Osi.ToTransform(lightUUID, x, y + data.step, z, rx, ry, rz)
        UpdateMarkerPosition(lightUUID)
    end
end)

-- Handle light rotation requests _ai
Ext.RegisterNetListener("RotateLightTilt", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local index = data.index
    local step = data.step
    
    if index and ServerSpawnedLights[index] then
        local lightUUID = ServerSpawnedLights[index].uuid
        -- Store tilt rotation offset _ai
        lightRotation.tilt[lightUUID] = (lightRotation.tilt[lightUUID] or 0) + step
        
        local pos = GetLightPosition(lightUUID)
        local rot = GetLightRotation(lightUUID)
        Osi.ToTransform(lightUUID, pos.x, pos.y, pos.z, rot.x + step, rot.y, rot.z)
        UpdateMarkerPosition(lightUUID)
    end
end)

Ext.RegisterNetListener("RotateLightYaw", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local index = data.index
    local step = data.step
    
    if index and ServerSpawnedLights[index] then
        local lightUUID = ServerSpawnedLights[index].uuid
        -- Store yaw rotation offset _ai
        lightRotation.yaw[lightUUID] = (lightRotation.yaw[lightUUID] or 0) + step
        
        local pos = GetLightPosition(lightUUID)
        local rot = GetLightRotation(lightUUID)
        Osi.ToTransform(lightUUID, pos.x, pos.y, pos.z, rot.x, rot.y + step, rot.z)
        UpdateMarkerPosition(lightUUID)
    end
end)

Ext.RegisterNetListener("RotateLightRoll", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local index = data.index
    local step = data.step
    
    if index and ServerSpawnedLights[index] then
        local lightUUID = ServerSpawnedLights[index].uuid
        -- Store roll rotation offset _ai
        lightRotation.roll[lightUUID] = (lightRotation.roll[lightUUID] or 0) + step
        
        local pos = GetLightPosition(lightUUID)
        local rot = GetLightRotation(lightUUID)
        Osi.ToTransform(lightUUID, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z + step)
        UpdateMarkerPosition(lightUUID)
    end
end)

-- Handle reset light position request _ai
Ext.RegisterNetListener("ResetLightPosition", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID, x, y, z, rx, ry, rz = GetLightTransform(data.index)
    
    if lightUUID then
        -- Get character position using existing helper function _ai
        local charPos = GetHostPosition()
        
        -- Reset only specified axis to character position _ai
        if data.axis == "x" then
            Osi.ToTransform(lightUUID, charPos.x, y, z, rx, ry, rz)
        elseif data.axis == "y" then
            Osi.ToTransform(lightUUID, x, charPos.y, z, rx, ry, rz)
        elseif data.axis == "z" then
            Osi.ToTransform(lightUUID, x, y, charPos.z, rx, ry, rz)
        elseif data.axis == "all" then
            -- Reset all axes to character position _ai
            Osi.ToTransform(lightUUID, charPos.x, charPos.y, charPos.z, rx, ry, rz)
        end
        UpdateMarkerPosition(lightUUID)
    end
end)

-- Handle reset light rotation request _ai
Ext.RegisterNetListener("ResetLightRotation", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID, x, y, z, rx, ry, rz = GetLightTransform(data.index)
    
    if lightUUID then
        local mode = lastMode[lightUUID] or "default"
        
        if mode == "orbit" then
            -- Reset to look at character _ai
            local charPos = GetHostPosition()
            local baseRx, baseRy, _ = Orbit:CalculateLookAtRotation(x, y, z, charPos.x, charPos.y, charPos.z)
            
            if data.axis == "tilt" then
                lightRotation.tilt[lightUUID] = 0
                Osi.ToTransform(lightUUID, x, y, z, baseRx, ry, rz)
            elseif data.axis == "yaw" then
                lightRotation.yaw[lightUUID] = 0
                Osi.ToTransform(lightUUID, x, y, z, rx, baseRy, rz)
            elseif data.axis == "roll" then
                lightRotation.roll[lightUUID] = 0
                Osi.ToTransform(lightUUID, x, y, z, rx, ry, 0)
            elseif data.axis == "all" then
                -- Reset all rotation values _ai
                lightRotation.tilt[lightUUID] = 0
                lightRotation.yaw[lightUUID] = 0
                lightRotation.roll[lightUUID] = 0
                Osi.ToTransform(lightUUID, x, y, z, baseRx, baseRy, 0)
            end
            UpdateMarkerPosition(lightUUID)
        else
            -- Reset to 0 _ai
            if data.axis == "tilt" then
                lightRotation.tilt[lightUUID] = 0
                Osi.ToTransform(lightUUID, x, y, z, 0, ry, rz)
            elseif data.axis == "yaw" then
                lightRotation.yaw[lightUUID] = 0
                Osi.ToTransform(lightUUID, x, y, z, rx, 0, rz)
            elseif data.axis == "roll" then
                lightRotation.roll[lightUUID] = 0
                Osi.ToTransform(lightUUID, x, y, z, rx, ry, 0)
            elseif data.axis == "all" then
                -- Reset all rotation values _ai
                lightRotation.tilt[lightUUID] = 0
                lightRotation.yaw[lightUUID] = 0
                lightRotation.roll[lightUUID] = 0
                Osi.ToTransform(lightUUID, x, y, z, 0, 0, 0)
            end
            UpdateMarkerPosition(lightUUID)
        end
    end
end)

-- Handle marker toggle request _ai
Ext.RegisterNetListener("ToggleMarker", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.uuid
    local markerEntity = Ext.Entity.Get(lightMarker)
    if not lightMarker then return end
    
    -- Initialize state if needed _ai
    if markerVisible[lightUUID] == nil then
        markerVisible[lightUUID] = true
    end
    
    -- Get current marker position and rotation _ai
    local x, y, z = Osi.GetPosition(lightMarker)
    local rx, ry, rz = Osi.GetRotation(lightMarker)
    
    if markerVisible[lightUUID] then
        -- Hide marker by moving it down, preserving rotation _ai
        -- Osi.ToTransform(lightMarker, x, y - 5, z, rx, ry, rz)
        markerEntity.GameObjectVisual.Scale = 0
        markerEntity:Replicate("GameObjectVisual")
        markerVisible[lightUUID] = false
    else
        -- Show marker by moving it back up, preserving rotation _ai
        -- Osi.ToTransform(lightMarker, x, y + 5, z, rx, ry, rz)
        markerEntity.GameObjectVisual.Scale = 0.78
        markerEntity:Replicate("GameObjectVisual")
        markerVisible[lightUUID] = true
    end
end)


-- Update existing LightSelected handler to manage secondary markers _ai
Ext.RegisterNetListener("LightSelected", function(channel, payload)
    local index = tonumber(payload)
    if index and index <= #ServerSpawnedLights then
        local newLightUUID = ServerSpawnedLights[index].uuid
        
        -- If we have a current marker1 light, create marker2 for it _ai
        if currentMarker1Light and secondaryMarkersVisible then
            if not secondaryMarkers[currentMarker1Light] then
                local pos = GetLightPosition(currentMarker1Light)
                local rot = GetLightRotation(currentMarker1Light)
                local marker = Osi.CreateAt(lightMarker2GUID, pos.x, pos.y, pos.z, 0, 1, "")
                Osi.ToTransform(marker, pos.x, pos.y, pos.z, rot.x-90, rot.y, rot.z)
                secondaryMarkers[currentMarker1Light] = marker
            end
        end
        
        -- If new light has marker2, remove it since it will get marker1 _ai
        if secondaryMarkers[newLightUUID] then
            Osi.RequestDelete(secondaryMarkers[newLightUUID])
            secondaryMarkers[newLightUUID] = nil
        end
        
        -- Move marker1 to new light and update tracking _ai
        CreateOrMoveLightMarker(newLightUUID)
        currentMarker1Light = newLightUUID
    end
end)

-- Handle toggle all markers request _ai
Ext.RegisterNetListener("ToggleAllMarkers", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local selectedLightUUID = data.uuid
    
    if not secondaryMarkersVisible then
        -- Create markers for all lights except selected one _ai
        for _, light in ipairs(ServerSpawnedLights) do
            if light.uuid ~= selectedLightUUID and not secondaryMarkers[light.uuid] then
                local pos = GetLightPosition(light.uuid)
                local rot = GetLightRotation(light.uuid)
                
                -- Create new marker _ai
                local marker = Osi.CreateAt(lightMarker2GUID, pos.x, pos.y, pos.z, 0, 1, "")
                Osi.ToTransform(marker, pos.x, pos.y, pos.z, rot.x-90, rot.y, rot.z)
                secondaryMarkers[light.uuid] = marker
            end
        end
        secondaryMarkersVisible = true
    else
        -- Remove all secondary markers _ai
        for uuid, marker in pairs(secondaryMarkers) do
            if marker then
                Osi.RequestDelete(marker)
            end
        end
        secondaryMarkers = {}
        secondaryMarkersVisible = false
    end
end)

-- Handle delete all lights request _ai
Ext.RegisterNetListener("DeleteAllLights", function(channel, payload)
    -- Delete all secondary markers first _ai
    for uuid, marker in pairs(secondaryMarkers) do
        if marker then
            Osi.RequestDelete(marker)
        end
    end
    secondaryMarkers = {}
    secondaryMarkersVisible = false

    -- Delete all gobo masks first _ai
    for uuid, gobo in pairs(LightGoboMap) do
        if gobo then
            Osi.RequestDelete(gobo)
        end
    end
    LightGoboMap = {}

    -- Delete all lights and free up their slots _ai
    for _, light in ipairs(ServerSpawnedLights) do
        if light.type and light.slotIndex then
            UsedLightSlots[light.type][light.slotIndex] = nil
        end
        Osi.RequestDelete(light.uuid)
    end
    
    -- Delete primary marker _ai
    if lightMarker then
        Osi.RequestDelete(lightMarker)
        lightMarker = nil
    end
    
    -- Clear all lists and reset counters _ai
    ServerSpawnedLights = {}
    globalLightCounter = 0
    
    -- Sync empty list to clients _ai
    SyncSpawnedLightsToClients()
end)

-- Handle orbit position update _ai
Ext.RegisterNetListener("UpdateLightOrbit", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.uuid
    
    -- DPrint("[Server] Orbit Update:") -- _ai
    -- DPrint(string.format("  Target position: x=%.2f, y=%.2f, z=%.2f", data.x, data.y, data.z)) -- _ai
    
    if lightUUID then
        -- Get current rotation _ai
        local rot = GetLightRotation(lightUUID)
        -- DPrint(string.format("  Current rotation: rx=%.2f, ry=%.2f, rz=%.2f", rot.x, rot.y, rot.z)) -- _ai
        
        Osi.ToTransform(lightUUID, data.x, data.y, data.z, rot.x, rot.y, rot.z)
        -- Update marker position _ai
        CreateOrMoveLightMarker(lightUUID)
    end
end)

-- -- Add handler for updating orbit values _ai
-- Ext.RegisterNetListener("UpdateOrbitMovement", function(channel, payload)
--     local data = Ext.Json.Parse(payload)
--     local lightUUID = data.uuid
--     local value = data.value
    
--     if lightUUID then
--         lastMode[lightUUID] = "orbit"
--         -- ... остальной код обработчика ...
--     end
-- end)

Ext.RegisterNetListener("UpdateOrbitMovement", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.uuid
    local value = data.value
    
    if lightUUID then
        -- Initialize values if they don't exist _ai
        local charPos = GetHostPosition()
        
        currentAngle[lightUUID] = currentAngle[lightUUID] or 0
        currentRadius[lightUUID] = currentRadius[lightUUID] or 0
        currentHeight[lightUUID] = currentHeight[lightUUID] or charPos.y
        
        if data.type == "angle" then
            currentAngle[lightUUID] = currentAngle[lightUUID] + value
        elseif data.type == "radius" then
            -- Ensure radius doesn't go below minimum value _ai
            currentRadius[lightUUID] = math.max(0.1, currentRadius[lightUUID] + value)
        elseif data.type == "height" then
            currentHeight[lightUUID] = currentHeight[lightUUID] + value
        end
        -- Update light position relative to character _ai
        UpdateLightOrbitPosition(lightUUID)
    end
end)

-- Add handler for updating orbit values _ai
Ext.RegisterNetListener("UpdateOrbitValues", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.uuid
    
    if lightUUID then
        local charPos = GetHostPosition()
        local lightPos = GetLightPosition(lightUUID)
        
        -- Calculate current orbit values from light position _ai
        local dx = lightPos.x - charPos.x
        local dz = lightPos.z - charPos.z
        
        -- Update values _ai
        currentRadius[lightUUID] = math.sqrt(dx * dx + dz * dz)
        currentAngle[lightUUID] = math.deg(Ext.Math.Atan2(dz, dx))
        currentHeight[lightUUID] = lightPos.y
        
        -- Send updated values to all clients _ai
        local response = {
            uuid = lightUUID,
            angle = currentAngle[lightUUID],
            radius = currentRadius[lightUUID],
            height = currentHeight[lightUUID]
        }
        Ext.Net.BroadcastMessage("OrbitValuesUpdated", Ext.Json.Stringify(response))
    end
end)

-- Handle move light to camera position request _ai
Ext.RegisterNetListener("MoveLightToCamera", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local index = data.index
    
    if index and ServerSpawnedLights[index] then
        local lightUUID = ServerSpawnedLights[index].uuid
        local pos = data.position
        local rot = data.rotation
        
        -- Move light to camera position _ai
        Osi.ToTransform(lightUUID, pos.x, pos.y, pos.z, rot.pitch, rot.yaw, rot.roll)
        
        -- Update marker position _ai
        UpdateMarkerPosition(lightUUID)
        
        -- Reset orbit mode since we moved the light directly _ai
        lastMode[lightUUID] = "default"
    end
end)

-- Handle camera-relative movement request _ai
Ext.RegisterNetListener("MoveLightCameraRelative", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.uuid
    
    if not lightUUID then return end
    
    -- Get current light position _ai
    local lightPos = GetLightPosition(lightUUID)
    if not lightPos then return end
    
    -- Get character position _ai
    local charPos = GetHostPosition()
    
    -- Calculate vector between camera and character _ai
    local cameraCharVector = Vector:CalculateCameraCharacterVector(data.cameraPos, charPos)
    local normalizedVector = Vector:Normalize(cameraCharVector)
    
    -- Calculate movement based on direction and camera-character vector _ai
    local movement = {x = 0, y = 0, z = 0}
    if data.direction == "forward" then
        movement = {
            x = normalizedVector.x * data.step,
            y = 0,
            z = normalizedVector.z * data.step
        }
    elseif data.direction == "right" then
        -- Calculate right vector (perpendicular to camera-character vector) _ai
        movement = {
            x = normalizedVector.z * data.step,
            y = 0,
            z = -normalizedVector.x * data.step
        }
    elseif data.direction == "up" then
        movement = {
            x = 0,
            y = data.step,
            z = 0
        }
    end
    
    -- Apply movement _ai
    local newPos = {
        x = lightPos.x + movement.x,
        y = lightPos.y + movement.y,
        z = lightPos.z + movement.z
    }
    
    -- Get current rotation _ai
    local rx, ry, rz = Osi.GetRotation(lightUUID)
    
    -- Move light to new position _ai
    Osi.ToTransform(lightUUID, newPos.x, newPos.y, newPos.z, rx or 0, ry or 0, rz or 0)
    
    -- Update marker position _ai
    UpdateMarkerPosition(lightUUID)
end)

-- Handle replace light request _ai
Ext.RegisterNetListener("ReplaceLight", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local oldUuid = data.uuid
    local newType = data.newType
    
    DPrint("[Server] Replace light request:", oldUuid, "to type", newType)
    
    -- Find old light and get its position and rotation _ai
    local oldLight = nil
    local oldIndex = nil
    for i, light in ipairs(ServerSpawnedLights) do
        if light.uuid == oldUuid then
            oldLight = light
            oldIndex = i
            break
        end
    end
    
    if oldLight then
        DPrint("[Server] Found old light:", oldLight.type, "slot", oldLight.slotIndex)
        
        -- Extract the number and custom name from the old light's name _ai
        local oldNumber = oldLight.name:match("#(%d+)")
        local customName = oldLight.name:match("#%d+ (.+)")
        
        -- If the custom name is just the type, use the new type instead _ai
        if customName == oldLight.type then
            customName = newType
        end
        
        -- Get position and rotation _ai
        local x, y, z = Osi.GetPosition(oldUuid)
        local rx, ry, rz = Osi.GetRotation(oldUuid)
        
        -- Find first unused slot for new type _ai
        local newSlotIndex = nil
        local newTemplate = nil
        local slots = Light_Actual_Templates_Slots[newType]
        
        -- Debug DPrint current slots state for new type _ai
        DPrint("[Server] Current slots state for", newType)
        for i, slot in ipairs(slots) do
            if slot[2] ~= "nil" then
                local isUsed = false
                for _, light in ipairs(ServerSpawnedLights) do
                    if light.type == newType and light.slotIndex == i and light.uuid ~= oldUuid then
                        isUsed = true
                        break
                    end
                end
                DPrint(string.format("  Slot %d: Used: %s", i, isUsed and "Yes" or "No"))
                if not isUsed then
                    newSlotIndex = i
                    newTemplate = slot[2]
                    break
                end
            end
        end
        
        if not newTemplate then
            DPrint("[Server] No available slots for type", newType)
            return
        end
        
        DPrint("[Server] Selected new slot", newSlotIndex, "with template", newTemplate)
        
        -- Save gobo data before deleting old light _ai
        local oldGoboUUID = LightGoboMap[oldUuid]
        local oldGoboDistance = GoboDistances[oldUuid]
        
        -- Free up the old slot before deleting the light _ai
        if oldLight.type and oldLight.slotIndex then
            DPrint(string.format("[Server] Freeing up slot %d for type %s during replacement", oldLight.slotIndex, oldLight.type))
            UsedLightSlots[oldLight.type][oldLight.slotIndex] = nil
        end
        
        -- Delete old light _ai
        Osi.RequestDelete(oldUuid)
        table.remove(ServerSpawnedLights, oldIndex)
        
        -- Get position and rotation _ai
        local pos = GetLightPosition(oldUuid)
        local rot = GetLightRotation(oldUuid)
        
        -- Create new light first _ai
        local newUuid = Osi.CreateAt(newTemplate, pos.x, pos.y, pos.z, 0, 1, "")
        
        -- Then set its rotation _ai
        Osi.ToTransform(newUuid, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z)
        
        -- Mark new slot as used _ai
        UsedLightSlots[newType][newSlotIndex] = true
        
        -- Generate name using the old number and preserving custom name _ai
        local uniqueName = string.format("Light #%s %s", oldNumber, customName)
        
        -- Add new light to list _ai
        table.insert(ServerSpawnedLights, {
            name = uniqueName,
            template = newTemplate,
            uuid = newUuid,
            type = newType,
            slotIndex = newSlotIndex
        })
        
        -- Transfer gobo to new light if it existed _ai
        if oldGoboUUID then
            LightGoboMap[newUuid] = oldGoboUUID
            GoboDistances[newUuid] = oldGoboDistance
            LightGoboMap[oldUuid] = nil
            GoboDistances[oldUuid] = nil
            UpdateGoboPosition(newUuid)
        end
        
        -- Update marker _ai
        CreateOrMoveLightMarker(newUuid)
        
        -- Sync list to clients _ai
        SyncSpawnedLightsToClients()
        
        -- Send restore values command to client _ai
        local restoreData = {
            oldUuid = oldUuid,
            newUuid = newUuid,
            values = data.values
        }
        Ext.Net.BroadcastMessage("RestoreReplacedLightValues", Ext.Json.Stringify(restoreData))
    end
end)

-- Handle light duplication request _ai
Ext.RegisterNetListener("DuplicateLight", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    
    -- Find first unused slot for the type _ai
    local newSlotIndex = nil
    local newTemplate = nil
    local slots = Light_Actual_Templates_Slots[data.type]
    
    for i, slot in ipairs(slots) do
        if slot[2] ~= "nil" then
            local isUsed = false
            for _, light in ipairs(ServerSpawnedLights) do
                if light.type == data.type and light.slotIndex == i then
                    isUsed = true
                    break
                end
            end
            if not isUsed then
                newSlotIndex = i
                newTemplate = slot[2]
                break
            end
        end
    end
    
    if not newTemplate then
        -- No available slots, don't duplicate _ai
        return
    end
    
    -- Get position and rotation from existing light _ai
    local pos = GetLightPosition(data.uuid)
    local rot = GetLightRotation(data.uuid)
    
    -- Create new light at the same position _ai
    local newUuid = Osi.CreateAt(newTemplate, pos.x, pos.y, pos.z, 0, 1, "")
    
    -- Set rotation _ai
    Osi.ToTransform(newUuid, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z)
    
    -- Generate unique name using the same function as for new lights _ai
    local uniqueName = GenerateUniqueLightName(data.type)
    
    -- Mark the slot as used _ai
    UsedLightSlots[data.type][newSlotIndex] = true
    
    -- Add to spawned lights list _ai
    table.insert(ServerSpawnedLights, {
        name = uniqueName,
        template = newTemplate,
        uuid = newUuid,
        type = data.type,
        slotIndex = newSlotIndex
    })
    
    -- Update marker _ai
    CreateOrMoveLightMarker(newUuid)
    
    -- Sync list to clients _ai
    SyncSpawnedLightsToClients()
    
    -- Send restore values command to clients _ai
    local restoreData = {
        newUuid = newUuid,
        values = data.values
    }
    Ext.Net.BroadcastMessage("RestoreReplacedLightValues", Ext.Json.Stringify(restoreData))
end)



-- Handle LTN change request from client _ai
Ext.RegisterNetListener("LTN_Change", function(channel, payload, user)
    local data = Ext.Json.Parse(payload)
    Osi.TriggerSetLighting(data.triggerUUID, data.templateUUID)
    currentLTN = data.templateUUID
end)

-- Handle ATM change request from client _ai
Ext.RegisterNetListener("ATM_Change", function(channel, payload, user)
    local data = Ext.Json.Parse(payload)
    Osi.TriggerSetAtmosphere(data.triggerUUID, data.templateUUID)
    currentATM = data.templateUUID
end)


-- Register message listeners _ai
Ext.RegisterNetListener("SaveLightPosition", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.lightUUID
    
    -- Get current position and rotation using helper functions _ai
    local pos = GetLightPosition(lightUUID)
    local rot = GetLightRotation(lightUUID)
    
    -- Save position and rotation _ai
    SavedLightPositions[lightUUID] = {
        x = pos.x,
        y = pos.y,
        z = pos.z,
        rx = rot.x,
        ry = rot.y,
        rz = rot.z
    }
    
    -- DPrint(string.format("[Server] Saved position for light: %s", lightUUID))
end)

Ext.RegisterNetListener("LoadLightPosition", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.lightUUID
    
    -- Check if position exists _ai
    if SavedLightPositions[lightUUID] then
        local pos = SavedLightPositions[lightUUID]
        
        -- DPrint(string.format("[Server] Loading position for light %s: x=%.2f, y=%.2f, z=%.2f, rx=%.2f, ry=%.2f, rz=%.2f", 
        --     lightUUID, pos.x, pos.y, pos.z, pos.rx, pos.ry, pos.rz))
        
        -- Apply saved position and rotation using ToTransform _ai
        Osi.ToTransform(lightUUID, pos.x, pos.y, pos.z, pos.rx, pos.ry, pos.rz)
        
        -- Update marker position _ai
        UpdateMarkerPosition(lightUUID)
        
        -- DPrint(string.format("[Server] Loaded position for light: %s", lightUUID))
    else
        -- DPrint(string.format("[Server] No saved position found for light: %s", lightUUID))
    end
end)

-- Reset all ATM triggers _ai
Ext.RegisterNetListener("ResetAllATM", function(channel, payload)
    -- DPrint("[Server] Resetting all ATM triggers") -- _ai
    for _, trigger in ipairs(atm_triggers) do
        -- DPrint("[Server] Resetting ATM trigger:", trigger.name) -- _ai
        Osi.TriggerResetAtmosphere(trigger.uuid)
    end
end)

-- Reset all LTN triggers _ai
Ext.RegisterNetListener("ResetAllLTN", function(channel, payload)
    -- DPrint("[Server] Resetting all LTN triggers") -- _ai
    for _, trigger in ipairs(ltn_triggers) do
        -- DPrint("[Server] Resetting LTN trigger:", trigger.name) -- _ai
        Osi.TriggerResetLighting(trigger.uuid)
    end
end)


Ext.RegisterNetListener("LTNValueCahnged", function(channel, payload)
    local data = Ext.Json.Parse(payload)

    for i = 1, #ltn_templates do
        local lighting = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting

        if data.name == "SunYaw" then lighting.Sun.Yaw = data.value
        elseif data.name == "SunPitch" then lighting.Sun.Pitch = data.value
        elseif data.name == "SunInt" then lighting.Sun.SunIntensity = data.value
        elseif data.name == "SunColor" then lighting.Sun.SunColor = {data.value1,data.value2,data.value3}
        elseif data.name == "CastLight" then lighting.Moon.CastLightEnabled = data.value
        elseif data.name == "MoonYaw" then lighting.Moon.Yaw = data.value
        elseif data.name == "MoonPitch" then lighting.Moon.Pitch = data.value
        elseif data.name == "MoonInt" then lighting.Sun.Moon.Intensity = data.value
        elseif data.name == "MoonRadius" then lighting.Sun.Moon.Radius = data.value
        elseif data.name == "MoonColor" then lighting.Sun.Moon.Color = {data.value1,data.value2,data.value3}
        elseif data.name == "StarsState" then lighting.SkyLight.ProcStarsEnabled = data.value
        elseif data.name == "StarsAmount" then lighting.SkyLight.ProcStarsAmount = data.value
        elseif data.name == "StarsInt" then lighting.SkyLight.ProcStarsIntensity = data.value
        elseif data.name == "StarsSaturation1" then lighting.SkyLight.ProcStarsSaturation[1] = data.value
        elseif data.name == "StarsSaturation2" then lighting.SkyLight.ProcStarsSaturation[2] = data.value
        elseif data.name == "StarsShimmer" then lighting.SkyLight.SkyLight.ProcStarsShimmer = data.value
        elseif data.name == "CascadeSpeed" then lighting.SkyLight.Sun.CascadeSpeed = data.value
        elseif data.name == "LightSize" then lighting.Sun.LightSize = data.value
        
        --Fog Layer 0
        elseif data.name == "FogLayer0Enabled" then lighting.Fog.FogLayer0.Enabled = data.value
        elseif data.name == "FogLayer0Density0" then lighting.Fog.FogLayer0.Density0 = data.value
        elseif data.name == "FogLayer0Density1" then lighting.Fog.FogLayer0.Density1 = data.value
        elseif data.name == "FogLayer0Height0" then lighting.Fog.FogLayer0.Height0 = data.value
        elseif data.name == "FogLayer0Height1" then lighting.Fog.FogLayer0.Height1 = data.value
        elseif data.name == "FogLayer0NoiseCoverage" then lighting.Fog.FogLayer0.NoiseCoverage = data.value
        elseif data.name == "FogLayer0Albedo" then lighting.Fog.FogLayer0.Albedo = {data.value1, data.value2, data.value3}
        
        --Fog Layer 1
        elseif data.name == "FogLayer1Enabled" then lighting.Fog.FogLayer1.Enabled = data.value
        elseif data.name == "FogLayer1Density0" then lighting.Fog.FogLayer1.Density0 = data.value
        elseif data.name == "FogLayer1Density1" then lighting.Fog.FogLayer1.Density1 = data.value
        elseif data.name == "FogLayer1Height0" then lighting.Fog.FogLayer1.Height0 = data.value
        elseif data.name == "FogLayer1Height1" then lighting.Fog.FogLayer1.Height1 = data.value
        elseif data.name == "FogLayer1NoiseCoverage" then lighting.Fog.FogLayer1.NoiseCoverage = data.value
        elseif data.name == "FogLayer1Albedo" then lighting.Fog.FogLayer1.Albedo = {data.value1, data.value2, data.value3}
        
        --Fog General
        elseif data.name == "FogPhase" then lighting.Fog.Phase = data.value
        elseif data.name == "FogRenderDistance" then lighting.Fog.RenderDistance = data.value
        
        --Moon Extended
        elseif data.name == "MoonDistance" then lighting.Moon.Distance = data.value
        elseif data.name == "MoonEarthshine" then lighting.Moon.Earthshine = data.value
        elseif data.name == "MoonEnabled" then lighting.Moon.Enabled = data.value
        elseif data.name == "MoonGlare" then lighting.Moon.MoonGlare = data.value
        elseif data.name == "TearsRotate" then lighting.Moon.TearsRotate = data.value
        elseif data.name == "TearsScale" then lighting.Moon.TearsScale = data.value
        
        --SkyLight
        elseif data.name == "CirrusCloudsAmount" then lighting.SkyLight.CirrusCloudsAmount = data.value
        elseif data.name == "CirrusCloudsColor" then lighting.SkyLight.CirrusCloudsColor = {data.value1, data.value2, data.value3}
        elseif data.name == "CirrusCloudsEnabled" then lighting.SkyLight.CirrusCloudsEnabled = data.value
        elseif data.name == "CirrusCloudsIntensity" then lighting.SkyLight.CirrusCloudsIntensity = data.value
        elseif data.name == "RotateSkydomeEnabled" then lighting.SkyLight.RotateSkydomeEnabled = data.value
        elseif data.name == "ScatteringEnabled" then lighting.SkyLight.ScatteringEnabled = data.value
        elseif data.name == "ScatteringIntensity" then lighting.SkyLight.ScatteringIntensity = data.value
        elseif data.name == "ScatteringSunColor" then lighting.SkyLight.ScatteringSunColor = {data.value1, data.value2, data.value3}
        elseif data.name == "ScatteringSunIntensity" then lighting.SkyLight.ScatteringSunIntensity = data.value
        elseif data.name == "SkydomeEnabled" then lighting.SkyLight.SkydomeEnabled = data.value
        
        --Sun Extended
        elseif data.name == "CascadeCount" then lighting.Sun.CascadeCount = data.value
        elseif data.name == "ShadowBias" then lighting.Sun.ShadowBias = data.value
        elseif data.name == "ShadowEnabled" then lighting.Sun.ShadowEnabled = data.value
        elseif data.name == "ShadowFade" then lighting.Sun.ShadowFade = data.value
        elseif data.name == "ShadowFarPlane" then lighting.Sun.ShadowFarPlane = data.value
        elseif data.name == "ShadowNearPlane" then lighting.Sun.ShadowNearPlane = data.value
        elseif data.name == "ScatteringIntensityScale" then lighting.Sun.ScatteringIntensityScale = data.value
        
        --Volumetric Cloud
        elseif data.name == "CloudEnabled" then lighting.VolumetricCloudSettings.Enabled = data.value
        elseif data.name == "CloudAmbientLightFactor" then lighting.VolumetricCloudSettings.AmbientLightFactor = data.value
        elseif data.name == "CloudBaseColor" then lighting.VolumetricCloudSettings.BaseColor = {data.value1, data.value2, data.value3}
        elseif data.name == "CloudEndHeight" then lighting.VolumetricCloudSettings.CoverageSettings.EndHeight = data.value
        elseif data.name == "CloudHorizonDistance" then lighting.VolumetricCloudSettings.CoverageSettings.HorizonDistance = data.value
        elseif data.name == "CloudStartHeight" then lighting.VolumetricCloudSettings.CoverageSettings.StartHeight = data.value
        elseif data.name == "CloudCoverageStartDistance" then lighting.VolumetricCloudSettings.CoverageStartDistance = data.value
        elseif data.name == "CloudCoverageWindSpeed" then lighting.VolumetricCloudSettings.CoverageWindSpeed = data.value
        elseif data.name == "CloudDetailScale" then lighting.VolumetricCloudSettings.DetailScale = data.value
        elseif data.name == "CloudIntensity" then lighting.VolumetricCloudSettings.Intensity = data.value
        elseif data.name == "CloudShadowFactor" then lighting.VolumetricCloudSettings.ShadowFactor = data.value
        elseif data.name == "CloudSunLightFactor" then lighting.VolumetricCloudSettings.SunLightFactor = data.value
        elseif data.name == "CloudSunRayLength" then lighting.VolumetricCloudSettings.SunRayLength = data.value
        elseif data.name == "CloudTopColor" then lighting.VolumetricCloudSettings.TopColor = {data.value1, data.value2, data.value3}
        end
    end
end)


-- Ext.RegisterNetListener("SunYaw", function(channel, payload)
--     --DPrint("[S][LLL] Sun yaw:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.Yaw = payload
--     end
-- end)

-- Ext.RegisterNetListener("SunPitch", function(channel, payload)
--     --DPrint("[S][LLL] Sun pitch:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.Pitch = payload
--     end
-- end)

-- Ext.RegisterNetListener("SunInt", function(channel, payload)
--     --DPrint("[S][LLL] Sun int:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.SunIntensity = payload
--     end
-- end)

-- Ext.RegisterNetListener("SunColor", function(channel, payload)

--     data = Ext.Json.Parse(payload)
    
--     --DPrint("[S][LLL] Sun int:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.SunColor = {data.value1,data.value2,data.value3}
--     end
-- end)


-- Ext.RegisterNetListener("CastLight", function(channel, payload)

--     local castLightState = tonumber(payload) == 1

--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.CastLightEnabled = castLightState
--     end
-- end)

-- Ext.RegisterNetListener("MoonYaw", function(channel, payload)
--     --DPrint("[S][LLL] Moon yaw:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Yaw = payload
--     end
-- end)

-- Ext.RegisterNetListener("MoonPitch", function(channel, payload)
--     --DPrint("[S][LLL] Moon pitch:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Pitch = payload
--     end
-- end)

-- Ext.RegisterNetListener("MoonInt", function(channel, payload)
--     --DPrint("[S][LLL] Moon int:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Intensity = payload
--     end
-- end)

-- Ext.RegisterNetListener("MoonRadius", function(channel, payload)
--     --DPrint("[S][LLL] Moon radius:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Radius = payload
--     end
-- end)

-- Ext.RegisterNetListener("MoonColor", function(channel, payload)

--     data = Ext.Json.Parse(payload)
    
--     --DPrint("[S][LLL] Sun int:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Color = {data.c1,data.c2,data.c3}
--     end
-- end)

-- Ext.RegisterNetListener("StarsState", function(channel, payload)
--     --DPrint("[S][LLL] Stars state:", payload)

--     local starsState = tonumber(payload) == 1

--     for i = 1, #ltn_templates do

--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsEnabled = starsState 
--     end
-- end)

-- Ext.RegisterNetListener("StarsAmount", function(channel, payload)
--     --DPrint("[S][LLL] Stars amount:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsAmount = payload
--     end
-- end)

-- Ext.RegisterNetListener("StarsInt", function(channel, payload)
--     --DPrint("[S][LLL] Stars int:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsIntensity = payload
--     end
-- end)

-- Ext.RegisterNetListener("StarsSaturation1", function(channel, payload)
--     --DPrint("[S][LLL] Stars saturation 1:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsSaturation[1] = payload
--     end
-- end)

-- Ext.RegisterNetListener("StarsSaturation2", function(channel, payload)
--     --DPrint("[S][LLL] Stars saturation 2:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsSaturation[2] = payload
--     end
-- end)

-- Ext.RegisterNetListener("StarsShimmer", function(channel, payload)
--     --DPrint("[S][LLL] Stars shimmer:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsShimmer = payload
--     end
-- end)

-- Ext.RegisterNetListener("CascadeSpeed", function(channel, payload)
--     --DPrint("[S][LLL] Cascade speed:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.CascadeSpeed = payload
--     end
-- end)

-- Ext.RegisterNetListener("LightSize", function(channel, payload)
--     --DPrint("[S][LLL] Light size:", payload)
--     for i = 1, #ltn_templates do
--         Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.LightSize = payload
--     end
-- end)

function valuesApply()
    local ticksPassed = 0
    local ticks = 5
    if currentLTN ~= nil then
        for i = 1, #ltn_triggers do
            Osi.TriggerSetLighting(ltn_triggers[i].uuid, "6e3f3623-5c84-a681-6131-2da753fa2c8f")
            if i == #ltn_triggers then
                if applyLTNSub then return end 
                applyLTNSub = Ext.Events.Tick:Subscribe(function()
                    ticksPassed = ticksPassed + 1
                    if ticksPassed >= ticks then
                        for k = 1, #ltn_triggers do
                            -- DPrint(k, currentLTN)
                            Osi.TriggerSetLighting(ltn_triggers[k].uuid, currentLTN)
                            if k == #ltn_triggers then
                                Ext.Events.Tick:Unsubscribe(applyLTNSub)
                                applyLTNSub = nil
                            end
                        end
                    end
                end)
            end
        end
    end
end




Ext.RegisterNetListener("sunValuesResetAll", function (channel, payload)
    --DPrint("[S][LLL] Load button pressed")

    local json = Ext.IO.LoadFile("LightyLights/LTN_Cache.json")
    local values = Ext.Json.Parse(json)

    for i = 1, #ltn_templates do

        local uuid = ltn_templates[i].uuid
        local parameters = values[uuid][2]


            local lighting = Ext.Resource.Get(uuid, "Lighting").Lighting
            
            --Sun
            lighting.Sun.Yaw = parameters.SunYaw
            lighting.Sun.Pitch = parameters.SunPitch
            lighting.Sun.SunIntensity = parameters.SunIntensity
            lighting.Sun.SunColor = { 
                parameters.SunColor[1],
                parameters.SunColor[2],
                parameters.SunColor[3]
            }
            lighting.Sun.CascadeCount = parameters.CascadeCount
            lighting.Sun.CascadeSpeed = parameters.CascadeSpeed
            lighting.Sun.LightSize = parameters.LightSize
            lighting.Sun.ShadowBias = parameters.ShadowBias
            lighting.Sun.ShadowEnabled = parameters.ShadowEnabled
            lighting.Sun.ShadowFade = parameters.ShadowFade
            lighting.Sun.ShadowFarPlane = parameters.ShadowFarPlane
            lighting.Sun.ShadowNearPlane = parameters.ShadowNearPlane
            lighting.Sun.ShadowObscurity = parameters.ShadowObscurity
            lighting.Sun.ScatteringIntensityScale = parameters.ScatteringIntensityScale

            --Moon
            lighting.Moon.Enabled = parameters.MoonEnabled
            lighting.Moon.Distance = parameters.MoonDistance
            lighting.Moon.Earthshine = parameters.MoonEarthshine
            lighting.Moon.MoonGlare = parameters.MoonGlare
            lighting.Moon.TearsRotate = parameters.TearsRotate
            lighting.Moon.TearsScale = parameters.TearsScale

            --Fog Layer 0
            lighting.Fog.FogLayer0.Albedo = {
                parameters.FogLayer0Albedo[1],
                parameters.FogLayer0Albedo[2],
                parameters.FogLayer0Albedo[3]
            }
            lighting.Fog.FogLayer0.Density0 = parameters.FogLayer0Density0
            lighting.Fog.FogLayer0.Density1 = parameters.FogLayer0Density1
            lighting.Fog.FogLayer0.Enabled = parameters.FogLayer0Enabled
            lighting.Fog.FogLayer0.Height0 = parameters.FogLayer0Height0
            lighting.Fog.FogLayer0.Height1 = parameters.FogLayer0Height1
            lighting.Fog.FogLayer0.NoiseCoverage = parameters.FogLayer0NoiseCoverage
            lighting.Fog.FogLayer0.NoiseFrequency = {
                parameters.FogLayer0NoiseFrequency[1],
                parameters.FogLayer0NoiseFrequency[2],
                parameters.FogLayer0NoiseFrequency[3]
            }
            lighting.Fog.FogLayer0.NoiseRotation = {
                parameters.FogLayer0NoiseRotation[1],
                parameters.FogLayer0NoiseRotation[2],
                parameters.FogLayer0NoiseRotation[3]
            }
            lighting.Fog.FogLayer0.NoiseWind = {
                parameters.FogLayer0NoiseWind[1],
                parameters.FogLayer0NoiseWind[2],
                parameters.FogLayer0NoiseWind[3]
            }

            --Fog Layer 1
            lighting.Fog.FogLayer1.Albedo = {
                parameters.FogLayer1Albedo[1],
                parameters.FogLayer1Albedo[2],
                parameters.FogLayer1Albedo[3]
            }
            lighting.Fog.FogLayer1.Density0 = parameters.FogLayer1Density0
            lighting.Fog.FogLayer1.Density1 = parameters.FogLayer1Density1
            lighting.Fog.FogLayer1.Enabled = parameters.FogLayer1Enabled
            lighting.Fog.FogLayer1.Height0 = parameters.FogLayer1Height0
            lighting.Fog.FogLayer1.Height1 = parameters.FogLayer1Height1
            lighting.Fog.FogLayer1.NoiseCoverage = parameters.FogLayer1NoiseCoverage
            lighting.Fog.FogLayer1.NoiseFrequency = {
                parameters.FogLayer1NoiseFrequency[1],
                parameters.FogLayer1NoiseFrequency[2],
                parameters.FogLayer1NoiseFrequency[3]
            }
            lighting.Fog.FogLayer1.NoiseRotation = {
                parameters.FogLayer1NoiseRotation[1],
                parameters.FogLayer1NoiseRotation[2],
                parameters.FogLayer1NoiseRotation[3]
            }
            lighting.Fog.FogLayer1.NoiseWind = {
                parameters.FogLayer1NoiseWind[1],
                parameters.FogLayer1NoiseWind[2],
                parameters.FogLayer1NoiseWind[3]
            }

            --Fog General
            lighting.Fog.Phase = parameters.FogPhase
            lighting.Fog.RenderDistance = parameters.FogRenderDistance

            --SkyLight
            lighting.SkyLight.CirrusCloudsAmount = parameters.CirrusCloudsAmount
            lighting.SkyLight.CirrusCloudsColor = {
                parameters.CirrusCloudsColor[1],
                parameters.CirrusCloudsColor[2],
                parameters.CirrusCloudsColor[3]
            }
            lighting.SkyLight.CirrusCloudsEnabled = parameters.CirrusCloudsEnabled
            lighting.SkyLight.CirrusCloudsIntensity = parameters.CirrusCloudsIntensity
            lighting.SkyLight.RotateSkydomeEnabled = parameters.RotateSkydomeEnabled
            lighting.SkyLight.ScatteringEnabled = parameters.ScatteringEnabled
            lighting.SkyLight.ScatteringIntensity = parameters.ScatteringIntensity
            lighting.SkyLight.ScatteringSunColor = {
                parameters.ScatteringSunColor[1],
                parameters.ScatteringSunColor[2],
                parameters.ScatteringSunColor[3]
            }
            lighting.SkyLight.ScatteringSunIntensity = parameters.ScatteringSunIntensity
            lighting.SkyLight.SkydomeEnabled = parameters.SkydomeEnabled
            lighting.SkyLight.SkydomeTex = parameters.SkydomeTex

            --Volumetric Cloud
            lighting.VolumetricCloudSettings.AmbientLightFactor = parameters.CloudAmbientLightFactor
            lighting.VolumetricCloudSettings.BaseColor = {
                parameters.CloudBaseColor[1],
                parameters.CloudBaseColor[2],
                parameters.CloudBaseColor[3]
            }
            lighting.VolumetricCloudSettings.CoverageSettings.EndHeight = parameters.CloudEndHeight
            lighting.VolumetricCloudSettings.CoverageSettings.HorizonDistance = parameters.CloudHorizonDistance
            lighting.VolumetricCloudSettings.CoverageSettings.Offset = {
                parameters.CloudOffset[1],
                parameters.CloudOffset[2]
            }
            lighting.VolumetricCloudSettings.CoverageSettings.StartHeight = parameters.CloudStartHeight
            lighting.VolumetricCloudSettings.CoverageStartDistance = parameters.CloudCoverageStartDistance
            lighting.VolumetricCloudSettings.CoverageWindSpeed = parameters.CloudCoverageWindSpeed
            lighting.VolumetricCloudSettings.DetailScale = parameters.CloudDetailScale
            lighting.VolumetricCloudSettings.Enabled = parameters.CloudEnabled
            lighting.VolumetricCloudSettings.Intensity = parameters.CloudIntensity
            lighting.VolumetricCloudSettings.ShadowFactor = parameters.CloudShadowFactor
            lighting.VolumetricCloudSettings.SunLightFactor = parameters.CloudSunLightFactor
            lighting.VolumetricCloudSettings.SunRayLength = parameters.CloudSunRayLength
            lighting.VolumetricCloudSettings.TopColor = {
                parameters.CloudTopColor[1],
                parameters.CloudTopColor[2],
                parameters.CloudTopColor[3]
            }
    end

    valuesApply()
    
end)



Ext.RegisterNetListener("valuesApply", function(channel, payload)
    valuesApply()
end)

Ext.RegisterNetListener("valuesApplyDay", function(channel, payload)
    local ticksPassed = 0
    local ticks = 5
    if currentLTN ~= nil then
        for i = 1, #ltn_triggers do
            Osi.TriggerSetLighting(ltn_triggers[i].uuid, "18c19ed1-f5f0-0380-ec7c-943ad733f031")
            if i == #ltn_triggers then
                if applyLTNSub then return end 
                applyLTNSub = Ext.Events.Tick:Subscribe(function()
                    ticksPassed = ticksPassed + 1
                    if ticksPassed >= ticks then
                        for k = 1, #ltn_triggers do
                            -- DPrint(k, currentLTN)
                            Osi.TriggerSetLighting(ltn_triggers[k].uuid, currentLTN)
                            if k == #ltn_triggers then
                                Ext.Events.Tick:Unsubscribe(applyLTNSub)
                                applyLTNSub = nil
                            end
                        end
                    end
                end)
            end
        end
    end
end)








-- Origin point handlers _ai
Ext.RegisterNetListener("CreateOriginPoint", function(channel, payload)
    local pos = GetHostPosition()
    originPoint.entity = Osi.CreateAt(lightMarker2GUID, pos.x, pos.y, pos.z, 0, 1, "")
end)

Ext.RegisterNetListener("DeleteOriginPoint", function(channel, payload)
    if originPoint.entity then
        Osi.RequestDelete(originPoint.entity)
        originPoint.entity = nil
        originPoint.enabled = false
    end
end)

Ext.RegisterNetListener("ResetOriginPoint", function(channel, payload)
    if originPoint.entity then
        local pos = GetHostPosition()
        Osi.ToTransform(originPoint.entity, pos.x, pos.y, pos.z, 0, 0, 0)
    end
end)

Ext.RegisterNetListener("ScaleOriginPoint", function(channel, payload)
    if originPoint.entity then
        local data = Ext.Json.Parse(payload)
        local originPointScale = Ext.Entity.Get(originPoint.entity)
        
        if data.hide then
            originPointScale.GameObjectVisual.Scale = 0.001
        else
            originPointScale.GameObjectVisual.Scale = 0.8
        end
        
        originPointScale:Replicate("GameObjectVisual")
    end
end)

Ext.RegisterNetListener("MoveOriginPoint", function(channel, payload)
    if originPoint.entity then
        local data = Ext.Json.Parse(payload)
        local x, y, z = Osi.GetPosition(originPoint.entity)
        
        if data.axis == "x" then
            x = x + data.value
        elseif data.axis == "y" then
            y = y + data.value
        elseif data.axis == "z" then
            z = z + data.value
        end
        
        Osi.ToTransform(originPoint.entity, x, y, z, 0, 0, 0)
    end
end)

-- Handler for moving origin point to a specific position _ai
Ext.RegisterNetListener("MoveOriginPointToPos", function(channel, payload)
    if originPoint.entity then
        local data = Ext.Json.Parse(payload)
        local position = data.position
        
        if position and position.x and position.y and position.z then
            Osi.ToTransform(originPoint.entity, position.x, position.y, position.z, 0, 0, 0)
        end
    end
end)

Ext.RegisterNetListener("ToggleOriginPoint", function(channel, payload)
    originPoint.enabled = payload == "true"
end)


-- Update CreateGobo handler to initialize distance _ai
Ext.RegisterNetListener("CreateGobo", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.lightUUID
    local goboGUID = data.goboGUID
    
    -- Delete existing gobo if any _ai
    if LightGoboMap[lightUUID] then
        Osi.RequestDelete(LightGoboMap[lightUUID])
        LightGoboMap[lightUUID] = nil
    end
    
    -- Create new gobo (position будет обновлена в UpdateGoboPosition) _ai
    local pos = GetLightPosition(lightUUID)
    local goboUUID = Osi.CreateAt(goboGUID, pos.x, pos.y, pos.z, 0, 1, "")
    
    -- Store gobo UUID and initialize distance _ai
    LightGoboMap[lightUUID] = goboUUID
    GoboDistances[lightUUID] = GoboDistances[lightUUID] or 1.0
    
    -- Immediately update position to correct location _ai
    UpdateGoboPosition(lightUUID)
end)


-- Handle gobo deletion request _ai
Ext.RegisterNetListener("DeleteGobo", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.lightUUID
    
    -- Delete gobo if exists _ai
    if LightGoboMap[lightUUID] then
        Osi.RequestDelete(LightGoboMap[lightUUID])
        LightGoboMap[lightUUID] = nil
    end
end)

-- Add handler for updating gobo distance _ai
Ext.RegisterNetListener("UpdateGoboDistance", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.lightUUID
    local distance = data.distance
    
    -- Store new distance _ai
    GoboDistances[lightUUID] = distance
    
    -- Update gobo position with new distance _ai
    UpdateGoboPosition(lightUUID)
end)


Ext.RegisterNetListener("UpdateGoboRotation", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.lightUUID
    local angle = data.angle
    local axis = data.axis
    
    if not GoboAngles[lightUUID] then
        GoboAngles[lightUUID] = {x = 0, y = 0, z = 0}
    elseif type(GoboAngles[lightUUID]) ~= "table" then
        local oldAngle = GoboAngles[lightUUID]
        GoboAngles[lightUUID] = {x = 0, y = 0, z = 0}
        GoboAngles[lightUUID].z = oldAngle
    end
    
    GoboAngles[lightUUID][axis] = angle
    
    UpdateGoboPosition(lightUUID)
end)


Ext.RegisterNetListener("ResetGoboRotation", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightUUID = data.lightUUID
    local axis = data.axis
    

    if not GoboAngles[lightUUID] or type(GoboAngles[lightUUID]) ~= "table" then
        GoboAngles[lightUUID] = {x = 0, y = 0, z = 0}
    end
    
    if axis == "all" then
        GoboAngles[lightUUID] = {x = 0, y = 0, z = 0}
    else
        GoboAngles[lightUUID][axis] = 0
    end
    

    UpdateGoboPosition(lightUUID)
end)

Ext.RegisterNetListener("ApplyTranformToServerXd", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    local lightEntity = Ext.Entity.Get(data.lightUUID)
    lightEntity.Transform.Transform.RotationQuat = { 
            data.rotation.x, 
            data.rotation.y, 
            data.rotation.z, 
            data.rotation.w 
        }
        lightEntity.Transform.Transform.Translate = { 
            data.position.x, 
            data.position.y, 
            data.position.z 
        }
    UpdateMarkerPosition(data.lightUUID)
    UpdateGoboPosition(data.lightUUID)
end)


