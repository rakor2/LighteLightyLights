local cameraFollowSubscriptionId = nil

-- VFX control variables _ai
local vfxSubscription = nil
local tickCounter = 0

-- LTN/ATM control variables _ai
local currentLTNIndex = 1
local currentATMIndex = 1
filteredLTNIndices = {} 
filteredATMIndices = {}

-- Button cooldown variables _ai
local atmltnCooldown = 15
local ltnButtonEnabled = true
local atmButtonEnabled = true

-- Light toggle state _ai
local areLightsOn = true

-- Add light states tracking _ai
local lightStates = {}

-- Camera subscription ID for move to camera function _ai
cameraSubscriptionId = nil

-- Function to update values text _ai
function UpdateValuesText()
    if not LightDropdown or not currentIntensityTextWidget or not currentDistanceTextWidget then 
        return 
    end
    
    if LightDropdown.SelectedIndex >= 0 then
        local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if selectedLight then

            local intensity = LightIntensityValues[selectedLight.uuid]
            local distance = LightRadiusValues[selectedLight.uuid]
            local temperature = LightTemperatureValues[selectedLight.uuid]
            
            if intensity then
                -- currentIntensityTextWidget.Label = string.format("Power: %.3f", intensity)
                intensitySliderValue.Value = {intensity, 0, 0, 0}

            else
                -- currentIntensityTextWidget.Label = string.format("Power: %.3f", 1.0)
                intensitySliderValue.Value = {1.0, 0, 0, 0}
                LightIntensityValues[selectedLight.uuid] = 1.0
            end
            
            if distance then

                -- currentDistanceTextWidget.Label = string.format("Distance: %.3f", distance)
                radiusSliderValue.Value = {distance, 0, 0, 0}
            else

                -- currentDistanceTextWidget.Label = string.format("Distance: %.3f", 1.0)
                radiusSliderValue.Value = {1.0, 0, 0, 0}
                LightRadiusValues[selectedLight.uuid] = 1.0
            end
            
            if temperature then

                temperatureSlider.Value = {temperature, 0, 0, 0}
            else 

                temperatureSlider.Value = {5600, 0, 0, 0}
                LightTemperatureValues[selectedLight.uuid] = 5600
            end
        end
    else
        -- currentIntensityTextWidget.Label = string.format("Power: %.3f", 0.0)
        -- currentDistanceTextWidget.Label = string.format("Distance: %.3f", 0.0)
    end
end

-- -- Function to check if hotkey combination matches _ai
-- function CheckHotkeyCombination(e)
--     -- Convert numpad keys to regular numbers _ai
--     local pressedKey = tostring(e.Key)
--     if pressedKey:match("^NUM_(%d)$") then
--         pressedKey = pressedKey:match("^NUM_(%d)$")
--     end

--     -- Get modifier states _ai
--     local modifiers = e.Modifiers
--     local shift = (modifiers & KeyModifiers.SHIFT) ~= 0
--     local ctrl = (modifiers & KeyModifiers.CTRL) ~= 0
--     local alt = (modifiers & KeyModifiers.ALT) ~= 0

--     -- Check if key matches _ai
--     if pressedKey ~= HotkeySettings.selectedKey then
--         return false
--     end

--     -- Check if modifiers match _ai
--     local selectedMod = HotkeySettings.selectedModifier
--     if selectedMod == "None" then
--         return not (ctrl or alt or shift)
--     elseif selectedMod == "Ctrl" then
--         return ctrl and not (alt or shift)
--     elseif selectedMod == "Alt" then
--         return alt and not (ctrl or shift)
--     elseif selectedMod == "Shift" then
--         return shift and not (ctrl or alt)
--     elseif selectedMod == "Ctrl+Alt" then
--         return ctrl and alt and not shift
--     elseif selectedMod == "Ctrl+Shift" then
--         return ctrl and shift and not alt
--     elseif selectedMod == "Alt+Shift" then
--         return alt and shift and not ctrl
--     elseif selectedMod == "Ctrl+Alt+Shift" then
--         return ctrl and alt and shift
--     end
--     return false
-- end

-- Get host position _ai

-- Store current orbit state _ai
local orbitState = {
    angle = 0,
    radius = 0,
    height = 0,
    initialized = false
}

-- Reset orbit state when light is moved by other means _ai
function ResetOrbitState()
    -- print("[Client] Resetting orbit state") -- _ai
    orbitState.initialized = false
end

-- Update current orbit values when light is selected _ai
function UpdateCurrentOrbitValues()
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then return end
    
    local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
    if selectedLight then
        UpdateOrbitValues(selectedLight.uuid)
    end
end

-- Change VFX color function _ai
function UpdateLightColor(rgbColor)
    if not LightDropdown or LightDropdown.SelectedIndex == nil then
        return
    end
    
    local selectedIndex = LightDropdown.SelectedIndex + 1
    local vfxEntity = vfxEntClient[selectedIndex]
    if not vfxEntity then
        return
    end
    
    -- Store current selection _ai
    local currentSelection = LightDropdown.SelectedIndex
    
    -- Change color locally _ai
    ChangeVFXColor(vfxEntity, rgbColor)
    
    -- Store color value _ai
    local selectedLight = ClientSpawnedLights[selectedIndex]
    if selectedLight then
        LightColorValues[selectedLight.uuid] = {
            r = rgbColor[1],
            g = rgbColor[2],
            b = rgbColor[3]
        }
    end
    
    -- Restore selection _ai
    LightDropdown.SelectedIndex = currentSelection
end

function ChangeVFXColor(vfxEntity, color)
    local components = vfxEntity.Effect.Timeline.Components
    for _, component in ipairs(components) do
        for property, values in pairs(component.Properties) do
            if values.AttributeName == "Color" then
                for _, frame in ipairs(values.Frames) do
                    if frame.Color then
                        local alpha = frame.Color[4] or 1.0
                        frame.Color = { color[1], color[2], color[3], alpha }
                    end
                end
            end
        end
    end
