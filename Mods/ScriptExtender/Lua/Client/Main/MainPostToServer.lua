-- function SendTestDPrint()
--     Ext.Net.PostMessageToServer("TestButtonClicked", "")
-- end

-- Request spawn light _ai
function RequestSpawnLight(lightType)
    -- Debug DPrint available slots _ai
    -- DPrint("[Client] RequestSpawnLight for type:", lightType)
    -- DPrint("[Client] Current UsedLightSlots state:")
    local slots = Light_Actual_Templates_Slots[lightType]
    for i, slot in ipairs(slots) do
        -- DPrint(string.format("  Slot %d: %s (GUID: %s) - Used: %s", 
        --     i, slot[1], slot[2], 
        --     UsedLightSlots[lightType][i] and "Yes" or "No"))
    end
    
    -- Find first unused slot _ai
    local slotIndex = nil
    local slotGUID = nil
    
    for i, slot in ipairs(slots) do
        if slot[2] ~= "nil" and not UsedLightSlots[lightType][i] then
            slotIndex = i
            slotGUID = slot[2]
            -- DPrint(string.format("[LLL][C] Selected slot %d with GUID: %s", i, slotGUID))
            break
        end
    end
    
    if not slotGUID then
        DPrint("[LLL][C] No available slots for", lightType)
        return
    end
    
    -- Send request to server _ai
    local payload = Ext.Json.Stringify({
        name = string.format("Light #%d %s", #ClientSpawnedLights + 1, lightType),
        template = slotGUID,
        type = lightType,
        slotIndex = slotIndex
    })
    
    -- DPrint("[Client] Sending SpawnLight request with payload:", payload)
    Ext.Net.PostMessageToServer("SpawnLight", payload)
end

function LightDropdownChange(dropdown)
    if dropdown.SelectedIndex >= 0 then
        local selectedLight = ClientSpawnedLights[dropdown.SelectedIndex + 1]
        if selectedLight then

            if LightColorValues[selectedLight.uuid] then
                colorPicker.Color = {
                    LightColorValues[selectedLight.uuid].r,
                    LightColorValues[selectedLight.uuid].g,
                    LightColorValues[selectedLight.uuid].b,
                    1.0
                }
            else
                colorPicker.Color = {1.0, 1.0, 1.0, 1.0}
            end

            if LightIntensityValues[selectedLight.uuid] then
                currentValues.intensity[selectedLight.uuid] = LightIntensityValues[selectedLight.uuid]
            else
                currentValues.intensity[selectedLight.uuid] = 1.0
            end

            if LightRadiusValues[selectedLight.uuid] then
                currentValues.radius[selectedLight.uuid] = LightRadiusValues[selectedLight.uuid]
            else
                currentValues.radius[selectedLight.uuid] = 1.0
            end
            DPrint(LightIntensityValues[selectedLight.uuid], LightRadiusValues[selectedLight.uuid])
            DPrint(currentValues.intensity[selectedLight.uuid], currentValues.radius[selectedLight.uuid])

            UpdateValuesText()
        end
        
        UpdateCurrentOrbitValues()
        Ext.Net.PostMessageToServer("LightSelected", tostring(dropdown.SelectedIndex + 1))
    else
        UpdateValuesText()
    end
end

function RenameLightClick(renameInput)
    if LightDropdown.SelectedIndex >= 0 then
        local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if selectedLight then
            local data = {
                uuid = selectedLight.uuid,
                newName = renameInput.Text
            }
            Ext.Net.PostMessageToServer("RenameLight", Ext.Json.Stringify(data))
        end
    end
end

-- Send delete light request to server _ai
function DeleteLight()
    if LightDropdown and LightDropdown.SelectedIndex >= 0 then
        Ext.Net.PostMessageToServer("Delete", tostring(LightDropdown.SelectedIndex + 1))
    end
end

function ConfirmDeleteAllClick(deleteAllButton, confirmButton)
    confirmButton.Visible = false
    deleteAllButton.Visible = true
    

    -- Clear all client-side data _ai
    ClientSpawnedLights = {}
    LightColorValues = {}
    LightIntensityValues = {}
    LightRadiusValues = {}
    savedIntensities = {}
    lightStates = {}
    currentValues.intensity = {}
    currentValues.radius = {}

    UsedLightSlots = {
        ["Directional_5"] = {},
        ["Directional_10"] = {},
        ["Directional_20"] = {},
        ["Directional_30"] = {},
        ["Directional_40"] = {},
        ["Directional_60"] = {},
        ["Directional_90"] = {},
        ["Directional_150"] = {},
        ["Directional_180"] = {},
        ["Point"] = {},
        ["Torch"] = {}
    }
    
    -- Reset UI _ai
    if LightDropdown then
        LightDropdown.Options = {}
        LightDropdown.SelectedIndex = -1
    end
    UpdateValuesText()
    
    -- Send request to server _ai
    Ext.Net.PostMessageToServer("DeleteAllLights", "")
end

-- Request replace light _ai
function ReplaceLight()
    if LightDropdown.SelectedIndex >= 0 then
        local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if selectedLight then
            -- Store values before deletion _ai
            local oldUuid = selectedLight.uuid
            local oldColor = LightColorValues[oldUuid]
            local oldIntensity = LightIntensityValues[oldUuid]
            local oldRadius = LightRadiusValues[oldUuid]
            
            -- Get new light type _ai
            local selectedType = lightTypes[lightTypeCombo.SelectedIndex + 1]
            
            -- Update light name with new type _ai
            local newName = string.format("Light #%d %s", LightDropdown.SelectedIndex + 1, selectedType)
            
            -- Send replace request to server _ai
            local data = {
                uuid = oldUuid,
                newType = selectedType,
                newName = newName,
                values = {
                    color = oldColor,
                    intensity = oldIntensity,
                    radius = oldRadius
                }
            }
            UpdateValuesText()
            Ext.Net.PostMessageToServer("ReplaceLight", Ext.Json.Stringify(data))
        end
    end
end

-- Request duplicate light _ai
function DuplicateLight()
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end

    local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
    if not selectedLight then
        return
    end
    
    lastDuplicatedLightValues = {
        uuid = selectedLight.uuid,
        intensity = LightIntensityValues[selectedLight.uuid],
        radius = LightRadiusValues[selectedLight.uuid],
        temperature = LightTemperatureValues[selectedLight.uuid]
    }
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        uuid = selectedLight.uuid,
        template = selectedLight.template,
        type = selectedLight.type,
        values = {
            color = LightColorValues[selectedLight.uuid],
            intensity = LightIntensityValues[selectedLight.uuid],
            radius = LightRadiusValues[selectedLight.uuid],
            temperature = LightTemperatureValues[selectedLight.uuid]
        }
    }
    
    Ext.Net.PostMessageToServer("DuplicateLight", Ext.Json.Stringify(data))
