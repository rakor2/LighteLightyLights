lastDuplicatedLightValues = nil

-- Update host position from server _ai
Ext.RegisterNetListener("HostPosition", function(channel, payload)
    hostPosition = Ext.Json.Parse(payload)
end)

Ext.RegisterNetListener("SyncSpawnedLights", function(channel, payload)
    local syncData = Ext.Json.Parse(payload)
    local previousSelectedUUID = nil
    local previousCount = #ClientSpawnedLights
    
    -- Store currently selected light UUID _ai
    if LightDropdown and LightDropdown.SelectedIndex >= 0 then
        local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if selectedLight then
            previousSelectedUUID = selectedLight.uuid
        end
    end
    
    -- If this is just a color update, handle it differently _ai
    if syncData.type == "color_update" then
        -- Find light by UUID _ai
        for i, light in ipairs(ClientSpawnedLights) do
            if light.uuid == syncData.targetUUID then
                -- Save color in light data _ai
                light.color = syncData.color
                
                -- Update VFX color if entity exists and has valid values _ai
                if vfxEntClient[i] and syncData.color and 
                   type(syncData.color.r) == "number" and 
                   type(syncData.color.g) == "number" and 
                   type(syncData.color.b) == "number" then
                    local color = {
                        syncData.color.r,
                        syncData.color.g,
                        syncData.color.b,
                        1.0
                    }
                    pcall(function()
                        ChangeVFXColor(vfxEntClient[i], color)
                    end)
                end
                break
            end
        end
        return
    end
    
    -- Regular sync code continues here... _ai
    -- DPrint("[Client] Processing regular sync update")
    -- DPrint("[Client] Previous light count:", previousCount)
    -- DPrint("[Client] New light count:", #syncData.lights)
    
    -- If we received empty list, clear all data _ai
    if #syncData.lights == 0 then
        ClientSpawnedLights = {}
        LightColorValues = {}
        LightIntensityValues = {}
        LightRadiusValues = {}
        LightTemperatureValues = {}
        savedIntensities = {}
        lightStates = {}
        currentValues.intensity = {}
        currentValues.radius = {}
        entClient = {}
        vfxEntClient = {}
        vfxEntClientReady = {}
        LightGoboMap = {}

        if LightDropdown then
            LightDropdown.Options = {}
            LightDropdown.SelectedIndex = -1
        end
        UpdateValuesText()
        return
    end
    
    ClientSpawnedLights = syncData.lights
    
    -- Clear all used slots first _ai
    for _, lightType in ipairs(lightTypes) do
        UsedLightSlots[lightType] = {}
    end
    
    -- Use the server's usedSlots data directly _ai
    if syncData.usedSlots then
        for lightType, slots in pairs(syncData.usedSlots) do
            UsedLightSlots[lightType] = slots
        end
    end
    
    -- Debug DPrint current slots state only for Point type _ai
    -- DPrint("[Client] Current UsedLightSlots state for Point")
    for i, slot in ipairs(Light_Actual_Templates_Slots["Point"]) do
        if slot[2] ~= "nil" then
            -- DPrint(string.format("  Slot %d: Used: %s", i, UsedLightSlots["Point"][i] and "Yes" or "No"))
        end
    end
    
    if LightDropdown then
        local options = {}
        for i = 1, #ClientSpawnedLights do
            local light = ClientSpawnedLights[i]
            
            -- Save light UUID _ai
            uuidClient[i] = light.uuid
            
            -- Get Entity and VFX with delay _ai
            Ext.OnNextTick(function()
                entClient[i] = Ext.Entity.Get(light.uuid)
            end)
            
            local handlerId
            local tick = 0
            handlerId = Ext.Events.Tick:Subscribe(function()
                tick = tick + 1
                local lightEntity = Ext.Entity.Get(light.uuid)
                if lightEntity ~= nil then
                    local vis1 = lightEntity.Visual
                    if vis1 ~= nil then
                        local vis2 = vis1.Visual
                        if vis2 ~= nil then
                            local visualEntity = vis2.VisualEntity
                            if visualEntity ~= nil then
                                vfxEntClient[i] = visualEntity
                                vfxEntClientReady[i] = true
                                Ext.Events.Tick:Unsubscribe(handlerId)
                            end
                        end
                    end
                end
            end)
            
            table.insert(options, light.name)
            
            if previousSelectedUUID and light.uuid == previousSelectedUUID then
                -- DPrint("[Client] Restoring selection for previously selected light:", light.name)
                LightDropdown.SelectedIndex = i - 1
            end
        end
        
        LightDropdown.Options = options
        
        if #ClientSpawnedLights > previousCount then
            -- DPrint("[Client] New light added, selecting last light")
            LightDropdown.SelectedIndex = #options - 1
            UpdateValuesText()

        elseif #ClientSpawnedLights < previousCount and #options > 0 then
            if LightDropdown.SelectedIndex >= #options then

                LightDropdown.SelectedIndex = #options - 1
                UpdateValuesText() 
            end
        elseif not previousSelectedUUID and #options > 0 then
            LightDropdown.SelectedIndex = #options - 1
            UpdateValuesText() 
        end
    end
    

    if lastDuplicatedLightValues and #ClientSpawnedLights > previousCount then
        local newLight = ClientSpawnedLights[#ClientSpawnedLights]
        
        if newLight and newLight.uuid ~= lastDuplicatedLightValues.uuid then
            if lastDuplicatedLightValues.intensity then
                LightIntensityValues[newLight.uuid] = lastDuplicatedLightValues.intensity
            end
            
            if lastDuplicatedLightValues.radius then
                LightRadiusValues[newLight.uuid] = lastDuplicatedLightValues.radius
            end
            
            if lastDuplicatedLightValues.temperature then
                LightTemperatureValues[newLight.uuid] = lastDuplicatedLightValues.temperature
                
                if temperatureSlider and LightDropdown and LightDropdown.SelectedIndex == #ClientSpawnedLights - 1 then
                    temperatureSlider.Value = {lastDuplicatedLightValues.temperature, 0, 0, 0}
                end
            end
            
            if LightDropdown and LightDropdown.SelectedIndex == #ClientSpawnedLights - 1 then
                UpdateValuesText()
            end
        end
    end
    
    -- Сбрасываем значения _ai
    lastDuplicatedLightValues = nil
    
    -- Sync with gobo light dropdown _ai
    if goboLightDropdown then
        goboLightDropdown.Options = LightDropdown.Options
        goboLightDropdown.SelectedIndex = LightDropdown.SelectedIndex
    end
end)

-- Handle lights list update from server _ai
Ext.RegisterNetListener("UpdateLightList", function(channel, payload)
    local lightList = Ext.Json.Parse(payload)
    if LightDropdown then
        local options = {}
        for _, light in ipairs(lightList) do
            table.insert(options, light.name)
        end
        LightDropdown.Options = options
        
        -- Select newly created light _ai
        if #options > 0 then
            LightDropdown.SelectedIndex = #options - 1
        end
    end
end)

-- Handle restore replaced light values _ai
Ext.RegisterNetListener("RestoreReplacedLightValues", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    
    -- Wait 12 ticks before restoring values _ai
    local tickCount = 0
    local handlerId
    handlerId = Ext.Events.Tick:Subscribe(function()
        tickCount = tickCount + 1
        if tickCount >= 12 then
            Ext.Events.Tick:Unsubscribe(handlerId)
            
            -- Find the new light and its VFX _ai
            local vfxEntity = nil
            for i, light in ipairs(ClientSpawnedLights) do
                if light.uuid == data.newUuid then
                    vfxEntity = vfxEntClient[i]
                    break
                end
            end
            
            if vfxEntity then
                -- Restore color _ai
                if data.values.color then
                    LightColorValues[data.newUuid] = data.values.color
                    ChangeVFXColor(vfxEntity, {
                        data.values.color.r,
                        data.values.color.g,
                        data.values.color.b,
                        1.0
                    })
                end
                
                -- Restore intensity _ai
                if data.values.intensity then
                    LightIntensityValues[data.newUuid] = data.values.intensity
                    UpdateVFXIntensity(vfxEntity, data.values.intensity)
                end
                
                -- Restore radius _ai
                if data.values.radius then
                    LightRadiusValues[data.newUuid] = data.values.radius
                    UpdateVFXRadius(vfxEntity, data.values.radius)
                end
            end
        end
    end)
end)

-- Add handler for orbit values update response _ai
Ext.RegisterNetListener("OrbitValuesUpdated", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    if data.uuid then
        currentAngle[data.uuid] = data.angle
        currentRadius[data.uuid] = data.radius
        currentHeight[data.uuid] = data.height
    end
end)

-- Origin point handler _ai
Ext.RegisterNetListener("OriginPointCreated", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    originPoint.entity = data.uuid
    originPoint.position = data.position
end)


    -- Sync with main light dropdown _ai
Ext.RegisterNetListener("SyncSpawnedLights", function(channel, payload)
    if goboLightDropdown then
        goboLightDropdown.Options = LightDropdown.Options
        goboLightDropdown.SelectedIndex = LightDropdown.SelectedIndex
    end
end)

Ext.RegisterNetListener("ChangeLTNValuesToClient", function(channel, payload)
    ChangeLTNValues()
end)