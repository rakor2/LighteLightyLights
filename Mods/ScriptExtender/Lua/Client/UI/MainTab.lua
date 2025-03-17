LightDropdown = nil
colorPicker = nil  
lightTypeCombo = nil
goboLightDropdown = nil
ltnCombo = nil
currentIntensityTextWidget = nil
currentDistanceTextWidget = nil
local xd = false


-- Function to get list of created lights _ai
function GetLightOptions()
    local options = {}
    if ClientSpawnedLights then
        for i, light in ipairs(ClientSpawnedLights) do
            table.insert(options, light.name)
        end
    end
    return options
end

-- Global ApplyStyle function _ai
function ApplyStyle(window, styleNum)
    if not Styles[styleNum] then
        for i = 1, 6 do
            Styles[i] = {
                func = Style["MainWindow" .. (i == 1 and "" or i)]["Main" .. (i == 1 and "" or i)]
            }
        end
    end
    
    if Styles[styleNum] then 
        Styles[styleNum].func(window) 
    end
end



MCM.SetKeybindingCallback('toggle_ll_window', function()
    mw.Open = not mw.Open
end)

MCM.SetKeybindingCallback('toggle_light', function()
    ToggleLight()
end)

MCM.SetKeybindingCallback('toggle_all_lights', function()
    ToggleLights()
end)

MCM.SetKeybindingCallback('toggle_marker', function()
    ToggleMarker()
end)

MCM.SetKeybindingCallback('toggle_all_markers', function()
    ToggleAllMarkers()
end)



function MainTab2(mt2)

    if MainTab2 ~= nil then return end
    MainTab2 = mt2

    -- Create window first _ai
    mw = Ext.IMGUI.NewWindow("Lighty Lights")
    mw.Open = false

    mw.Closeable = true
    MainWindow(mw)


    -- xdText = mt2:AddText("")


    -- Add open button _ai
    openButton = mt2:AddButton("Open")
    openButton.IDContext = "OpenMainWindowButton"
    openButton.OnClick = function()
        mw.Open = not mw.Open
    end

        -- Add window close handler _ai
    mw.OnClose = function()
        mw.Open = false
        return true
    end
    
    -- local keyCombo = mt2:AddCombo("Key")
    -- keyCombo.IDContext = "HotkeyKeyCombo"
    -- keyCombo.Options = KeyboardKeys
    -- keyCombo.SelectedIndex = 0
    
    -- -- Set initial key selection _ai
    -- for i, key in ipairs(KeyboardKeys) do
    --     if key == HotkeySettings.selectedKey then
    --         keyCombo.SelectedIndex = i - 1
    --         break
    --     end
    -- end
    
    -- keyCombo.OnChange = function(widget)
    --     HotkeySettings.selectedKey = KeyboardKeys[widget.SelectedIndex + 1]
    -- end

    -- local modifierCombo = mt2:AddCombo("Modifier")
    -- modifierCombo.IDContext = "HotkeyModifierCombo"
    -- modifierCombo.Options = KeyboardModifiers
    -- modifierCombo.SelectedIndex = 0
    
    -- -- Set initial modifier selection _ai
    -- for i, modifier in ipairs(KeyboardModifiers) do
    --     if modifier == HotkeySettings.selectedModifier then
    --         modifierCombo.SelectedIndex = i - 1
    --         break
    --     end
    -- end
    
    -- modifierCombo.OnChange = function(widget)
    --     HotkeySettings.selectedModifier = KeyboardModifiers[widget.SelectedIndex + 1]
    -- end

    -- -- Register hotkey handler _ai
    -- Ext.Events.KeyInput:Subscribe(function(e)
    --     if e.Event == "KeyDown" and e.Repeat == false then
    --         if CheckHotkeyCombination(e) then
    --             openButton.OnClick()
    --         end
    --     end
    -- end)


    -- Add style switch combo _ai
    local styleCombo = mt2:AddCombo("Style")
    styleCombo.IDContext = "StyleSwitchCombo"
    styleCombo.Options = StyleNames
    styleCombo.SelectedIndex = StyleSettings.selectedStyle - 1

    styleCombo.OnChange = function(widget)
        StyleSettings.selectedStyle = widget.SelectedIndex + 1
        ApplyStyle(mw, StyleSettings.selectedStyle)
    end

    -- Apply initial style _ai
    ApplyStyle(mw, StyleSettings.selectedStyle)

        -- Add save button _ai
    local saveButton = mt2:AddButton("Save settings")
    saveButton.IDContext = "SaveSettingsButton"
    saveButton.OnClick = function()
        Settings.Save()
    end

end

function MainWindow(mw)

    Style.MainWindow.Main(mw)
    ViewportSize = Ext.IMGUI.GetViewportSize()
    mw:SetPos({ViewportSize[1]/6, ViewportSize[2]/10})
    mw:SetSize({622, 1000})
    -- mw.AlwaysAutoResize = true

    mw.Visible = true
    mw.Closeable = true
    
    -- Create one TabBar for all tabs _ai
    mainTabBar = mw:AddTabBar("LL")
    
    -- Add Main tab _ai
    mainTab = mainTabBar:AddTabItem("Main")
    MainWindowTab(mainTab)
    
    -- Add Origin Point tab _ai
    originPointTab = mainTabBar:AddTabItem("Origin point")
    OriginPointTab(originPointTab)

    -- Add AnL tab to the same TabBar _ai
    anlTab = mainTabBar:AddTabItem("AnL")
    AnLWindowTab(anlTab)

    goboTab = mainTabBar:AddTabItem("Gobo")
    GoboWindowTab(goboTab)

    -- -- Add Scene Saver tab to the same TabBar _ai
    -- sceneSaverTab = mainTabBar:AddTabItem("Scene Saver")
    -- SceneSaverWindowTab(sceneSaverTab)
    -- -- Add Settings tab to the same TabBar _ai
    -- settingsTab = mainTabBar:AddTabItem("Settings")
    -- SettingsTab(settingsTab)

end