end

-- Move light forward/back _ai
function MoveLightForwardBack(step)
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        step = step
    }
    Ext.Net.PostMessageToServer("MoveLightForwardBack", Ext.Json.Stringify(data))
end

-- Move light left/right _ai
function MoveLightLeftRight(step)
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        step = step
    }
    Ext.Net.PostMessageToServer("MoveLightLeftRight", Ext.Json.Stringify(data))
end

-- Move light up/down _ai
function MoveLightUpDown(step)
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        step = step
    }
    Ext.Net.PostMessageToServer("MoveLightUpDown", Ext.Json.Stringify(data))
end

-- Rotate light tilt _ai
function RotateLightTilt(step)
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        step = step
    }
    Ext.Net.PostMessageToServer("RotateLightTilt", Ext.Json.Stringify(data))
end

-- Rotate light yaw _ai
function RotateLightYaw(step)
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        step = step
    }
    Ext.Net.PostMessageToServer("RotateLightYaw", Ext.Json.Stringify(data))
end

-- Rotate light roll _ai
function RequestRotateLightRoll(step)
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        step = step
    }
    Ext.Net.PostMessageToServer("RotateLightRoll", Ext.Json.Stringify(data))
end

-- Reset light position relative to character position _ai
function ResetLightPosition(axis)
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        axis = axis
    }
    Ext.Net.PostMessageToServer("ResetLightPosition", Ext.Json.Stringify(data))
end

-- Reset light rotation to 0 for specified axis _ai
function ResetLightRotation(axis)
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        axis = axis
    }
    Ext.Net.PostMessageToServer("ResetLightRotation", Ext.Json.Stringify(data))