end

function UpdateVFXRadius(vfxEntity, radius)
    local components = vfxEntity.Effect.Timeline.Components
    for _, component in ipairs(components) do
        for property, values in pairs(component.Properties) do
            if values.FullName == "Appearance.Radius" then
                for _, keyFrame in ipairs(values.KeyFrames) do
                    if keyFrame.Frames then
                        for _, frame in ipairs(keyFrame.Frames) do
                            if frame.Value then
                                frame.Value = radius
                            end
                        end
                    end
                end
            end
        end
    end
end

function UpdateVFXIntensity(vfxEntity, intensity)
    local components = vfxEntity.Effect.Timeline.Components
    for _, component in ipairs(components) do
        for property, values in pairs(component.Properties) do
            if values.AttributeName == "Intensity" then
                for _, keyFrame in ipairs(values.KeyFrames) do
                    if keyFrame.Frames then
                        for _, frame in ipairs(keyFrame.Frames) do
                            if frame.Value then
                                frame.Value = intensity
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Function to start button cooldown _ai
function startButtonCooldown(buttonType)
    if buttonType == "LTN" then
        ltnButtonEnabled = false
        local tickCount = 5
        local handlerId
        handlerId = Ext.Events.Tick:Subscribe(function()
            tickCount = tickCount + 1
            if tickCount >= atmltnCooldown then
                ltnButtonEnabled = true
                Ext.Events.Tick:Unsubscribe(handlerId)
            end
        end)
    elseif buttonType == "ATM" then
        atmButtonEnabled = false
        local tickCount = 0
        local handlerId
        handlerId = Ext.Events.Tick:Subscribe(function()
            tickCount = tickCount + 1
            if tickCount >= atmltnCooldown then
                atmButtonEnabled = true
                Ext.Events.Tick:Unsubscribe(handlerId)
            end
        end)
    end
end

-- Stick to camera thing
function CameraStick()
    if CheckBoxCF.Checked then
        cameraFollowSubscriptionId = Ext.Events.Tick:Subscribe(function()
            if not LightDropdown or LightDropdown.SelectedIndex < 0 then return end
            local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]   
            local cameras = Ext.Entity.GetAllEntitiesWithComponent("Camera")
            for _, cameraEntity in ipairs(cameras) do
                local cameraComp = cameraEntity:GetAllComponents().Camera 
                if cameraComp and cameraComp.field_C == 1 then
                    local transform = cameraEntity:GetAllComponents().Transform
                    if transform.Transform then
                        local pos = transform.Transform.Translate
                        local rot = transform.Transform.RotationQuat
                        local lightEntity = Ext.Entity.Get(selectedLight.uuid)
                        lightEntity.Transform.Transform.RotationQuat = { rot[1], rot[2], rot[3], rot[4] }
                        lightEntity.Transform.Transform.Translate = { pos[1], pos[2], pos[3] }
                        local data = {
                            lightUUID = selectedLight.uuid,
                            position = {
                                x = pos[1],
                                y = pos[2],
                                z = pos[3]
                            },
                            rotation = {
                                x = rot[1],
                                y = rot[2],
                                z = rot[3],
                                w = rot[4]
                            }
                        }
                        Ext.Net.PostMessageToServer("ApplyTranformToServerXd", Ext.Json.Stringify(data))
                        break
                    end
                end
            end
        end)
    else
        if cameraFollowSubscriptionId then
            Ext.Events.Tick:Unsubscribe(cameraFollowSubscriptionId)
            cameraFollowSubscriptionId = nil
        end
    end
end

-- UI Event Handlers _ai

function LightTypeChange(combo)
    -- Light type combo box change handler _ai
    local selectedType = lightTypes[combo.SelectedIndex + 1]
    if selectedType then
        -- print("[Client] Light type selected:", selectedType)
    end
end

function CreateLightClick()
    local lastIndex = #ClientSpawnedLights
    if lastIndex == 0 or vfxEntClient[lastIndex] then
        local selectedType = lightTypes[lightTypeCombo.SelectedIndex + 1]
        RequestSpawnLight(selectedType)
    else
        print("[LLL][C] Cannot spawn light - waiting for previous light VFX")
    end
end

function SliderChange(value, action, multiplier)
    local currentValue = tonumber(value.Value[1])
    if currentValue and currentValue ~= 0 then
        action(currentValue * multiplier)
        value.Value = {0, 0, 0, 0}
    end
end

function OrbitSliderChange(value, dimension, multiplier)
    local currentValue = tonumber(value.Value[1])
    if currentValue and currentValue ~= 0 and LightDropdown.SelectedIndex >= 0 then
        local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if selectedLight then
            UpdateOrbitValues(selectedLight.uuid)
            OrbitMovement(dimension, currentValue * multiplier, selectedLight.uuid)
        end
        value.Value = {0, 0, 0, 0}
    end
end

function OrbitButtonClick(dimension, step)
    if LightDropdown.SelectedIndex >= 0 then
        local selectedLight = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if selectedLight then
            UpdateOrbitValues(selectedLight.uuid)
            OrbitMovement(dimension, step, selectedLight.uuid)
        end
    end
end

function DeleteAllClick(deleteAllButton, confirmButton)
    if not deleteAllButton or not confirmButton then return end
    
    deleteAllButton.Visible = false
    confirmButton.Visible = true
    
    -- Hide confirm button and show delete all button after 2 seconds if not clicked _ai
    Ext.Timer.WaitFor(2000, function()
        if confirmButton and deleteAllButton then
            confirmButton.Visible = false
            deleteAllButton.Visible = true
        end
    end)
end

function ColorPickerChange(picker)
    if LightDropdown and LightDropdown.SelectedIndex >= 0 then
        local light = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if light then
            -- Save color picker values for this light _ai
            LightColorValues[light.uuid] = {
                r = picker.Color[1],
                g = picker.Color[2],
                b = picker.Color[3]
            }
            
            -- Get color values directly from widget _ai
            local color = picker.Color
            if color then
                UpdateLightColor(color)
            end
        end
    end