--===============-------------------------------------------------------------------------------------------------------------------------------
-----MAIN TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function MainWindowTab(parent) -- local parent = mw

    parent:AddSeparatorText("Management")

    -- Add light type combo box _ai
    lightTypeCombo = parent:AddCombo("")
    lightTypeCombo.IDContext = "LightTypeCombo"
    lightTypeCombo.HeightLargest = true
    lightTypeCombo.Options = lightTypeNames 
    lightTypeCombo.SelectedIndex = 0
    lightTypeCombo.OnChange = function(widget)
        LightTypeChange(widget)
    end

    -- Add create button _ai
    local createButton = parent:AddButton("Create")
    createButton.IDContext = "CreateLightButton"
    Style.buttonSize.default(createButton)
    createButton.SameLine = true
    createButton.OnClick = function()
        CreateLightClick()
    end

    -- Add spawned lights combo directly to mt _ai
    LightDropdown = parent:AddCombo("Created lights")
    LightDropdown.IDContext = "LightDropdown"
    LightDropdown.HeightLargest = true

    -- Add handler for dropdown selection change _ai
    LightDropdown.OnChange = function(widget)
        LightDropdownChange(widget)
    end
    
    -- Add rename input and button directly to mt _ai
    local renameInput = parent:AddInputText("")
    renameInput.IDContext = "RenameLightInput"
    
    local renameButton = parent:AddButton("Rename")
    renameButton.IDContext = "RenameLightButton"
    Style.buttonSize.default(renameButton)
    renameButton.SameLine = true
    renameButton.OnClick = function()
        RenameLightClick(renameInput)
    end
    
    -- Add delete button _ai
    local deleteButton = parent:AddButton("Delete")
    deleteButton.IDContext = "DeleteLightButton"
    Style.buttonSize.default(deleteButton)
    deleteButton.OnClick = function()
        DeleteLight()
    end

    -- Add delete all button with confirmation _ai
    local deleteAllButton = parent:AddButton("Delete all")
    deleteAllButton.IDContext = "DeleteAllLightButton"
    Style.buttonSize.default(deleteAllButton)
    deleteAllButton.SameLine = true
    
    -- Add confirm button (initially hidden) _ai
    local confirmDeleteAllButton = parent:AddButton("Confirm")
    confirmDeleteAllButton.IDContext = "ConfirmDeleteAllButton"
    Style.buttonConfirm.default(confirmDeleteAllButton)
    confirmDeleteAllButton.SameLine = true
    confirmDeleteAllButton.Visible = false
    
    -- Add handlers for delete all functionality _ai
    deleteAllButton.OnClick = function()
        DeleteAllClick(deleteAllButton, confirmDeleteAllButton)
    end
    
    confirmDeleteAllButton.OnClick = function()
        ConfirmDeleteAllClick(deleteAllButton, confirmDeleteAllButton)
    end

    -- Add duplicate button _ai
    local duplicateButton = parent:AddButton("Duplicate")
    duplicateButton.IDContext = "DuplicateLightButton"
    duplicateButton.SameLine = true
    Style.buttonSize.default(duplicateButton)
    duplicateButton.OnClick = function()
        DuplicateLight()
    end

    -- Add replace button _ai
    local replaceButton = parent:AddButton("Replace")
    replaceButton.IDContext = "ReplaceLightButton"
    replaceButton.SameLine = true
    Style.buttonSize.default(replaceButton)
    replaceButton.OnClick = function()
        ReplaceLight()
    end

    local separatorPosSource = parent:AddSeparatorText("Character's position source")
    

    -- Add position source checkbox _ai
    local posSourceCheckbox = parent:AddCheckbox("Use client-side position")
    local useOriginPoint = parent:AddCheckbox("Use origin point")
    local tlDummyCheckbox = parent:AddCheckbox("Use cutscene position")
    local CollapsingHeaderOrbit

    posSourceCheckbox.IDContext = "PosSourceCheckbox"
    posSourceCheckbox.OnChange = function(widget)
        if widget.Checked then
            useOriginPoint.Checked = false
            tlDummyCheckbox.Checked = false
            ToggleOriginPoint(false)
            CollapsingHeaderOrbit.Label = "Character relative"
        end
        PositionSourceChange(widget.Checked)
    end

    useOriginPoint.IDContext = "UseOriginPointCheckbox"
    useOriginPoint.SameLine = true
    useOriginPoint.OnChange = function(widget)
        if widget.Checked then
            posSourceCheckbox.Checked = false
            tlDummyCheckbox.Checked = false
            PositionSourceChange(false)
            CollapsingHeaderOrbit.Label = "Origin point relative"
        else
            if not posSourceCheckbox.Checked then
                CollapsingHeaderOrbit.Label = "Character relative"
            end
        end
        ToggleOriginPoint(widget.Checked)
    end


    tlDummyCheckbox.IDContext = "CutsceneCheckbox"
    tlDummyCheckbox.Checked = false
    tlDummyCheckbox.SameLine = false
    tlDummyCheckbox.OnChange = function(widget)
        if tlDummyCheckbox.Checked then
            useOriginPoint.Checked = false
            ToggleOriginPoint(false)
            posSourceCheckbox.Checked = false
        end
        PositionSourceCutscene(widget.Checked)
    end
    
    local Separator = parent:AddSeparatorText("Parameters")

    local collapsingHeader = parent:AddCollapsingHeader("Color/Temperature/Power/Distance")

    -- Add color picker with RGB inputs _ai
    colorPicker = collapsingHeader:AddColorPicker("xd")
    colorPicker.IDContext = "LightColorPicker"
    colorPicker.NoAlpha = true
    colorPicker.Float = false
    colorPicker.PickerHueWheel = false
    colorPicker.InputRGB = true
    colorPicker.DisplayHex = true
    colorPicker.OnChange = function(widget)
        ColorPickerChange(widget)
    end

    -- Add temperature slider _ai
    local temperatureSlider = collapsingHeader:AddSlider("Temperature", 1000, 1000, 40000, 1)
    temperatureSlider.IDContext = "LightTemperatureSlider"
    temperatureSlider.OnChange = function(widget)
        TemperatureSliderChange(widget)
    end

    intensitySlider = collapsingHeader:AddSlider("", 0, -2000, 2000, 0.001)
    intensitySlider.IDContext = "LightIntensitySlider"
    intensitySliderValue = intensitySlider
    intensitySlider.OnChange = function(widget)
        IntensitySliderChange(widget)
    end

    -- Add text widgets for displaying current values _ai
    local currentIntensityText = collapsingHeader:AddText(string.format("Power: %.3f", 0.0))
    currentIntensityTextWidget = currentIntensityText
    currentIntensityText.SameLine = true

    local resetIntensityButton = collapsingHeader:AddButton("r")
    resetIntensityButton.SameLine = true
    resetIntensityButton.IDContext = "ResetIntensityButton"
    resetIntensityButton.OnClick = function()
        ResetIntensityClick()
    end

    local radiusSlider = collapsingHeader:AddSlider("", 0, 0, 60, 0.001)
    radiusSlider.IDContext = "LightRadiusSlider"
    radiusSlider.Logarithmic = true
    radiusSliderValue = radiusSlider
    radiusSlider.OnChange = function(widget)
        RadiusSliderChange(widget)
    end

    local currentDistanceText = collapsingHeader:AddText(string.format("Distance: %.3f", 0.0))
    currentDistanceTextWidget = currentDistanceText
    currentDistanceText.SameLine = true

    local resetRadiusButton = collapsingHeader:AddButton("r")
    resetRadiusButton.IDContext = "ResetRadiusButton"
    resetRadiusButton.SameLine = true
    resetRadiusButton.OnClick = function()
        ResetRadiusClick()
    end
    

    -- Add position controls separator _ai
    local Separator = parent:AddSeparatorText("Position")

    
    local CheckBoxCF = parent:AddCheckbox("Stick light to camera")
    CheckBoxCF.OnChange = function(widget)
        CameraStick(widget)
    end

    -- Add save/load position buttons _ai
    local savePositionButton = parent:AddButton("Save")
    savePositionButton.IDContext = "SavePositionButton"
    Style.buttonSize.default(savePositionButton)
    savePositionButton.OnClick = function()
        SaveLightPosition()
    end

    local loadPositionButton = parent:AddButton("Load")
    loadPositionButton.IDContext = "LoadPositionButton"
    Style.buttonSize.default(loadPositionButton)
    loadPositionButton.SameLine = true
    loadPositionButton.OnClick = function()
        LoadLightPosition()
    end

    -- Forward/Back reset button _ai
    local resetForwardBackButton = parent:AddButton("X reset")
    Style.buttonSize.default(resetForwardBackButton)
    resetForwardBackButton.IDContext = "ResetForwardBackButton"
    resetForwardBackButton.OnClick = function()
        ResetLightPosition("z")
    end

    -- Left/Right reset button _ai
    local resetLeftRightButton = parent:AddButton("Y reset")
    Style.buttonSize.default(resetLeftRightButton)
    resetLeftRightButton.IDContext = "ResetLeftRightButton"
    resetLeftRightButton.SameLine = true
    resetLeftRightButton.OnClick = function()
        ResetLightPosition("x")
    end

    -- Up/Down reset button _ai
    local resetUpDownButton = parent:AddButton("Z reset")
    Style.buttonSize.default(resetUpDownButton)
    resetUpDownButton.IDContext = "ResetUpDownButton"
    resetUpDownButton.SameLine = true
    resetUpDownButton.OnClick = function()
        ResetLightPosition("y")
    end

    -- Reset all position button _ai
    local resetAllPositionButton = parent:AddButton("Reset all")
    Style.buttonSize.default(resetAllPositionButton)
    resetAllPositionButton.SameLine = true
    resetAllPositionButton.IDContext = "ResetAllPositionButton"
    resetAllPositionButton.OnClick = function()
        ResetLightPosition("all")
    end

    -- Tilt rotation reset button _ai
    local resetTiltButton = parent:AddButton("Tilt reset")
    Style.buttonSize.default(resetTiltButton)
    resetTiltButton.IDContext = "ResetTiltButton"
    resetTiltButton.OnClick = function()
        ResetLightRotation("tilt")
    end

    -- Yaw rotation reset button _ai
    local resetYawButton = parent:AddButton("Yaw reset")
    Style.buttonSize.default(resetYawButton)
    resetYawButton.SameLine = true
    resetYawButton.OnClick = function()
        ResetLightRotation("yaw")
    end

 -- Roll rotation reset button _ai
    local resetRollButton = parent:AddButton("Roll reset")
    Style.buttonSize.default(resetRollButton)
    resetRollButton.IDContext = "ResetRollButton"
    resetRollButton.SameLine = true
    resetRollButton.OnClick = function()
        ResetLightRotation("roll")
    end

    -- Reset all rotation button _ai
    local resetAllRotationButton = parent:AddButton("Reset all")
    Style.buttonSize.default(resetAllRotationButton)
    resetAllRotationButton.SameLine = true
    resetAllRotationButton.IDContext = "ResetAllRotationButton"
    resetAllRotationButton.OnClick = function()
        ResetLightRotation("all")
    end

    CollapsingHeaderOrbit = parent:AddCollapsingHeader("Character relative")
    CollapsingHeaderOrbit.Visible = true
    
    local angleSlider = CollapsingHeaderOrbit:AddSlider("", 0, -1000, 1000, 0.001)
    angleSlider.IDContext = "AngleSlider"
    angleSlider.OnChange = function(value)
        OrbitSliderChange(value, "angle", -0.002)
    end

    -- Angle orbit buttons _ai
    local angleLeftButton = CollapsingHeaderOrbit:AddButton("<")
    angleLeftButton.SameLine = true
    angleLeftButton.OnClick = function()
        OrbitButtonClick("angle", buttonStep * 10)
    end

    local angleRightButton = CollapsingHeaderOrbit:AddButton(">")
    angleRightButton.SameLine = true
    angleRightButton.OnClick = function()
        OrbitButtonClick("angle", -buttonStep * 10)
    end

    local addtext = CollapsingHeaderOrbit:AddText("Ccw/Cw")
    addtext.SameLine = true

    local radiusSlider = CollapsingHeaderOrbit:AddSlider("", 0, -1000, 1000, 0.001)
    radiusSlider.IDContext = "RadiusSlider"
    radiusSlider.OnChange = function(value)
        OrbitSliderChange(value, "radius", 0.0001)
    end

    -- Radius orbit buttons _ai
    local radiusInButton = CollapsingHeaderOrbit:AddButton("<")
    radiusInButton.IDContext = "RadiusInButton"
    radiusInButton.SameLine = true
    radiusInButton.OnClick = function()
        OrbitButtonClick("radius", -buttonStep)
    end

    local radiusOutButton = CollapsingHeaderOrbit:AddButton(">")
    radiusOutButton.IDContext = "RadiusOutButton"
    radiusOutButton.SameLine = true
    radiusOutButton.OnClick = function()
        OrbitButtonClick("radius", buttonStep)
    end

    local addtext = CollapsingHeaderOrbit:AddText("Close/Far")
    addtext.SameLine = true

    local heightSlider = CollapsingHeaderOrbit:AddSlider("", 0, -1000, 1000, 0.001)
    heightSlider.IDContext = "HeightSlider"
    heightSlider.OnChange = function(value)
        OrbitSliderChange(value, "height", 0.0001)
    end

    -- Height orbit buttons _ai
    local heightDownButton = CollapsingHeaderOrbit:AddButton("<")
    heightDownButton.IDContext = "HeightDownButton"
    heightDownButton.SameLine = true
    heightDownButton.OnClick = function()
        OrbitButtonClick("height", -buttonStep)
    end

    local heightUpButton = CollapsingHeaderOrbit:AddButton(">")
    heightUpButton.IDContext = "HeightUpButton"
    heightUpButton.SameLine = true
    heightUpButton.OnClick = function()
        OrbitButtonClick("height", buttonStep)
    end

    local addtext = CollapsingHeaderOrbit:AddText("Down/Up")
    addtext.SameLine = true

    -- Collapsing header _ai
    local CollapsingHeaderDm = parent:AddCollapsingHeader("World relative")

    local forwardBackSlider = CollapsingHeaderDm:AddSlider("", 0, -1000, 1000, 0.001)
    forwardBackSlider.IDContext = "ForwardBackSlider"
    forwardBackSlider.OnChange = function(value)
        SliderChange(value, MoveLightForwardBack, stepMultiplier)
    end

    -- Forward/Back movement _ai
    local forwardBackButton = CollapsingHeaderDm:AddButton("<")
    forwardBackButton.SameLine = true
    forwardBackButton.IDContext = "MoveBackButton"
    forwardBackButton.OnClick = function()
        MoveLightForwardBack(-buttonStep)
    end

    local forwardButton = CollapsingHeaderDm:AddButton(">")
    forwardButton.IDContext = "MoveForwardButton"
    forwardButton.SameLine = true
    forwardButton.OnClick = function()
        MoveLightForwardBack(buttonStep)
    end

    local addtext = CollapsingHeaderDm:AddText("South/North")
    addtext.SameLine = true

    local leftRightSlider = CollapsingHeaderDm:AddSlider("", 0, -1000, 1000, 0.001)
    leftRightSlider.IDContext = "LeftRightSlider"
    leftRightSlider.OnChange = function(value)
        SliderChange(value, MoveLightLeftRight, stepMultiplier)
    end

    -- Left/Right movement _ai
    local leftButton = CollapsingHeaderDm:AddButton("<")
    leftButton.SameLine = true
    leftButton.IDContext = "MoveLeftButton"
    leftButton.OnClick = function()
        MoveLightLeftRight(-buttonStep)
    end

    local rightButton = CollapsingHeaderDm:AddButton(">")

    rightButton.IDContext = "MoveRightButton"
    rightButton.SameLine = true
    rightButton.OnClick = function()
        MoveLightLeftRight(buttonStep)
    end

    local addtext = CollapsingHeaderDm:AddText("West/East")
    addtext.SameLine = true

    local upDownSlider = CollapsingHeaderDm:AddSlider("", 0, -1000, 1000, 0.001)
    upDownSlider.IDContext = "UpDownSlider"
    upDownSlider.OnChange = function(value)
        SliderChange(value, MoveLightUpDown, stepMultiplier)
    end
    -- Up/Down movement _ai
    local downButton = CollapsingHeaderDm:AddButton("<")
    downButton.SameLine = true
    downButton.IDContext = "MoveDownButton"
    downButton.OnClick = function()
        MoveLightUpDown(-buttonStep)
    end

    local upButton = CollapsingHeaderDm:AddButton(">")
    upButton.IDContext = "MoveUpButton"
    upButton.SameLine = true
    upButton.OnClick = function()
        MoveLightUpDown(buttonStep)
    end

    local addtext = CollapsingHeaderDm:AddText("Down/Up")
    addtext.SameLine = true


     -- Collapsing header _ai
    local CollapsingHeaderCameraRelative = parent:AddCollapsingHeader("Camera relative")

    local forwardCRSlider = CollapsingHeaderCameraRelative:AddSlider("", 0, -1000, 1000, 0.001)
    forwardCRSlider.IDContext = "ForwardCRSlider"
    forwardCRSlider.OnChange = function(value)
        local currentValue = tonumber(value.Value[1])
        if currentValue and currentValue ~= 0 then
            MoveLightCameraRelative("forward", currentValue * stepMultiplier)
            forwardCRSlider.Value = {0, 0, 0, 0}
        end
    end

    -- Forward/Back movement _ai
    local forwardCRButton = CollapsingHeaderCameraRelative:AddButton("<")
    forwardCRButton.SameLine = true
    forwardCRButton.IDContext = "MoveForwardCRButton"
    forwardCRButton.OnClick = function()
        MoveLightCameraRelative("forward", -buttonStep)
    end

    local backwardCRButton = CollapsingHeaderCameraRelative:AddButton(">")
    backwardCRButton.IDContext = "MoveBackwardCRButton"
    backwardCRButton.SameLine = true
    backwardCRButton.OnClick = function()
        MoveLightCameraRelative("forward", buttonStep)
    end

    
    local addtext = CollapsingHeaderCameraRelative:AddText("Back/Forward")
    addtext.SameLine = true

    local rightleftCRSlider = CollapsingHeaderCameraRelative:AddSlider("", 0, -1000, 1000, 0.001)
    rightleftCRSlider.IDContext = "RightLeftCRSlider"
    rightleftCRSlider.OnChange = function(value)
        local currentValue = tonumber(value.Value[1])
        if currentValue and currentValue ~= 0 then
            MoveLightCameraRelative("right", currentValue * stepMultiplier)
            rightleftCRSlider.Value = {0, 0, 0, 0}
        end
    end

    -- Left/Right movement _ai
    local leftCRButton = CollapsingHeaderCameraRelative:AddButton("<")
    leftCRButton.SameLine = true
    leftCRButton.IDContext = "MoveLeftCRButton"
    leftCRButton.OnClick = function()
        MoveLightCameraRelative("right", -buttonStep)
    end

    local rightCRButton = CollapsingHeaderCameraRelative:AddButton(">")
    rightCRButton.IDContext = "MoveRightCRButton"
    rightCRButton.SameLine = true
    rightCRButton.OnClick = function()
        MoveLightCameraRelative("right", buttonStep)
    end

    local addtext = CollapsingHeaderCameraRelative:AddText("Left/Right")
    addtext.SameLine = true

    local upDownCRSlider = CollapsingHeaderCameraRelative:AddSlider("", 0, -1000, 1000, 0.001)
    upDownCRSlider.IDContext = "UpDownCRSlider"
    upDownCRSlider.OnChange = function(value)
        local currentValue = tonumber(value.Value[1])
        if currentValue and currentValue ~= 0 then
            MoveLightCameraRelative("up", currentValue * stepMultiplier)
            upDownCRSlider.Value = {0, 0, 0, 0}
        end
    end

    -- Up/Down movement _ai
    local downCRButton = CollapsingHeaderCameraRelative:AddButton("<")
    downCRButton.SameLine = true
    downCRButton.IDContext = "MoveDownCRButton"
    downCRButton.OnClick = function()
        MoveLightCameraRelative("up", -buttonStep)
    end

    local upCRButton = CollapsingHeaderCameraRelative:AddButton(">")
    upCRButton.IDContext = "MoveUpCRButton"
    upCRButton.SameLine = true
    upCRButton.OnClick = function()
        MoveLightCameraRelative("up", buttonStep)
    end

    local addtext = CollapsingHeaderCameraRelative:AddText("Down/Up")
    addtext.SameLine = true


    local CollapsingHeaderRotation = parent:AddCollapsingHeader("Rotation")


    local tiltSlider = CollapsingHeaderRotation:AddSlider("", 0, -1000, 1000, 0.001)
    tiltSlider.OnChange = function(value)
        local currentValue = tonumber(value.Value[1])
        if currentValue and currentValue ~= 0 then
            RotateLightTilt(currentValue * rotationMultiplier)
            tiltSlider.Value = {0, 0, 0, 0}
        end
    end

    -- Tilt rotation _ai
    local tiltLeftButton = CollapsingHeaderRotation:AddButton("<")
    tiltLeftButton.SameLine = true
    tiltLeftButton.OnClick = function()
        RotateLightTilt(-rotationStep)
    end


    local tiltRightButton = CollapsingHeaderRotation:AddButton(">")
    tiltRightButton.SameLine = true
    tiltRightButton.OnClick = function()
        RotateLightTilt(rotationStep)
    end

    local addtext = CollapsingHeaderRotation:AddText("Up/Down")
    addtext.SameLine = true

    local yawSlider = CollapsingHeaderRotation:AddSlider("", 0, -1000, 1000, 0.001)
    yawSlider.OnChange = function(value)
        local currentValue = tonumber(value.Value[1])
        if currentValue and currentValue ~= 0 then
            RotateLightYaw(currentValue * rotationMultiplier)
            yawSlider.Value = {0, 0, 0, 0}
        end
    end

    -- Yaw rotation _ai
    local yawLeftButton = CollapsingHeaderRotation:AddButton("<")
    yawLeftButton.SameLine = true
    yawLeftButton.OnClick = function()
        RotateLightYaw(-rotationStep)
    end

    local yawRightButton = CollapsingHeaderRotation:AddButton(">")
    yawRightButton.SameLine = true
    yawRightButton.SameLine = true
    yawRightButton.OnClick = function()
        RotateLightYaw(rotationStep)
    end

    local addtext = CollapsingHeaderRotation:AddText("Left/Right")
    addtext.SameLine = true
    -- Add position controls separator _ai
    local Separator = parent:AddSeparatorText("Utilities")

    -- Add toggle single light button _ai
    local toggleLightButton = parent:AddButton("Toggle light")
    toggleLightButton.IDContext = "ToggleLightButton"
    toggleLightButton.OnClick = function()
       ToggleLight()
    end

    -- Add toggle lights button _ai
    local toggleLightsButton = parent:AddButton("Toggle all")
    toggleLightsButton.IDContext = "ToggleLightsButton"
    Style.buttonSize.default(toggleLightsButton)
    toggleLightsButton.SameLine = true
    toggleLightsButton.OnClick = function()
        ToggleLights()
    end

    -- Add toggle marker button _ai
    local toggleMarkerButton = parent:AddButton("Toggle marker")
    toggleMarkerButton.IDContext = "ToggleMarkerButton"
    toggleMarkerButton.OnClick = function()
        ToggleMarker()
    end

    -- Add toggle all markers button _ai
    local toggleAllMarkersButton = parent:AddButton("Toggle all")
    toggleAllMarkersButton.IDContext = "ToggleAllMarkersButton"
    toggleAllMarkersButton.SameLine = true
    toggleAllMarkersButton.OnClick = function()
        ToggleAllMarkers()
    end

    -- Add step control sliders _ai
    local movementStepSlider = parent:AddSlider("Position step", buttonStep, 0.001, 2, 0.001)
    movementStepSlider.IDContext = "MovementStepSlider"
    movementStepSlider.OnChange = function(widget)
        buttonStep = widget.Value[1]
    end

    local rotationStepSlider = parent:AddSlider("Rotation step", rotationStep, 0.001, 2, 0.001)
    rotationStepSlider.IDContext = "RotationStepSlider"
    rotationStepSlider.OnChange = function(widget)
        rotationStep = widget.Value[1]
    end

    -- Add VFX control checkbox _ai
    local vfxControlCheckbox = parent:AddCheckbox("Disable VFX blur and shake")
    vfxControlCheckbox.OnChange = function(widget)
        DisableVFXEffects(widget.Checked)
    end