end

-- Handle save light position _ai
function SaveLightPosition()
    if LightDropdown.SelectedIndex >= 0 then
        local light = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if light then
            -- DPrint(string.format("[Client] Saving position for light: %s", light.uuid))
            local payload = Ext.Json.Stringify({
                lightUUID = light.uuid
            })
            Ext.Net.PostMessageToServer("SaveLightPosition", payload)
        end
    end
end

-- Handle load light position _ai
function LoadLightPosition()
    if LightDropdown.SelectedIndex >= 0 then
        local light = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if light then
            -- DPrint(string.format("[Client] Loading position for light: %s", light.uuid))
            local payload = Ext.Json.Stringify({
                lightUUID = light.uuid
            })
            Ext.Net.PostMessageToServer("LoadLightPosition", payload)
        end
    end
end

-- Request update of orbit values from current light position _ai
function UpdateOrbitValues(uuid)
    if uuid then
        local data = {
            uuid = uuid,
            type = "update_values"
        }
        Ext.Net.PostMessageToServer("UpdateOrbitValues", Ext.Json.Stringify(data))
    end
end

-- Add with other request functions _ai
function OrbitMovement(type, value, uuid)
    if uuid then
        local data = {
            type = type,
            value = value,
            uuid = uuid
        }
        Ext.Net.PostMessageToServer("UpdateOrbitMovement", Ext.Json.Stringify(data))
    end
end


-- Move light to camera position _ai
function MoveLightToCamera()
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then
        return
    end
    
    local cPos, tPos = GetCameraData()
    if not cPos then return end
    
    -- Calculate direction vector _ai
    local direction = Vector:CalculateDirection(cPos, tPos)
    local normalizedDir = Vector:Normalize(direction)
    
    -- Calculate rotation angles _ai
    local rotation = Vector:DirectionToRotation(direction)
    
    -- Send data to server _ai
    local data = {
        index = LightDropdown.SelectedIndex + 1,
        position = cPos,
        rotation = rotation
    }
    
    Ext.Net.PostMessageToServer("MoveLightToCamera", Ext.Json.Stringify(data))
end

-- Request camera-relative movement _ai
function MoveLightCameraRelative(direction, step)
    if LightDropdown.SelectedIndex >= 0 then
        local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if selectedLight then
            -- Get camera position _ai
            local cameraPos = GetCameraData()
            if cameraPos then
                local data = {
                    index = LightDropdown.SelectedIndex + 1,
                    uuid = selectedLight.uuid,
                    cameraPos = cameraPos,
                    direction = direction,
                    step = step
                }
                Ext.Net.PostMessageToServer("MoveLightCameraRelative", Ext.Json.Stringify(data))
            end
        end
    end
end

-- Apply LTN template function _ai
function ApplyLTNTemplate(index)
    if index > 0 and index <= #ltn_templates then
        currentLTNIndex = index
        -- DPrint(string.format("[Client] Applied LTN: %s, UUID: %s", ltn_templates[currentLTNIndex].name, ltn_templates[currentLTNIndex].uuid))
        for _, trigger in ipairs(ltn_triggers) do
            -- DPrint(string.format("[Client] - Applied to LTN trigger: %s", trigger.uuid))
            local payload = Ext.Json.Stringify({
                triggerUUID = trigger.uuid,
                templateUUID = ltn_templates[currentLTNIndex].uuid
            })
            currentLTN = ltn_templates[currentLTNIndex].uuid
            Ext.Net.PostMessageToServer("LTN_Change", payload)
            ChangeLTNValues()
        end

    end
end

-- Apply ATM template function _ai
function ApplyATMTemplate(index)
    if index > 0 and index <= #atm_templates then
        currentATMIndex = index
        -- DPrint(string.format("[Client] Applied ATM: %s", atm_templates[currentATMIndex].name))
        
        for _, trigger in ipairs(atm_triggers) do
            -- DPrint(string.format("[Client] - Applied to ATM trigger: %s", trigger.uuid))
            local payload = Ext.Json.Stringify({
                triggerUUID = trigger.uuid,
                templateUUID = atm_templates[currentATMIndex].uuid
            })
            Ext.Net.PostMessageToServer("ATM_Change", payload)
        end
    end