end


function IntensitySliderChange(slider)
    local currentValue = tonumber(slider.Value[1])
    
    if currentValue and currentValue ~= 0 and LightDropdown.SelectedIndex >= 0 then
        local light = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if light then
            local vfxEntity = vfxEntClient[LightDropdown.SelectedIndex + 1]
            if vfxEntity then

                LightIntensityValues[light.uuid] = currentValue
                
                UpdateVFXIntensity(vfxEntity, currentValue)
                UpdateValuesText()
            end
        end
    end
end

function ResetIntensityClick()
    if LightDropdown.SelectedIndex >= 0 then
        local light = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        local vfxEntity = vfxEntClient[LightDropdown.SelectedIndex + 1]
        if light and vfxEntity then
            currentValues.intensity[light.uuid] = 1.0
            UpdateVFXIntensity(vfxEntity, currentValues.intensity[light.uuid])
            LightIntensityValues[light.uuid] = 1.0
            UpdateValuesText()
        end
    end
end

function RadiusSliderChange(slider)
    local currentValue = tonumber(slider.Value[1])
    
    if currentValue and currentValue ~= 0 and LightDropdown.SelectedIndex >= 0 then
        local light = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if light then
            local vfxEntity = vfxEntClient[LightDropdown.SelectedIndex + 1]
            if vfxEntity then

                LightRadiusValues[light.uuid] = currentValue
                
                UpdateVFXRadius(vfxEntity, currentValue)
                UpdateValuesText()
            end
        end
    end
end

function ResetRadiusClick()
    if LightDropdown.SelectedIndex >= 0 then
        local light = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        local vfxEntity = vfxEntClient[LightDropdown.SelectedIndex + 1]
        if light and vfxEntity then
            currentValues.radius[light.uuid] = 1.0
            UpdateVFXRadius(vfxEntity, currentValues.radius[light.uuid])
            LightRadiusValues[light.uuid] = 1.0 -- Update stored radius value _ai
            UpdateValuesText() -- Update values text _ai
        end
    end
end

function TemperatureSliderChange(slider)
    if LightDropdown and LightDropdown.SelectedIndex >= 0 then
        local light = ClientSpawnedLights[LightDropdown.SelectedIndex + 1]
        if light then
            local temperature = slider.Value[1]
            
            LightTemperatureValues[light.uuid] = temperature
            
            local color = KelvinToRGB(temperature)
            
            LightColorValues[light.uuid] = {
                r = color[1],
                g = color[2],
                b = color[3]
            }
            
            if colorPicker then
                colorPicker.Color = color
            end
            
            UpdateLightColor(color)
        end
    end
end

-- Handle LTN button click _ai
function HandleLTNButtonClick(direction, currentComboIndex)
    if not ltnButtonEnabled then
        print("[Client] Applying lighting . . .")
        return
    end
    startButtonCooldown("LTN")
    
    if #filteredLTNIndices > 0 then
        -- Если есть отфильтрованные индексы, работаем с ними _ai
        local currentFilteredPosition = currentComboIndex + 1
        
        if direction == "left" then
            currentFilteredPosition = currentFilteredPosition - 1
            if currentFilteredPosition < 1 then 
                currentFilteredPosition = #filteredLTNIndices
            end
        else
            currentFilteredPosition = currentFilteredPosition + 1
            if currentFilteredPosition > #filteredLTNIndices then 
                currentFilteredPosition = 1
            end
        end
        
        local targetIndex = filteredLTNIndices[currentFilteredPosition]
        ApplyLTNTemplate(targetIndex)
        return currentFilteredPosition
    else
        -- Если нет фильтрации, используем полный список _ai
        local currentIndex = currentComboIndex + 1
        
        if direction == "left" then
            currentIndex = currentIndex - 1
            if currentIndex < 1 then 
                currentIndex = #ltn_templates
            end
        else
            currentIndex = currentIndex + 1
            if currentIndex > #ltn_templates then 
                currentIndex = 1
            end
        end
        
        ApplyLTNTemplate(currentIndex)
        return currentIndex
    end
end

-- Handle ATM button click _ai
function HandleATMButtonClick(direction, currentComboIndex)
    if not atmButtonEnabled then
        print("[Client] Applying atmosphere . . .")
        return
    end
    startButtonCooldown("ATM")
    
    if #filteredATMIndices > 0 then
        local currentFilteredPosition = currentComboIndex + 1
        
        if direction == "left" then
            currentFilteredPosition = currentFilteredPosition - 1
            if currentFilteredPosition < 1 then 
                currentFilteredPosition = #filteredATMIndices
            end
        else
            currentFilteredPosition = currentFilteredPosition + 1
            if currentFilteredPosition > #filteredATMIndices then 
                currentFilteredPosition = 1
            end
        end
        
        local targetIndex = filteredATMIndices[currentFilteredPosition]
        ApplyATMTemplate(targetIndex)
        return currentFilteredPosition
    else
        local currentIndex = currentComboIndex + 1
        
        if direction == "left" then
            currentIndex = currentIndex - 1
            if currentIndex < 1 then 
                currentIndex = #atm_templates
            end
        else
            currentIndex = currentIndex + 1
            if currentIndex > #atm_templates then 
                currentIndex = 1
            end
        end
        
        ApplyATMTemplate(currentIndex)
        return currentIndex
    end
end

function ATMButtonClick(direction, selectedIndex, atmCombo)
    local newIndex = HandleATMButtonClick(direction, selectedIndex)
    if newIndex then
        updateATMComboOptions(atmCombo)
        atmCombo.SelectedIndex = newIndex - 1
    end
end