end

--===============-------------------------------------------------------------------------------------------------------------------------------
-----ORIGIN POINT TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function OriginPointTab(parent)

    parent:AddSeparatorText("Management")

    -- Create origin point button _ai
    local createButton = parent:AddButton("Create")
    createButton.IDContext = "CreateOriginPointButton"
    Style.buttonSize.default(createButton)
    createButton.OnClick = function()
        CreateOriginPoint()
    end

    -- Move origin point to camera position button _ai
    local moveToCameraButton = parent:AddButton("Move to cam")
    moveToCameraButton.IDContext = "MoveToCameraButton"
    -- Style.buttonSize.default(moveToCameraButton)
    moveToCameraButton.SameLine = true
    moveToCameraButton.OnClick = function()
        MoveOriginPointToCameraPos()
    end

    -- Reset position button _ai
    local resetButton = parent:AddButton("Reset")
    resetButton.IDContext = "ResetOriginPointButton"
    Style.buttonSize.default(resetButton)
    resetButton.SameLine = true
    resetButton.OnClick = function()
        ResetOriginPoint()
    end
    
    
    -- Delete origin point button _ai
    local deleteButton = parent:AddButton("Delete")
    deleteButton.IDContext = "DeleteOriginPointButton"
    Style.buttonSize.default(deleteButton)
    deleteButton.SameLine = true
 

    local hideOriginPointCheckbox = parent:AddCheckbox("Hide origin point")
    hideOriginPointCheckbox.IDContext = "HideOriginPointCheckbox"
    hideOriginPointCheckbox.OnChange = function(widget)
        ScaleOriginPoint(widget.Checked)
    end

    deleteButton.OnClick = function()
        DeleteOriginPoint()
        hideOriginPointCheckbox.Checked = false
    end

    parent:AddSeparatorText("Position")

    local zSlider = parent:AddSlider("", 0, -1000, 1000, 0.001)
    zSlider.OnChange = function(value)
        OriginPointSliderChange(value, "z", stepMultiplier)
    end

    -- Z axis buttons _ai
    local zLeftButton = parent:AddButton("<")
    zLeftButton.SameLine = true
    zLeftButton.IDContext = "ZLeftButton"
    zLeftButton.OnClick = function()
        MoveOriginPoint("z", -buttonStep)
    end

    local zRightButton = parent:AddButton(">")
    zRightButton.SameLine = true
    zRightButton.IDContext = "ZRightButton"
    zRightButton.OnClick = function()
        MoveOriginPoint("z", buttonStep)
    end

    local addtext = parent:AddText("South/North")
    addtext.SameLine = true

    -- Add sliders for position adjustment _ai
    local xSlider = parent:AddSlider("", 0, -1000, 1000, 0.001)
    xSlider.IDContext = "XSlider"
    xSlider.OnChange = function(value)
        OriginPointSliderChange(value, "x", stepMultiplier)
    end

    -- X axis buttons _ai
    local xLeftButton = parent:AddButton("<")
    xLeftButton.SameLine = true
    xLeftButton.IDContext = "XLeftButton"
    xLeftButton.OnClick = function()
        MoveOriginPoint("x", -buttonStep)
    end

    local xRightButton = parent:AddButton(">")
    xRightButton.SameLine = true
    xRightButton.IDContext = "XRightButton"
    xRightButton.OnClick = function()
        MoveOriginPoint("x", buttonStep)
    end

    local addtext = parent:AddText("West/East")
    addtext.SameLine = true

    local ySlider = parent:AddSlider("", 0, -1000, 1000, 0.001)
    ySlider.OnChange = function(value)
        OriginPointSliderChange(value, "y", stepMultiplier)
    end

    -- Y axis buttons _ai
    local yLeftButton = parent:AddButton("<")
    yLeftButton.SameLine = true
    yLeftButton.IDContext = "YLeftButton"
    yLeftButton.OnClick = function()
        MoveOriginPoint("y", -buttonStep)
    end

    local yRightButton = parent:AddButton(">")
    yRightButton.SameLine = true
    yRightButton.IDContext = "YRightButton"
    yRightButton.OnClick = function()
        MoveOriginPoint("y", buttonStep)
    end

    local addtext = parent:AddText("Down/Up")
    addtext.SameLine = true