end


function UpdateValue(name, type, value)

        if type == "value" then
            local data = {
                name = name,
                value = value
            }
            Ext.Net.PostMessageToServer("LTNValueCahnged", Ext.Json.Stringify(data))

        elseif type == "value1" then 
            local data = {
                name = name,
                value = value.Value[1]
            }
            Ext.Net.PostMessageToServer("LTNValueCahnged", Ext.Json.Stringify(data))

        elseif type == "value4" then
            local data = {
                name = name,
                value1 = value.Color[1],
                value2 = value.Color[2],
                value3 = value.Color[3],
                value4 = value.Color[4]
            }
        Ext.Net.PostMessageToServer("LTNValueCahnged", Ext.Json.Stringify(data))

    end
end


-- function UpdateSunColor(value)
--     local data = {
--         c1 = value.Color[1],
--         c2 = value.Color[2],
--         c3 = value.Color[3],
--         c4 = value.Color[4]
--     }
--     Ext.Net.PostMessageToServer("SunColor", Ext.Json.Stringify(data))
-- end

function UpdateCastLight(value)
    Ext.Net.PostMessageToServer("CastLight", value)
end


function UpdateMoonColor(value)
    local data = {
        c1 = value.Color[1],
        c2 = value.Color[2],
        c3 = value.Color[3],
        c4 = value.Color[4]
    }
    Ext.Net.PostMessageToServer("MoonColor", Ext.Json.Stringify(data))
end


-- Fog Layer 0
function UpdateFogLayer0Albedo(value)
    local data = {
        a1 = value.Color[1],
        a2 = value.Color[2],
        a3 = value.Color[3]
    }
    Ext.Net.PostMessageToServer("FogLayer0Albedo", Ext.Json.Stringify(data))
end

function UpdateFogLayer0Density0(value)
    Ext.Net.PostMessageToServer("FogLayer0Density0", value.Value[1])
end

function UpdateFogLayer0Density1(value)
    Ext.Net.PostMessageToServer("FogLayer0Density1", value.Value[1])
end

function UpdateFogLayer0Enabled(value)
    Ext.Net.PostMessageToServer("FogLayer0Enabled", value)
end

function UpdateFogLayer0Height0(value)
    Ext.Net.PostMessageToServer("FogLayer0Height0", value.Value[1])
end

function UpdateFogLayer0Height1(value)
    Ext.Net.PostMessageToServer("FogLayer0Height1", value.Value[1])
end

function UpdateFogLayer0NoiseCoverage(value)
    Ext.Net.PostMessageToServer("FogLayer0NoiseCoverage", value.Value[1])
end

function UpdateFogLayer0NoiseFrequency(value)
    local data = {
        nf1 = value.Value[1],
        nf2 = value.Value[2],
        nf3 = value.Value[3]
    }
    Ext.Net.PostMessageToServer("FogLayer0NoiseFrequency", Ext.Json.Stringify(data))
end

function UpdateFogLayer0NoiseRotation(value)
    local data = {
        nr1 = value.Value[1],
        nr2 = value.Value[2],
        nr3 = value.Value[3]
    }
    Ext.Net.PostMessageToServer("FogLayer0NoiseRotation", Ext.Json.Stringify(data))
end

function UpdateFogLayer0NoiseWind(value)
    local data = {
        nw1 = value.Value[1],
        nw2 = value.Value[2],
        nw3 = value.Value[3]
    }
    Ext.Net.PostMessageToServer("FogLayer0NoiseWind", Ext.Json.Stringify(data))
end

-- Fog Layer 1
function UpdateFogLayer1Albedo(value)
    local data = {
        nw1 = value.Color[1],
        nw2 = value.Color[2],
        nw3 = value.Color[3]
    }
    Ext.Net.PostMessageToServer("FogLayer1Albedo", Ext.Json.Stringify(data))
end

function UpdateFogLayer1Density0(value)
    Ext.Net.PostMessageToServer("FogLayer1Density0", value.Value[1])
end

function UpdateFogLayer1Density1(value)
    Ext.Net.PostMessageToServer("FogLayer1Density1", value.Value[1])
end

function UpdateFogLayer1Enabled(value)
    Ext.Net.PostMessageToServer("FogLayer1Enabled", value)