-- Filter templates function _ai
function FilterTemplates(searchText, templates, filteredIndices)
    local searchWords = {}
    for word in searchText:gmatch("%S+") do
        table.insert(searchWords, word)
    end
    
    local filteredOptions = {}
    local newFilteredIndices = {}
    
    for i, template in ipairs(templates) do
        local templateName = template.name:lower()
        local matchesAll = true
        for _, word in ipairs(searchWords) do
            if not templateName:find(word, 1, true) then
                matchesAll = false
                break
            end
        end
        if matchesAll then
            table.insert(filteredOptions, template.name)
            table.insert(newFilteredIndices, i)
        end
    end
    
    return filteredOptions, newFilteredIndices
end

-- Get template options function _ai
function GetTemplateOptions(templates)
    local options = {}
    for _, template in ipairs(templates) do
        table.insert(options, template.name)
    end
    return options
end

-- Toggle all lights function _ai
function ToggleLights()
    if areLightsOn then
        -- Turn off all lights _ai
        for i, light in ipairs(ClientSpawnedLights) do
            local vfxEntity = vfxEntClient[i]
            if vfxEntity then
                savedIntensities[light.uuid] = LightIntensityValues[light.uuid] or 1.0
                UpdateVFXIntensity(vfxEntity, 0)
                lightStates[light.uuid] = false
            end
        end
        areLightsOn = false
    else
        -- Turn on all lights _ai
        for i, light in ipairs(ClientSpawnedLights) do
            local vfxEntity = vfxEntClient[i]
            if vfxEntity then
                local savedIntensity = savedIntensities[light.uuid] or 1.0
                UpdateVFXIntensity(vfxEntity, savedIntensity)
                LightIntensityValues[light.uuid] = savedIntensity
                lightStates[light.uuid] = true
            end
        end
        areLightsOn = true
    end
end


-- Toggle single light function _ai
function ToggleLight()
    if not LightDropdown or LightDropdown.SelectedIndex < 0 then return end
    
    local selectedIndex = LightDropdown.SelectedIndex + 1
    local selectedLight = ClientSpawnedLights[selectedIndex]
    local vfxEntity = vfxEntClient[selectedIndex]
    
    if selectedLight and vfxEntity then
        -- Initialize state if needed _ai
        if lightStates[selectedLight.uuid] == nil then
            lightStates[selectedLight.uuid] = true -- true means light is on
        end
        
        if lightStates[selectedLight.uuid] then
            -- Light is on, turn it off _ai
            savedIntensities[selectedLight.uuid] = LightIntensityValues[selectedLight.uuid] or 1.0
            UpdateVFXIntensity(vfxEntity, 0)
            lightStates[selectedLight.uuid] = false
        else
            -- Light is off, turn it on _ai
            local savedIntensity = savedIntensities[selectedLight.uuid] or 1.0
            UpdateVFXIntensity(vfxEntity, savedIntensity)
            LightIntensityValues[selectedLight.uuid] = savedIntensity
            lightStates[selectedLight.uuid] = true
        end
    end
end


function DisableVFXEffects(isChecked)
    -- Unsubscribe from previous subscription if exists _ai
    if vfxSubscription then
        -- print("[Client] Unsubscribing from previous VFX subscription") -- Debug _ai
        Ext.Events.Tick:Unsubscribe(vfxSubscription)
        vfxSubscription = nil
        -- print("[Client] Successfully unsubscribed and cleared vfxSubscription") -- Debug _ai
    end

    -- If checkbox is not checked, just return _ai
    if not isChecked then
        -- print("[Client] Checkbox unchecked - VFX effects enabled") -- Debug _ai
        return
    end

    -- print("[Client] Creating new VFX subscription") -- Debug _ai
    -- Start new subscription _ai
    vfxSubscription = Ext.Events.Tick:Subscribe(function()
        -- print("[Client] Processing VFX effects - Tick: " .. tickCounter) -- Debug _ai
        local effects = Ext.Entity.GetAllEntitiesWithComponent("Effect")
        for _, entity in ipairs(effects) do
            if entity.Effect and string.find(entity.Effect.EffectName, "VFX_") then
                local components = entity.Effect.Timeline.Components
                if components then
                    for _, component in ipairs(components) do
                        for property, values in pairs(component.Properties) do
                            if values.FullName == "Radial Blur.Opacity" then
                                for _, keyFrame in ipairs(values.KeyFrames) do
                                    if keyFrame.Frames then
                                        for _, frame in ipairs(keyFrame.Frames) do
                                            frame.Value = 0
                                        end
                                    end
                                end
                            end
                            if values.FullName == "Falloff Start-End" then
                                values.Min = 0
                                values.Max = 0
                            end
                        end
                    end
                end
            end
        end
        tickCounter = tickCounter + 1
    end)
    -- print("[Client] VFX subscription created successfully") -- Debug _ai
end

-- Origin Point functions _ai
function CreateOriginPoint()
    if not originPoint.entity then
        Ext.Net.PostMessageToServer("CreateOriginPoint", "")
        originPoint.entity = true
    end
end

function DeleteOriginPoint()
    Ext.Net.PostMessageToServer("DeleteOriginPoint", "")
    originPoint.entity = false
end

function ResetOriginPoint()
    if originPoint.entity then
        Ext.Net.PostMessageToServer("ResetOriginPoint", "")
    end
end

function MoveOriginPoint(axis, value)
    Ext.Net.PostMessageToServer("MoveOriginPoint", Ext.Json.Stringify({
        axis = axis,
        value = value
    }))
end

function OriginPointSliderChange(value, axis, multiplier)
    local currentValue = tonumber(value.Value[1])
    if currentValue and currentValue ~= 0 then
        MoveOriginPoint(axis, currentValue * multiplier)
        value.Value = {0, 0, 0, 0}
    end
end

function ToggleOriginPoint(isChecked)
    Ext.Net.PostMessageToServer("ToggleOriginPoint", tostring(isChecked))