end


--===============-------------------------------------------------------------------------------------------------------------------------------
-----ANAL TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function AnLWindowTab(parent)

    parent:AddSeparatorText("Management")

    -- Add LTN controls _ai
    local ltnSearchInput = parent:AddInputText("Search LTN", "")
    ltnCombo = parent:AddCombo("", "")

    -- Initialize LTN combo _ai
    ltnCombo.Options = GetTemplateOptions(ltn_templates)
    ltnCombo.SelectedIndex = 0

    local ltnLeftButton = parent:AddButton("<")
    ltnLeftButton.SameLine = true
    ltnLeftButton.IDContext = "LTNLeftButton"
    ltnLeftButton.OnClick = function()
        LTNButtonClick("left", ltnCombo.SelectedIndex, ltnCombo)
    end

    local ltnRightButton = parent:AddButton(">")
    ltnRightButton.SameLine = true
    ltnRightButton.IDContext = "LTNRightButton"
    ltnRightButton.OnClick = function()
        LTNButtonClick("right", ltnCombo.SelectedIndex, ltnCombo)
    end

    
    -- Then add Fav button _ai
    local addToLTNFavButton = parent:AddButton("Add to favs")
    addToLTNFavButton.SameLine = true
    addToLTNFavButton.IDContext = "AddToLTNFavoritesButton"
    addToLTNFavButton.OnClick = function()
        AddLTNFavorite(ltnCombo, ltnFavCombo)
    end

    -- Add LTN favorites section _ai
    ltnFavCombo = parent:AddCombo("")
    local ltnFavOptions = {}
    for _, fav in ipairs(LTNFavoritesList) do
        table.insert(ltnFavOptions, fav.name)
    end
    ltnFavCombo.Options = ltnFavOptions
    ltnFavCombo.OnChange = function(widget)
        LTNFavComboChange(widget)
    end

    -- Add LTN favorites navigation _ai
    local ltnFavLeftButton = parent:AddButton("<")
    ltnFavLeftButton.SameLine = true
    ltnFavLeftButton.IDContext = "LTNFavLeftButton"
    ltnFavLeftButton.OnClick = function()
        LTNFavButtonClick("left", ltnFavCombo)
    end

    local ltnFavRightButton = parent:AddButton(">")
    ltnFavRightButton.SameLine = true
    ltnFavRightButton.IDContext = "LTNFavRightButton"
    ltnFavRightButton.OnClick = function()
        LTNFavButtonClick("right", ltnFavCombo)
    end

    local ltnFavText = parent:AddText("Favorites")
    ltnFavText.SameLine = true

    ltnSearchInput.OnChange = function(widget)
        LTNSearchInputChange(widget, ltnCombo)
    end

    ltnCombo.OnChange = function(widget)
        LTNComboBoxChange(widget)
    end

    -- local separator = parent:AddSeparator()
    -- separator:SetColor("Separator", {0.5, 0.5, 0.5, 0})
        
    local dummySeparator = parent:AddDummy(1, 1)
    dummySeparator.IDContext = "ddummySeparator"


    -- Add ATM controls _ai
    local atmSearchInput = parent:AddInputText("Search ATM", "")
    local atmCombo = parent:AddCombo("", "")

    -- Initialize ATM combo _ai
    atmCombo.Options = GetTemplateOptions(atm_templates)
    atmCombo.SelectedIndex = 0

    local atmLeftButton = parent:AddButton("<")
    atmLeftButton.SameLine = true
    atmLeftButton.IDContext = "ATMLeftButton"
    atmLeftButton.OnClick = function()
        ATMButtonClick("left", atmCombo.SelectedIndex, atmCombo)
    end

    local atmRightButton = parent:AddButton(">")
    atmRightButton.SameLine = true
    atmRightButton.IDContext = "ATMRightButton"
    atmRightButton.OnClick = function()
        ATMButtonClick("right", atmCombo.SelectedIndex, atmCombo)
    end

    
    -- Then add Fav button _ai
    local addToATMFavButton = parent:AddButton("Add to favs")
    addToATMFavButton.SameLine = true
    addToATMFavButton.IDContext = "ATMFavButton"
    addToATMFavButton.OnClick = function()
        AddATMFavorite(atmCombo, atmFavCombo)
    end

    -- Add ATM favorites section _ai
    atmFavCombo = parent:AddCombo("")
    local atmFavOptions = {}
    for _, fav in ipairs(ATMFavoritesList) do
        table.insert(atmFavOptions, fav.name)
    end
    atmFavCombo.Options = atmFavOptions
    atmFavCombo.OnChange = function(widget)
        ATMFavComboChange(widget)
    end

    -- Add ATM favorites navigation _ai
    local atmFavLeftButton = parent:AddButton("<")
    atmFavLeftButton.SameLine = true
    atmFavLeftButton.IDContext = "ATMFavLeftButton"
    atmFavLeftButton.OnClick = function()
        ATMFavButtonClick("left", atmFavCombo)
    end

    local atmFavRightButton = parent:AddButton(">")
    atmFavRightButton.SameLine = true
    atmFavRightButton.IDContext = "ATMFavRightButton"
    atmFavRightButton.OnClick = function()
        ATMFavButtonClick("right", atmFavCombo)
    end

    local atmFavText = parent:AddText("Favorites")
    atmFavText.SameLine = true

    atmSearchInput.OnChange = function(widget)
        ATMSearchInputChange(widget, atmCombo)
    end

    atmCombo.OnChange = function(widget)
        ATMComboBoxChange(widget)
    end
    
    -- Add reset ATM button _ai
    local resetATMButton = parent:AddButton("Reset ATM")
    resetATMButton.IDContext = "ResetAllATMButton"
    resetATMButton.OnClick = function()
        ResetAllATM()
    end

    -- Add reset LTN button _ai
    local resetLTNButton = parent:AddButton("Reset LTN")
    resetLTNButton.IDContext = "ResetAllLTNButton"
    resetLTNButton.SameLine = true
    resetLTNButton.OnClick = function()
        ResetAllLTN()
    end

    local appliesSunMoon = parent:AddSeparatorText("Circles in the sky")
    


    -- local valuesApplyButton = parent:AddButton("Apply day")
    -- valuesApplyButton.IDContext = "sunValuesDayLoad"
    -- valuesApplyButton.SameLine = false
    -- valuesApplyButton.OnClick = function()
    --     Ext.Net.PostMessageToServer("valuesApplyDay", "")
    -- end


    -- local smSeparator = parent:AddSeparatorText("Sun")
    
    local collapsingHeaderSun = parent:AddCollapsingHeader("Sun")

    sunYaw = collapsingHeaderSun:AddSlider("Yaw", 0, 0, 360, 0.01)
    sunYaw.IDContext = "sunYaw"
    sunYaw.SameLine = false
    sunYaw.Value = {0,0,0,0}
    sunYaw.OnChange = function(value)
        -- print(sunYaw.Value[1])
        UpdateSunYaw(value)
    end

    sunPitch = collapsingHeaderSun:AddSlider("Pitch", 0, 0, 360, 0.01)
    sunPitch.IDContext = "sunPitch"
    sunPitch.SameLine = false
    sunPitch.OnChange = function(value)
        --print(sunPitch.Value[1])
        UpdateSunPitch(value)
    end
    
    sunIntensity = collapsingHeaderSun:AddSlider("Intensity", 0, 0, 1000000, 0.01)
    sunIntensity.IDContext = "sunIntensity"
    sunIntensity.SameLine = false
    sunIntensity.Logarithmic = true
    sunIntensity.OnChange = function(value)
        --print(sunIntensity.Value[1])
        UpdateSunInt(value)
    end

    -- local moonSeparator = parent:AddSeparatorText("Moon")

    local collapsingHeaderMoon = parent:AddCollapsingHeader("Moon")

    castLightCheckbox = collapsingHeaderMoon:AddCheckbox("Cast light")
    castLightCheckbox.IDContext = "castLightCheckbox"
    castLightCheckbox.Checked = false
    castLightCheckbox.SameLine = false
    castLightCheckbox.OnChange = function(value)
        if castLightCheckbox.Checked then
        --print(castLightCheckbox.Checked)
            UpdateCastLight(1)
        else
        --print(castLightCheckbox.Checked)
            UpdateCastLight(0)
        end
    end

    moonYaw = collapsingHeaderMoon:AddSlider("Yaw", 0, 0, 360, 0.01)
    moonYaw.IDContext = "moonYaw"
    moonYaw.SameLine = false
    moonYaw.OnChange = function(value)
        --print(moonYaw.Value[1])
        UpdateMoonYaw(value)
    end

    moonPitch = collapsingHeaderMoon:AddSlider("Pitch", 0, 0, 360, 0.01)
    moonPitch.IDContext = "moonPitch"
    moonPitch.SameLine = false
    moonPitch.OnChange = function(value)
        --print(moonPitch.Value[1])
        UpdateMoonPitch(value)
    end

    moonIntensity = collapsingHeaderMoon:AddSlider("Intensity", 0, 0, 100000, 0.01)
    moonIntensity.IDContext = "moonIntensity"
    moonIntensity.SameLine = false
    moonIntensity.Logarithmic = true
    moonIntensity.OnChange = function(value)
        --print(moonIntensity.Value[1])
        UpdateMoonInt(value)
    end


    moonRadius = collapsingHeaderMoon:AddSlider("Radius", 0, 0, 100000, 0.01)
    moonRadius.IDContext = "moonRadius"
    moonRadius.SameLine = false
    moonRadius.Logarithmic = true
    moonRadius.OnChange = function(value)
        --print(moonRadius.Value[1])
        UpdateMoonRadius(value)
    end
    

    -- local starsSeparator = parent:AddSeparatorText("Stars")
    
    local collapsingHeaderStars = parent:AddCollapsingHeader("Stars")

    starsCheckbox = collapsingHeaderStars:AddCheckbox("Stars")
    starsCheckbox.IDContext = "starsCheckbox"
    starsCheckbox.Checked = false
    starsCheckbox.SameLine = false
    starsCheckbox.OnChange = function()
        if starsCheckbox.Checked then
        --print(starsCheckbox.Checked)
            UpdateStarsState(1)
            -- Checked code
        else
        --print(starsCheckbox.Checked)
            UpdateStarsState(0)
            -- Unchecked code
        end
    end
    
    starsAmount = collapsingHeaderStars:AddSlider("Amount", 0, 0, 50, 0.01)
    starsAmount.IDContext = "starsAmount"
    starsAmount.SameLine = false
    starsAmount.OnChange = function(value)
        --print(starsAmount.Value[1])
        UpdateStarsAmount(value)
    end

    starsIntensity = collapsingHeaderStars:AddSlider("Intensity", 0, 0, 100000, 0.01)
    starsIntensity.IDContext = "starsIntensity"
    starsIntensity.SameLine = false
    starsIntensity.Logarithmic = true
    starsIntensity.OnChange = function(value)
        --print(starsIntensity.Value[1])
        UpdateStarsInt(value)
    end

    starsSaturation1 = collapsingHeaderStars:AddSlider("Saturation 1", 0, 0, 1, 0.01)
    starsSaturation1.IDContext = "starsSaturation1"
    starsSaturation1.SameLine = false
    starsSaturation1.OnChange = function(value)
        --print(starsSaturation1.Value[1])
        UpdateStarsSaturation1(value)
    end

    starsSaturation2 = collapsingHeaderStars:AddSlider("Saturation 2", 0, 0, 1, 0.01)
    starsSaturation2.IDContext = "starsSaturation2"
    starsSaturation2.SameLine = false
    starsSaturation2.OnChange = function(value)
        --print(starsSaturation2.Value[1])
        UpdateStarsSaturation2(value)
    end

    starsShimmer = collapsingHeaderStars:AddSlider("Shimmer", 0, 0, 10, 0.01)
    starsShimmer.IDContext = "starsShimmer"
    starsShimmer.SameLine = false
    starsShimmer.OnChange = function(value)
        --print(starsShimmer.Value[1])
        UpdateStarsShimmer(value)
    end


    -- local shadowSeparator = parent:AddSeparatorText("Shadows")

    local collapsingHeaderShadows = parent:AddCollapsingHeader("Shadows")

    cascadeSpeed = collapsingHeaderShadows:AddSlider("Cascade Speed", 0, 0, 1, 0.01)
    cascadeSpeed.IDContext = "cascadeSpeed"
    cascadeSpeed.SameLine = false
    cascadeSpeed.OnChange = function(value)
        --print(cascadeSpeed.Value[1])
        UpdateCascadeSpeed(value)
    end

    lightSize = collapsingHeaderShadows:AddSlider("Light Size", 0, 0, 30, 0.01)
    lightSize.IDContext = "lightSize"
    lightSize.SameLine = false
    lightSize.OnChange = function(value)
        --print(lightSize.Value[1])
        UpdateLightSize(value)
    end

    local valuesApplyButton = parent:AddButton("Apply")
    valuesApplyButton.IDContext = "sunValuesNightLoad"
    valuesApplyButton.OnClick = function()
        Ext.Net.PostMessageToServer("valuesApply", "")
    end

    local sunValuesLoadButton = parent:AddButton("Reset all")
    sunValuesLoadButton.IDContext = "sunValuesLoad"
    sunValuesLoadButton.SameLine = true
    sunValuesLoadButton.OnClick = function()
        Ext.Net.PostMessageToServer("sunValuesResetAll", "")
        starsCheckbox.Checked = false
        castLightCheckbox.Checked = false
        -- ResetSliderValues()
    end

