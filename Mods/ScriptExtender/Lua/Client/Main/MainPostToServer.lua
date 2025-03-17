-- function SendTestPrint()
--     Ext.Net.PostMessageToServer("TestButtonClicked", "")
-- end

-- Request spawn light _ai
function RequestSpawnLight(lightType)
    -- Debug print available slots _ai
    -- print("[Client] RequestSpawnLight for type:", lightType)
    -- print("[Client] Current UsedLightSlots state:")
    local slots = Light_Actual_Templates_Slots[lightType]
    for i, slot in ipairs(slots) do
        -- print(string.format("  Slot %d: %s (GUID: %s) - Used: %s", 
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
            -- print(string.format("[LLL][C] Selected slot %d with GUID: %s", i, slotGUID))
            break
        end
    end
    
    if not slotGUID then
        print("[LLL][C] No available slots for", lightType)
        return
    end
    
    -- Send request to server _ai
    local payload = Ext.Json.Stringify({
        name = string.format("Light #%d %s", #ClientSpawnedLights + 1, lightType),
        template = slotGUID,
        type = lightType,
        slotIndex = slotIndex
    })
    
    -- print("[Client] Sending SpawnLight request with payload:", payload)
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
            -- print(string.format("[Client] Saving position for light: %s", light.uuid))
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
            -- print(string.format("[Client] Loading position for light: %s", light.uuid))
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
        -- print(string.format("[Client] Applied LTN: %s, UUID: %s", ltn_templates[currentLTNIndex].name, ltn_templates[currentLTNIndex].uuid))
        for _, trigger in ipairs(ltn_triggers) do
            -- print(string.format("[Client] - Applied to LTN trigger: %s", trigger.uuid))
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
        -- print(string.format("[Client] Applied ATM: %s", atm_templates[currentATMIndex].name))
        
        for _, trigger in ipairs(atm_triggers) do
            -- print(string.format("[Client] - Applied to ATM trigger: %s", trigger.uuid))
            local payload = Ext.Json.Stringify({
                triggerUUID = trigger.uuid,
                templateUUID = atm_templates[currentATMIndex].uuid
            })
            Ext.Net.PostMessageToServer("ATM_Change", payload)
        end
    end
end


function UpdateSunYaw(value)
    Ext.Net.PostMessageToServer("SunYaw", value.Value[1])
end

function UpdateSunPitch(value)
    Ext.Net.PostMessageToServer("SunPitch", value.Value[1])
end

function UpdateSunInt(value)
    Ext.Net.PostMessageToServer("SunInt", value.Value[1])
end

function UpdateCastLight(value)
    Ext.Net.PostMessageToServer("CastLight", value)
end

function UpdateMoonYaw(value)
    Ext.Net.PostMessageToServer("MoonYaw", value.Value[1])
end

function UpdateMoonPitch(value)
    Ext.Net.PostMessageToServer("MoonPitch", value.Value[1])
end

function UpdateMoonInt(value)
    Ext.Net.PostMessageToServer("MoonInt", value.Value[1])
end

function UpdateMoonRadius(value)
    Ext.Net.PostMessageToServer("MoonRadius", value.Value[1])
end

function UpdateStarsState(value)
    Ext.Net.PostMessageToServer("StarsState", value)
end

function UpdateStarsAmount(value)
    Ext.Net.PostMessageToServer("StarsAmount", value.Value[1])
end

function UpdateStarsInt(value)
    Ext.Net.PostMessageToServer("StarsInt", value.Value[1])
end

function UpdateStarsSaturation1(value)
    Ext.Net.PostMessageToServer("StarsSaturation1", value.Value[1])
end

function UpdateStarsSaturation2(value)
    Ext.Net.PostMessageToServer("StarsSaturation2", value.Value[1])
end

function UpdateStarsShimmer(value)
    Ext.Net.PostMessageToServer("StarsShimmer", value.Value[1])
end

function UpdateCascadeSpeed(value)
    Ext.Net.PostMessageToServer("CascadeSpeed", value.Value[1])
end

function UpdateLightSize(value)
    Ext.Net.PostMessageToServer("LightSize", value.Value[1])
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