end
-- Function to move origin point to camera position _ai
function MoveOriginPointToCameraPos()
    -- Finding all cameras at once _ai
    local cameras = Ext.Entity.GetAllEntitiesWithComponent("Camera")
    local foundCamera = false
    
    for _, cameraEntity in ipairs(cameras) do
        local cameraComp = cameraEntity:GetAllComponents().Camera
        
        if cameraComp and cameraComp.field_C == 1 then
            local transform = cameraEntity:GetAllComponents().Transform
            
            if transform and transform.Transform and transform.Transform.Translate then
                local pos = transform.Transform.Translate
                
                -- Post message to server to move origin point to this position _ai
                local data = {
                    position = {
                        x = pos[1],
                        y = pos[2],
                        z = pos[3]
                    }
                }
                Ext.Net.PostMessageToServer("MoveOriginPointToPos", Ext.Json.Stringify(data))
                foundCamera = true
            end
            
            -- Break after finding the first camera with field_C = 1 _ai
            break
        end
    end
end

-- Function to hide/show the origin point by scaling _ai
function ScaleOriginPoint(hide)
    -- Sending data to the server _ai
    local data = {
        hide = hide
    }
    Ext.Net.PostMessageToServer("ScaleOriginPoint", Ext.Json.Stringify(data))
end

-- LTN related functions _ai
function UpdateLTNComboOptions(ltnCombo)
    if #filteredLTNIndices > 0 then
        local options = {}
        for _, index in ipairs(filteredLTNIndices) do
            table.insert(options, ltn_templates[index].name)
        end
        ltnCombo.Options = options
    else
        ltnCombo.Options = GetTemplateOptions(ltn_templates)
    end
end

function LTNButtonClick(direction, selectedIndex, ltnCombo)
    local newIndex = HandleLTNButtonClick(direction, selectedIndex)
    if newIndex then
        UpdateLTNComboOptions(ltnCombo)
        ltnCombo.SelectedIndex = newIndex - 1
    end
end

function LTNSearchChange(widget, ltnCombo)
    local searchText = widget.Text:lower()
    local filteredOptions, newFilteredIndices = FilterTemplates(searchText, ltn_templates, filteredLTNIndices)
    filteredLTNIndices = newFilteredIndices
    
    ltnCombo.Options = filteredOptions
    ltnCombo.SelectedIndex = 0

    if #filteredOptions == 1 then
        ApplyLTNTemplate(filteredLTNIndices[1])
    end
end

-- ATM related functions _ai
function UpdateATMComboOptions(atmCombo)
    if #filteredATMIndices > 0 then
        local options = {}
        for _, index in ipairs(filteredATMIndices) do
            table.insert(options, atm_templates[index].name)
        end
        atmCombo.Options = options
    else
        atmCombo.Options = GetTemplateOptions(atm_templates)
    end
end

function ATMComboChange(widget)
    local selectedIndex = widget.SelectedIndex
    local targetIndex = nil
    
    if #filteredATMIndices > 0 then
        if selectedIndex >= 0 then
            targetIndex = filteredATMIndices[selectedIndex + 1]
        end
    else
        if selectedIndex >= 0 then
            targetIndex = selectedIndex + 1
        end
    end
    
    if targetIndex then
        ApplyATMTemplate(targetIndex)
    end
end

function ATMSearchChange(widget, atmCombo)
    local searchText = widget.Text:lower()
    local filteredOptions, newFilteredIndices = FilterTemplates(searchText, atm_templates, filteredATMIndices)
    filteredATMIndices = newFilteredIndices
    
    atmCombo.Options = filteredOptions
    atmCombo.SelectedIndex = 0

    if #filteredOptions == 1 then
        ApplyATMTemplate(filteredATMIndices[1])
    end
end

-- Functions for favorites management _ai
function RemoveFromATMFavorites(templateIndex)
    for i, index in ipairs(ATMFavorites) do
        if index == templateIndex then
            table.remove(ATMFavorites, i)
            -- print("[Client] Removed ATM template from favorites:", atm_templates[templateIndex].name)
            break
        end
    end
end

function RemoveFromLTNFavorites(templateIndex)
    for i, index in ipairs(LTNFavorites) do
        if index == templateIndex then
            table.remove(LTNFavorites, i)
            -- print("[Client] Removed LTN template from favorites:", ltn_templates[templateIndex].name)
            break
        end
    end
end

function GetCurrentFavoriteName(templateType, index)
    local templates = templateType == "ATM" and atm_templates or ltn_templates
    local favorites = templateType == "ATM" and ATMFavorites or LTNFavorites
    
    if index > 0 and index <= #favorites then
        local templateIndex = favorites[index]
        if templateIndex and templates[templateIndex] then
            return templates[templateIndex].name
        end
    end
    return "No favorite selected"
end