end

--===============-------------------------------------------------------------------------------------------------------------------------------
-----GOBO TAB----
--===============-------------------------------------------------------------------------------------------------------------------------------

function GoboWindowTab(parent)

    parent:AddSeparatorText("Management")

    local goboGUIDs = {
        Tree = gobo_window_tree,
        Figures = gobo_figures,
        Window = gobo_window
    }

    -- Use existing LightDropdown for light selection _ai
    goboLightDropdown = parent:AddCombo("Created lights")
    goboLightDropdown.IDContext = "GoboLightDropdown"
    goboLightDropdown.HeightLargest = true
    goboLightDropdown.Options = LightDropdown.Options
    goboLightDropdown.SelectedIndex = LightDropdown.SelectedIndex

    -- List of available gobo masks _ai
    local goboList = parent:AddCombo("Masks")
    goboList.IDContext = "GoboMasksList"
    goboList.HeightLargest = true
    goboList.Options = {"Tree", "Figures", "Window"}
    goboList.SelectedIndex = 0

    -- Add distance slider for gobo _ai
    local goboDistanceSlider = parent:AddSlider("Distance", 1.0, 0.1, 4.0, 0.01)
    goboDistanceSlider.IDContext = "GoboDistanceSlider"
    goboDistanceSlider.OnChange = function(widget)
        GoboDistanceSliderChange(widget, goboLightDropdown)
    end


    -- local goboRotationHeader = parent:AddSeparatorText("Rotation")


    -- local goboRotationXSlider = parent:AddSlider("", 0, 0, 360.0, 1.0)
    -- goboRotationXSlider.IDContext = "GoboRotationXSlider"
    -- goboRotationXSlider.OnChange = function(widget)
    --     GoboRotationAxisSlider(widget, goboLightDropdown, "x")
    -- end

    -- local resetGoboRotationXButton = parent:AddButton("Reset tilt")
    -- resetGoboRotationXButton.IDContext = "ResetGoboRotationXButton"
    -- resetGoboRotationXButton.SameLine = true
    -- resetGoboRotationXButton.OnClick = function()
    --     ResetGoboRotation(goboLightDropdown, "x")
    --     goboRotationXSlider.Value = {0, 0, 0, 0}
    -- end

    -- local goboRotationYSlider = parent:AddSlider("", 0, 0, 360.0, 1.0)
    -- goboRotationYSlider.IDContext = "GoboRotationYSlider"
    -- goboRotationYSlider.OnChange = function(widget)
    --     GoboRotationAxisSlider(widget, goboLightDropdown, "y")
    -- end

    -- local resetGoboRotationYButton = parent:AddButton("Reset yaw")
    -- resetGoboRotationYButton.IDContext = "ResetGoboRotationYButton"
    -- resetGoboRotationYButton.SameLine = true
    -- resetGoboRotationYButton.OnClick = function()
    --     ResetGoboRotation(goboLightDropdown, "y")
    --     goboRotationYSlider.Value = {0, 0, 0, 0}
    -- end

    -- local goboRotationZSlider = parent:AddSlider("", 0, 0, 360.0, 1.0)
    -- goboRotationZSlider.IDContext = "GoboRotationZSlider"
    -- goboRotationZSlider.OnChange = function(widget)
    --     GoboRotationAxisSlider(widget, goboLightDropdown, "z")
    -- end

    -- local resetGoboRotationZButton = parent:AddButton("Reset roll")
    -- resetGoboRotationZButton.IDContext = "ResetGoboRotationZButton"
    -- resetGoboRotationZButton.SameLine = true
    -- resetGoboRotationZButton.OnClick = function()
    --     ResetGoboRotation(goboLightDropdown, "z")
    --     goboRotationZSlider.Value = {0, 0, 0, 0}
    -- end

    -- local resetAllGoboRotationButton = parent:AddButton("Reset all")
    -- resetAllGoboRotationButton.IDContext = "ResetAllGoboRotationButton"
    -- resetAllGoboRotationButton.OnClick = function()
    --     ResetGoboRotation(goboLightDropdown, "all")
    --     goboRotationXSlider.Value = {0, 0, 0, 0}
    --     goboRotationYSlider.Value = {0, 0, 0, 0}
    --     goboRotationZSlider.Value = {0, 0, 0, 0}
    -- end

    -- Add create gobo button _ai
    local createGoboButton = parent:AddButton("Create gobo")
    createGoboButton.IDContext = "CreateGoboButton"
    createGoboButton.OnClick = function()
        CreateGoboClick(goboLightDropdown, goboList, goboGUIDs)
    end

    -- Add delete gobo button _ai
    local deleteGoboButton = parent:AddButton("Delete gobo")
    deleteGoboButton.IDContext = "DeleteGoboButton"
    deleteGoboButton.SameLine = true
    deleteGoboButton.OnClick = function()
        DeleteGoboClick(goboLightDropdown)
    end

end


--===============-------------------------------------------------------------------------------------------------------------------------------
-----SETTINGS TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

-- function SettingsTab(parent)
--     parent:AddSeparatorText("Settings")
    
--     -- -- Add orbit height offset slider _ai
--     -- local orbitHeightSlider = parent:AddSlider("Orbit height offset", orbitHeightOffset, 0.0, 5.0, 0.1)
--     -- orbitHeightSlider.IDContext = "OrbitHeightOffsetSlider"
--     -- orbitHeightSlider:Tooltip():AddText("Controls the vertical offset of the light when using character-relative mode")
--     -- orbitHeightSlider.OnChange = function(widget)
--     --     orbitHeightOffset = widget.Value[1]
--     --     Settings.Save() -- Save settings when value changes _ai
--     -- end
-- end


--===============-------------------------------------------------------------------------------------------------------------------------------    
--SCENE SAVER TAB--
--===============-------------------------------------------------------------------------------------------------------------------------------

-- function SceneSaverWindowTab(parent)
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
--     parent:AddSeparatorText("Scene Saver")
-- end

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Lighty Lights", MainTab2)