end

function UpdateFogLayer1Height0(value)
    Ext.Net.PostMessageToServer("FogLayer1Height0", value.Value[1])
end

function UpdateFogLayer1Height1(value)
    Ext.Net.PostMessageToServer("FogLayer1Height1", value.Value[1])
end

function UpdateFogLayer1NoiseCoverage(value)
    Ext.Net.PostMessageToServer("FogLayer1NoiseCoverage", value.Value[1])
end

function UpdateFogLayer1NoiseFrequency(value)
    local data = {
        nf1 = value.Value[1],
        nf2 = value.Value[2],
        nf3 = value.Value[3]
    }
    Ext.Net.PostMessageToServer("FogLayer1NoiseFrequency", Ext.Json.Stringify(data))
end

function UpdateFogLayer1NoiseRotation(value)
    local data = {
        nr1 = value.Value[1],
        nr2 = value.Value[2],
        nr3 = value.Value[3]
    }
    Ext.Net.PostMessageToServer("FogLayer1NoiseRotation", Ext.Json.Stringify(data))
end

function UpdateFogLayer1NoiseWind(value)
    local data = {
        nw1 = value.Value[1],
        nw2 = value.Value[2],
        nw3 = value.Value[3]
    }
    Ext.Net.PostMessageToServer("FogLayer1NoiseWind", Ext.Json.Stringify(data))
end

-- Fog General
function UpdateFogPhase(value)
    Ext.Net.PostMessageToServer("FogPhase", value.Value[1])
end

function UpdateFogRenderDistance(value)
    Ext.Net.PostMessageToServer("FogRenderDistance", value.Value[1])
end

-- Moon
function UpdateMoonDistance(value)
    Ext.Net.PostMessageToServer("MoonDistance", value.Value[1])
end

function UpdateMoonEarthshine(value)
    Ext.Net.PostMessageToServer("MoonEarthshine", value.Value[1])
end

function UpdateMoonEnabled(value)
    Ext.Net.PostMessageToServer("MoonEnabled", value)
end


function UpdateMoonGlare(value)
    Ext.Net.PostMessageToServer("MoonGlare", value.Value[1])
end

function UpdateTearsRotate(value)
    Ext.Net.PostMessageToServer("TearsRotate", value.Value[1])
end

function UpdateTearsScale(value)
    Ext.Net.PostMessageToServer("TearsScale", value.Value[1])
end

-- SkyLight
function UpdateCirrusCloudsAmount(value)
    Ext.Net.PostMessageToServer("CirrusCloudsAmount", value.Value[1])
end

function UpdateCirrusCloudsColor(value)
    local data = {
        cc1 = value.Color[1],
        cc2 = value.Color[2],
        clampc3 = value.Color[3]
    }
    Ext.Net.PostMessageToServer("CirrusCloudsColor", Ext.Json.Stringify(data))
end

function UpdateCirrusCloudsEnabled(value)
    Ext.Net.PostMessageToServer("CirrusCloudsEnabled", value)
end

function UpdateCirrusCloudsIntensity(value)
    Ext.Net.PostMessageToServer("CirrusCloudsIntensity", value.Value[1])
end

function UpdateRotateSkydomeEnabled(value)
    Ext.Net.PostMessageToServer("RotateSkydomeEnabled", value)
end

function UpdateScatteringEnabled(value)
    Ext.Net.PostMessageToServer("ScatteringEnabled", value)
end

function UpdateScatteringIntensity(value)
    Ext.Net.PostMessageToServer("ScatteringIntensity", value.Value[1])
end

function UpdateScatteringSunColor(value)
    local data = {
        sc1 = value.Color[1],
        sc2 = value.Color[2],
        sc3 = value.Color[3]
    }
    Ext.Net.PostMessageToServer("ScatteringSunColor", Ext.Json.Stringify(data))
end

function UpdateScatteringSunIntensity(value)
    Ext.Net.PostMessageToServer("ScatteringSunIntensity", value.Value[1])
end

function UpdateSkydomeEnabled(value)
    Ext.Net.PostMessageToServer("SkydomeEnabled", value)
end

function UpdateSkydomeTex(value)
    Ext.Net.PostMessageToServer("SkydomeTex", value)
end