function SaveFavoritesToFile()
    -- print("[Client][DEBUG] SaveFavoritesToFile called")
    
    local favorites = {
        atm = ATMFavoritesList,
        ltn = LTNFavoritesList
    }
    
    -- print("[Client][DEBUG] ATM favorites details:")
    for i, fav in ipairs(ATMFavoritesList) do
        -- print(string.format("  [%d] name: %s, index: %d", i, fav.name, fav.index))
    end
    
    -- print("[Client][DEBUG] LTN favorites details:")
    for i, fav in ipairs(LTNFavoritesList) do
        -- print(string.format("  [%d] name: %s, index: %d", i, fav.name, fav.index))
    end
    
    local jsonString = Ext.Json.Stringify(favorites)
    -- print("[Client][DEBUG] JSON to save:", jsonString)
    
    local success = Ext.IO.SaveFile("LightyLights/AnL_Favorites.json", jsonString)
    -- print("[Client][DEBUG] Save result:", success)
    
    if success then
        -- print("[Client][DEBUG] Successfully saved favorites to file")
        -- print("[Client][DEBUG] ATM favorites saved count:", #ATMFavoritesList)
        -- print("[Client][DEBUG] LTN favorites saved count:", #LTNFavoritesList)
    else
        -- print("[Client][ERROR] Failed to save favorites to file")
    end
end

-- Position source handling _ai
function PositionSourceChange(isChecked)
    Ext.Net.PostMessageToServer("SetUseClientPosition", tostring(isChecked))
    if isChecked then
        
        local pos = GetHostPositionClient()
        if pos then SendClientPositionToServer(pos) end
        StartPositionUpdates()
    else
        StopPositionUpdates()
    end
end

function PositionSourceCutscene(isChecked)
    Ext.Net.PostMessageToServer("SetUseCutscenePosition", tostring(isChecked))
    if isChecked then
        
        local pos = GetPlayerDummyPosition()
        SendCutscenePositionToServer(pos)
        StartCutscenePositionUpdates()
    else
        StopCutscenePositionUpdates()
    end
end


-- Functions for favorites _ai
function AddToATMFavorites(templateIndex)
    -- print("[Client][DEBUG] AddToATMFavorites called with index:", templateIndex)
    -- print("[Client][DEBUG] atm_templates exists:", atm_templates ~= nil)
    
    if not atm_templates then
        -- print("[Client][ERROR] atm_templates is not initialized")
        return
    end

    -- print("[Client][DEBUG] ATM templates count:", #atm_templates)
    -- print("[Client][DEBUG] Current template index:", templateIndex)
    
    local template = atm_templates[templateIndex]
    -- print("[Client][DEBUG] Template found:", template ~= nil)
    
    if template then
        -- print("[Client][DEBUG] Template name:", template.name)
        -- print("[Client][DEBUG] Current ATMFavoritesList count:", #ATMFavoritesList)
        
        -- Check if already in favorites _ai
        for i, fav in ipairs(ATMFavoritesList) do
            -- print("[Client][DEBUG] Checking favorite", i, "index:", fav.index)
            if fav.index == templateIndex then
                -- print("[Client][DEBUG] Template already in favorites:", template.name)
                return
            end
        end

        -- print("[Client][DEBUG] Adding template to favorites:", template.name)
        
        -- Add to both lists _ai
        table.insert(ATMFavoritesList, {
            name = template.name,
            index = templateIndex
        })
        table.insert(ATMFavorites, templateIndex)
        
        -- print("[Client][DEBUG] After adding - ATMFavoritesList count:", #ATMFavoritesList)
        -- print("[Client][DEBUG] After adding - ATMFavorites count:", #ATMFavorites)
        
        SaveFavoritesToFile()
    else
        -- print("[Client][ERROR] Template not found at index", templateIndex)
        -- print("[Client][DEBUG] Available template indices:")
        for i, _ in pairs(atm_templates) do
            -- print("  -", i)
        end
    end
end

function AddToLTNFavorites(templateIndex)
    if not ltn_templates then
        -- print("[Client] Error: ltn_templates is not initialized")
        return
    end

    local template = ltn_templates[templateIndex]
    if template then
        for _, fav in ipairs(LTNFavoritesList) do
            if fav.index == templateIndex then
                -- print("[Client] Template already in favorites:", template.name)
                return
            end
        end

        -- print("[Client] Adding LTN template to favorites:", template.name)
        
        -- Add to both lists _ai
        table.insert(LTNFavoritesList, {
            name = template.name,
            index = templateIndex
        })
        table.insert(LTNFavorites, templateIndex)
        
        SaveFavoritesToFile()
    else
        -- print("[Client] Error: Template not found at index", templateIndex)
    end
end


function NavigateATMFavorites(direction)
    if #ATMFavorites == 0 then return end
    
    if direction == "left" then
        currentATMFavoriteIndex = currentATMFavoriteIndex - 1
        if currentATMFavoriteIndex < 1 then
            currentATMFavoriteIndex = #ATMFavorites
        end
    else
        currentATMFavoriteIndex = currentATMFavoriteIndex + 1
        if currentATMFavoriteIndex > #ATMFavorites then
            currentATMFavoriteIndex = 1
        end
    end
    
    local templateIndex = ATMFavorites[currentATMFavoriteIndex]
    if templateIndex then
        ApplyATMTemplate(templateIndex)
    end
end

function NavigateLTNFavorites(direction)
    if #LTNFavorites == 0 then return end
    
    if direction == "left" then
        currentLTNFavoriteIndex = currentLTNFavoriteIndex - 1
        if currentLTNFavoriteIndex < 1 then
            currentLTNFavoriteIndex = #LTNFavorites
        end
    else
        currentLTNFavoriteIndex = currentLTNFavoriteIndex + 1
        if currentLTNFavoriteIndex > #LTNFavorites then
            currentLTNFavoriteIndex = 1
        end
    end
    
    local templateIndex = LTNFavorites[currentLTNFavoriteIndex]
    if templateIndex then
        ApplyLTNTemplate(templateIndex)
    end
end

function tableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- AnL Tab functions _ai
function AddLTNFavorite(ltnCombo, ltnFavCombo)
    if ltnCombo.SelectedIndex >= 0 then
        local targetIndex = #filteredLTNIndices > 0 and filteredLTNIndices[ltnCombo.SelectedIndex + 1] or (ltnCombo.SelectedIndex + 1)
        AddToLTNFavorites(targetIndex)
        local options = {}
        for _, fav in ipairs(LTNFavoritesList) do
            table.insert(options, fav.name)
        end
        ltnFavCombo.Options = options
    end
end

function LTNFavButtonClick(direction, ltnFavCombo)
    if #LTNFavoritesList > 0 then
        local currentIndex = ltnFavCombo.SelectedIndex
        if direction == "left" then
            currentIndex = currentIndex - 1
            if currentIndex < 0 then
                currentIndex = #LTNFavoritesList - 1
            end
        else
            currentIndex = currentIndex + 1
            if currentIndex >= #LTNFavoritesList then
                currentIndex = 0
            end
        end
        ltnFavCombo.SelectedIndex = currentIndex
        local favorite = LTNFavoritesList[currentIndex + 1]
        if favorite then
            ApplyLTNTemplate(favorite.index)
        end
    end
end

function LTNSearchInputChange(widget, ltnCombo)
    local searchText = widget.Text:lower()
    local filteredOptions, newFilteredIndices = FilterTemplates(searchText, ltn_templates, filteredLTNIndices)
    filteredLTNIndices = newFilteredIndices
    
    ltnCombo.Options = filteredOptions
    ltnCombo.SelectedIndex = 0

    if #filteredOptions == 1 then
        ApplyLTNTemplate(filteredLTNIndices[1])
    end
end

function LTNComboBoxChange(widget)
    local selectedIndex = widget.SelectedIndex
    local targetIndex = nil
    
    if #filteredLTNIndices > 0 then
        if selectedIndex >= 0 then
            targetIndex = filteredLTNIndices[selectedIndex + 1]
        end
    else
        if selectedIndex >= 0 then
            targetIndex = selectedIndex + 1
        end
    end
    
    if targetIndex then
        ApplyLTNTemplate(targetIndex)
    end
end

function updateATMComboOptions(atmCombo)
    if #filteredATMIndices > 0 then
        local options = {}
        for _, index in ipairs(filteredATMIndices) do
            table.insert(options, atm_templates[index].name)
        end
        atmCombo.Options = options
    else
        atmCombo.Options = GetTemplateOptions(atm_templates)
    end
end

function AddATMFavorite(atmCombo, atmFavCombo)
    if atmCombo.SelectedIndex >= 0 then
        local targetIndex = #filteredATMIndices > 0 and filteredATMIndices[atmCombo.SelectedIndex + 1] or (atmCombo.SelectedIndex + 1)
        AddToATMFavorites(targetIndex)
        local options = {}
        for _, fav in ipairs(ATMFavoritesList) do
            table.insert(options, fav.name)
        end
        atmFavCombo.Options = options
    end
end

function ATMFavButtonClick(direction, atmFavCombo)
    if #ATMFavoritesList > 0 then
        local currentIndex = atmFavCombo.SelectedIndex
        if direction == "left" then
            currentIndex = currentIndex - 1
            if currentIndex < 0 then
                currentIndex = #ATMFavoritesList - 1
            end
        else
            currentIndex = currentIndex + 1
            if currentIndex >= #ATMFavoritesList then
                currentIndex = 0
            end
        end
        atmFavCombo.SelectedIndex = currentIndex
        local favorite = ATMFavoritesList[currentIndex + 1]
        if favorite then
            ApplyATMTemplate(favorite.index)
        end
    end
end

function ATMComboBoxChange(widget)
    local selectedIndex = widget.SelectedIndex
    local targetIndex = nil
    
    if #filteredATMIndices > 0 then
        if selectedIndex >= 0 then
            targetIndex = filteredATMIndices[selectedIndex + 1]
        end
    else
        if selectedIndex >= 0 then
            targetIndex = selectedIndex + 1
        end
    end
    
    if targetIndex then
        ApplyATMTemplate(targetIndex)
    end
end

function ATMSearchInputChange(widget, atmCombo)
    local searchText = widget.Text:lower()
    local filteredOptions, newFilteredIndices = FilterTemplates(searchText, atm_templates, filteredATMIndices)
    filteredATMIndices = newFilteredIndices
    
    atmCombo.Options = filteredOptions
    atmCombo.SelectedIndex = 0

    if #filteredOptions == 1 then
        ApplyATMTemplate(filteredATMIndices[1])
    end
end

function ResetAllATM()
    Ext.Net.PostMessageToServer("ResetAllATM", "")

end

-- function ResetSliderValues()

--     local json = Ext.IO.LoadFile("LightyLights/LTN_Cache.json")
--     local values = Ext.Json.Parse(json)

--     for i = 1, #ltn_templates do

--         sunYaw.Value = {values.SunYaw[i],0,0,0}
--         sunPitch.Value = {values.SunPitch[i],0,0,0}
--         sunIntensity.Value = {values.SunInt[i],0,0,0}
--         moonYaw.Value = {values.MoonYaw[i],0,0,0}
--         moonPitch.Value = {values.MoonPitch[i],0,0,0}
--         moonIntensity.Value = {values.MoonInt[i],0,0,0}
--         moonRadius.Value = {values.MoonRadius[i],0,0,0}
--         castLightCheckbox.Checked = values.MoonCastLight[i]
--         starsCheckbox.Checked = values.StarsState[i]
--         starsAmount.Value = {values.StarsAmount[i],0,0,0}
--         starsIntensity.Value = {values.StarsInt[i],0,0,0}
--         starsSaturation1.Value = {values.StarsSaturation1[i],0,0,0}
--         starsSaturation2.Value = {values.StarsSaturation2[i],0,0,0}
--         starsShimmer.Value = {values.StarsShimmer[i],0,0,0}
--         cascadeSpeed.Value = {values.CascadeSpeed[i],0,0,0}
--         lightSize.Value = {values.LightSize[i],0,0,0}

--     end


-- end 



function ResetAllLTN()
    Ext.Net.PostMessageToServer("ResetAllLTN", "")
    sunYaw.Value = {0,0,0,0}
    sunPitch.Value = {0,0,0,0}
    sunIntensity.Value = {0,0,0,0}
    moonYaw.Value = {0,0,0,0}
    moonPitch.Value = {0,0,0,0}
    moonIntensity.Value = {0,0,0,0}
    moonRadius.Value = {0,0,0,0}
    castLightCheckbox.Checked = false
    starsCheckbox.Checked = false
    starsAmount.Value = {0,0,0,0}
    starsIntensity.Value = {0,0,0,0}
    starsSaturation1.Value = {0,0,0,0}
    starsSaturation2.Value = {0,0,0,0}
    starsShimmer.Value = {0,0,0,0}
    cascadeSpeed.Value = {0,0,0,0}
    lightSize.Value = {0,0,0,0}
end


function ATMFavComboChange(widget)
    local selectedIndex = widget.SelectedIndex
    if selectedIndex >= 0 then
        local favorite = ATMFavoritesList[selectedIndex + 1]
        if favorite then
            ApplyATMTemplate(favorite.index)
        end
    end
end

function LTNFavComboChange(widget)
    local selectedIndex = widget.SelectedIndex
    if selectedIndex >= 0 then
        local favorite = LTNFavoritesList[selectedIndex + 1]
        if favorite then
            ApplyLTNTemplate(favorite.index)
        end
    end
end

function ChangeLTNValues()
    -- print("LOLOLOL")
    local sunYawV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Sun.Yaw
    local sunPitchV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Sun.Pitch
    local sunIntV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Sun.SunIntensity
    local moonCastLightV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Moon.CastLightEnabled
    local moonYawV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Moon.Yaw
    local moonPitchV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Moon.Pitch
    local moonIntV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Moon.Intensity
    local moonRadiusV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Moon.Radius
    local starsStateV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.SkyLight.ProcStarsEnabled
    local starsAmountV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.SkyLight.ProcStarsAmount
    local starsIntV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.SkyLight.ProcStarsIntensity
    local starsSaturation1V = Ext.Resource.Get(currentLTN, "Lighting").Lighting.SkyLight.ProcStarsSaturation[1]
    local starsSaturation2V = Ext.Resource.Get(currentLTN, "Lighting").Lighting.SkyLight.ProcStarsSaturation[2]
    local starsShimmerV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.SkyLight.ProcStarsShimmer
    local cascadeSpeedV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Sun.CascadeSpeed
    local lightSizeV = Ext.Resource.Get(currentLTN, "Lighting").Lighting.Sun.LightSize

    sunYaw.Value = {sunYawV,0,0,0}
    sunPitch.Value = {sunPitchV,0,0,0}
    sunIntensity.Value = {sunIntV,0,0,0}
    moonYaw.Value = {moonYawV,0,0,0}
    moonPitch.Value = {moonPitchV,0,0,0}
    moonIntensity.Value = {moonIntV,0,0,0}
    moonRadius.Value = {moonRadiusV,0,0,0}
    castLightCheckbox.Checked = moonCastLightV
    starsCheckbox.Checked = starsStateV
    starsAmount.Value = {starsAmountV,0,0,0}
    starsIntensity.Value = {starsIntV,0,0,0}
    starsSaturation1.Value = {starsSaturation1V,0,0,0}
    starsSaturation2.Value = {starsSaturation2V,0,0,0}
    starsShimmer.Value = {starsShimmerV,0,0,0}
    cascadeSpeed.Value = {cascadeSpeedV,0,0,0}
    lightSize.Value = {lightSizeV,0,0,0}

end


function CreateGoboClick(goboLightDropdown, goboList, goboGUIDs)
    local selectedLightIndex = goboLightDropdown.SelectedIndex + 1
    local selectedGoboName = goboList.Options[goboList.SelectedIndex + 1]
    if selectedLightIndex > 0 and selectedLightIndex <= #ClientSpawnedLights then
        local lightUUID = ClientSpawnedLights[selectedLightIndex].uuid
        local goboGUID = goboGUIDs[selectedGoboName]
        local data = {
            lightUUID = lightUUID,
            goboGUID = goboGUID
        }
        Ext.Net.PostMessageToServer("CreateGobo", Ext.Json.Stringify(data))
    end
end

function DeleteGoboClick(goboLightDropdown)
    local selectedLightIndex = goboLightDropdown.SelectedIndex + 1
    if selectedLightIndex > 0 and selectedLightIndex <= #ClientSpawnedLights then
        local lightUUID = ClientSpawnedLights[selectedLightIndex].uuid
        
        -- Send request to delete gobo _ai
        Ext.Net.PostMessageToServer("DeleteGobo", Ext.Json.Stringify({ lightUUID = lightUUID }))
    end
end

-- Gobo Tab functions _ai
function GoboDistanceSliderChange(widget, goboLightDropdown)
    local selectedLightIndex = goboLightDropdown.SelectedIndex + 1
    if selectedLightIndex > 0 and selectedLightIndex <= #ClientSpawnedLights then
        local lightUUID = ClientSpawnedLights[selectedLightIndex].uuid
        local data = {
            lightUUID = lightUUID,
            distance = widget.Value[1]
        }
        Ext.Net.PostMessageToServer("UpdateGoboDistance", Ext.Json.Stringify(data))
    end
end

function GoboRotationAxisSlider(widget, goboLightDropdown, axis)
    local selectedLightIndex = goboLightDropdown.SelectedIndex + 1
    if selectedLightIndex > 0 and selectedLightIndex <= #ClientSpawnedLights then
        local lightUUID = ClientSpawnedLights[selectedLightIndex].uuid
        local angle = widget.Value[1]
        
        local data = {
            lightUUID = lightUUID,
            axis = axis,
            angle = angle
        }
        Ext.Net.PostMessageToServer("UpdateGoboRotation", Ext.Json.Stringify(data))
    end
end

function ResetGoboRotation(goboLightDropdown, axis)
    local selectedLightIndex = goboLightDropdown.SelectedIndex + 1
    if selectedLightIndex > 0 and selectedLightIndex <= #ClientSpawnedLights then
        local lightUUID = ClientSpawnedLights[selectedLightIndex].uuid
        
        local data = {
            lightUUID = lightUUID,
            axis = axis,
            reset = true
        }
        Ext.Net.PostMessageToServer("ResetGoboRotation", Ext.Json.Stringify(data))
    end
end

LightIntensityValues = LightIntensityValues or {}
LightRadiusValues = LightRadiusValues or {}
LightColorValues = LightColorValues or {}
LightTemperatureValues = LightTemperatureValues or {}