-- Sun
function UpdateSunIntensity(value)
    Ext.Net.PostMessageToServer("SunIntensity", value.Value[1])
end

function UpdateCascadeCount(value)
    Ext.Net.PostMessageToServer("CascadeCount", value.Value[1])
end

function UpdateShadowBias(value)
    Ext.Net.PostMessageToServer("ShadowBias", value.Value[1])
end

function UpdateShadowEnabled(value)
    Ext.Net.PostMessageToServer("ShadowEnabled", value)
end

function UpdateShadowFade(value)
    Ext.Net.PostMessageToServer("ShadowFade", value.Value[1])
end

function UpdateShadowFarPlane(value)
    Ext.Net.PostMessageToServer("ShadowFarPlane", value.Value[1])
end

function UpdateShadowNearPlane(value)
    Ext.Net.PostMessageToServer("ShadowNearPlane", value.Value[1])
end

function UpdateShadowObscurity(value)
    Ext.Net.PostMessageToServer("ShadowObscurity", value.Value[1])
end

function UpdateScatteringIntensityScale(value)
    Ext.Net.PostMessageToServer("ScatteringIntensityScale", value.Value[1])
end

-- Volumetric Cloud
function UpdateCloudAmbientLightFactor(value)
    Ext.Net.PostMessageToServer("CloudAmbientLightFactor", value.Value[1])
end

function UpdateCloudBaseColor(value)
    local data = {
        cbc1 = value.Color[1],
        cbc2 = value.Color[2],
        cbc3 = value.Color[3]
    }
    Ext.Net.PostMessageToServer("CloudBaseColor", Ext.Json.Stringify(data))
end

function UpdateCloudEndHeight(value)
    Ext.Net.PostMessageToServer("CloudEndHeight", value.Value[1])
end

function UpdateCloudHorizonDistance(value)
    Ext.Net.PostMessageToServer("CloudHorizonDistance", value.Value[1])
end

function UpdateCloudOffset(value)
    local data = {
        co1 = value.Value[1],
        co2 = value.Value[2]
    }
    Ext.Net.PostMessageToServer("CloudOffset", Ext.Json.Stringify(data))
end

function UpdateCloudStartHeight(value)
    Ext.Net.PostMessageToServer("CloudStartHeight", value.Value[1])
end

function UpdateCloudCoverageStartDistance(value)
    Ext.Net.PostMessageToServer("CloudCoverageStartDistance", value.Value[1])
end

function UpdateCloudCoverageWindSpeed(value)
    Ext.Net.PostMessageToServer("CloudCoverageWindSpeed", value.Value[1])
end

function UpdateCloudDetailScale(value)
    Ext.Net.PostMessageToServer("CloudDetailScale", value.Value[1])
end

function UpdateCloudEnabled(value)
    Ext.Net.PostMessageToServer("CloudEnabled", value)
end

function UpdateCloudIntensity(value)
    Ext.Net.PostMessageToServer("CloudIntensity", value.Value[1])
end

function UpdateCloudShadowFactor(value)
    Ext.Net.PostMessageToServer("CloudShadowFactor", value.Value[1])
end

function UpdateCloudSunLightFactor(value)
    Ext.Net.PostMessageToServer("CloudSunLightFactor", value.Value[1])
end

function UpdateCloudSunRayLength(value)
    Ext.Net.PostMessageToServer("CloudSunRayLength", value.Value[1])
end

function UpdateCloudTopColor(value)
    local data = {
        ctc1 = value.Color[1],
        ctc2 = value.Color[2],
        ctc3 = value.Color[3]
    }
    Ext.Net.PostMessageToServer("CloudTopColor", Ext.Json.Stringify(data))
end

-- Toggle marker function _ai
function ToggleMarker()
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then return end
    
    local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
    if selectedLight then
        local data = {
            uuid = selectedLight.uuid
        }
        Ext.Net.PostMessageToServer("ToggleMarker", Ext.Json.Stringify(data))
    end
end

-- Toggle all markers function _ai
function ToggleAllMarkers()
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then return end
    
    local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
    if selectedLight then
        local data = {
            uuid = selectedLight.uuid,
            allLights = ClientSpawnedLights
        }
        Ext.Net.PostMessageToServer("ToggleAllMarkers", Ext.Json.Stringify(data))
    end
end