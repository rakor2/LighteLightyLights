LightDropdown = nil
colorPicker = nil  
lightTypeCombo = nil
goboLightDropdown = nil
ltnCombo = nil
currentIntensityTextWidget = nil
currentDistanceTextWidget = nil

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
        for i = 1, #StyleDefinitions do
            local funcName = StyleDefinitions[i].funcName
            local windowName = "MainWindow" .. (funcName == "Main" and "" or funcName:sub(5))
            
            Styles[i] = {
                func = Style[windowName][funcName]
            }
        end
    end
    
    if Styles[styleNum] then 
        Styles[styleNum].func(window) 
    end
end


function EnableMCMHotkeys()
    MCM.SetKeybindingCallback('ll_toggle_window', function()
        mw.Open = not mw.Open
    end)
    
    MCM.SetKeybindingCallback('ll_toggle_light', function()
        ToggleLight()
    end)
    
    MCM.SetKeybindingCallback('ll_toggle_all_lights', function()
        ToggleLights()
    end)
    
    MCM.SetKeybindingCallback('ll_toggle_marker', function()
        ToggleMarker()
    end)
    
    MCM.SetKeybindingCallback('ll_toggle_all_markers', function()
        ToggleAllMarkers()
    end)
    
    MCM.SetKeybindingCallback('ll_duplicate', function()
        DuplicateLight()
    end)

    MCM.SetKeybindingCallback('ll_stick', function()
        if CheckBoxCF.Checked == false then
            CheckBoxCF.Checked = true
            CameraStick()
        else
            CheckBoxCF.Checked = false
            CameraStick()
        end
    end)

    
end


function MainTab2(mt2)

    if MainTab2 ~= nil then return end
    MainTab2 = mt2

    -- Create window first _ai
    mw = Ext.IMGUI.NewWindow("Lighty Lights")
    mw.Open = true

    mw.Closeable = true
    MainWindow(mw)

    if mw then
        EnableMCMHotkeys()
    end

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
        Settings.Save()
    end

    -- Apply initial style _ai
    ApplyStyle(mw, StyleSettings.selectedStyle)

        -- Add save button _ai
    -- local saveButton = mt2:AddButton("Save settings")
    -- saveButton.IDContext = "SaveSettingsButton"
    -- saveButton.OnClick = function()
    --     Settings.Save()
    -- end

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


    StyleV2:RegisterWindow(mw)

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
    lightTypeCombo.OnChange = function(combo)
        LightTypeChange(combo)
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
    LightDropdown.OnChange = function(dropdown)
        LightDropdownChange(dropdown)
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
    posSourceCheckbox.OnChange = function(checkbox)
        if checkbox.Checked then
            useOriginPoint.Checked = false
            tlDummyCheckbox.Checked = false
            ToggleOriginPoint(false)
            CollapsingHeaderOrbit.Label = "Character relative"
        end
        PositionSourceChange(checkbox.Checked)
    end

    useOriginPoint.IDContext = "UseOriginPointCheckbox"
    useOriginPoint.SameLine = true
    useOriginPoint.OnChange = function(checkbox)
        if checkbox.Checked then
            posSourceCheckbox.Checked = false
            tlDummyCheckbox.Checked = false
            PositionSourceChange(false)
            CollapsingHeaderOrbit.Label = "Origin point relative"
        else
            if not posSourceCheckbox.Checked then
                CollapsingHeaderOrbit.Label = "Character relative"
            end
        end
        ToggleOriginPoint(checkbox.Checked)
    end


    tlDummyCheckbox.IDContext = "CutsceneCheckbox"
    tlDummyCheckbox.Checked = false
    tlDummyCheckbox.SameLine = false
    tlDummyCheckbox.OnChange = function(checkbox)
        if tlDummyCheckbox.Checked then
            useOriginPoint.Checked = false
            ToggleOriginPoint(false)
            posSourceCheckbox.Checked = false
            CollapsingHeaderOrbit.Label = "Character relative"
        end
        PositionSourceCutscene(checkbox.Checked)
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
    colorPicker.OnChange = function(picker)
        ColorPickerChange(picker)
    end

    -- Add temperature slider _ai
    temperatureSlider = collapsingHeader:AddSlider("Temperature", 1000, 1000, 40000, 1)
    temperatureSlider.IDContext = "LightTemperatureSlider"
    temperatureSlider.Logarithmic = true
    temperatureSlider.OnChange = function(slider)
        TemperatureSliderChange(slider)
    end

    intensitySlider = collapsingHeader:AddSlider("", 0, -2000, 2000, 0.001)
    intensitySlider.IDContext = "LightIntensitySlider"
    intensitySlider.Logarithmic = true
    intensitySlider.Value = {1,0,0,0}
    intensitySliderValue = intensitySlider
    intensitySlider.OnChange = function(slider)
        IntensitySliderChange(slider)
    end

    -- Add text widgets for displaying current values _ai
    -- local currentIntensityText = collapsingHeader:AddText(string.format("Power: %.3f", 0.0))
    local currentIntensityText = collapsingHeader:AddText("Power")
    -- currentIntensityTextWidget = currentIntensityText
    currentIntensityText.SameLine = true

    local resetIntensityButton = collapsingHeader:AddButton("r")
    resetIntensityButton.SameLine = true
    resetIntensityButton.IDContext = "ResetIntensityButton"
    resetIntensityButton.OnClick = function()
        intensitySlider.Value = {1,0,0,0}
        ResetIntensityClick()
    end

    local radiusSlider = collapsingHeader:AddSlider("", 0, 0, 60, 0.001)
    radiusSlider.IDContext = "LightRadiusSlider"
    radiusSlider.Logarithmic = true
    radiusSlider.Value = {1,0,0,0}
    radiusSliderValue = radiusSlider
    radiusSlider.OnChange = function(slider)
        RadiusSliderChange(slider)
    end


    -- local currentDistanceText = collapsingHeader:AddText(string.format("Distance: %.3f", 0.0))
    local currentDistanceText = collapsingHeader:AddText("Distance")
    -- currentDistanceTextWidget = currentDistanceText
    currentDistanceText.SameLine = true

    local resetRadiusButton = collapsingHeader:AddButton("r")
    resetRadiusButton.IDContext = "ResetRadiusButton"
    resetRadiusButton.SameLine = true
    resetRadiusButton.OnClick = function()
        radiusSlider.Value = {1,0,0,0}
        ResetRadiusClick()
    end
    

    -- Add position controls separator _ai
    local Separator = parent:AddSeparatorText("Position")

    
    CheckBoxCF = parent:AddCheckbox("Stick light to camera")
    CheckBoxCF.OnChange = function()
        CameraStick()
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



    -- local smSeparator = parent:AddSeparatorText("Sun")
    
    local collapsingHeaderSun = parent:AddCollapsingHeader("Sun")

    sunYaw = collapsingHeaderSun:AddSlider("Yaw", 0, 0, 360, 0.01)
    sunYaw.IDContext = "sunYaw"
    sunYaw.SameLine = false
    sunYaw.Value = {0,0,0,0}
    sunYaw.OnChange = function(value)
        -- DPrint(sunYaw.Value[1])
        UpdateValue("SunYaw", "value1", value)
    end

    sunPitch = collapsingHeaderSun:AddSlider("Pitch", 0, 0, 360, 0.01)
    sunPitch.IDContext = "sunPitch"
    sunPitch.SameLine = false
    sunPitch.OnChange = function(value)
        --DPrint(sunPitch.Value[1])
        UpdateValue("SunPitch", "value1", value)
    end
    
    sunIntensity = collapsingHeaderSun:AddSlider("Intensity", 0, 0, 1000000, 0.01)
    sunIntensity.IDContext = "sunIntensity"
    sunIntensity.SameLine = false
    sunIntensity.Logarithmic = true
    sunIntensity.OnChange = function(value)
        --DPrint(sunIntensity.Value[1])
        UpdateValue("SunInt", "value1", value)
    end

    sunColor = collapsingHeaderSun:AddColorPicker("Sun color")
    sunColor.IDContext = "colorSun"
    sunColor.Color = {1.0, 1.0, 1.0, 1.0}
    sunColor.NoAlpha = true
    sunColor.Float = true
    sunColor.PickerHueWheel = false
    sunColor.InputRGB = true
    sunColor.DisplayHex = true
    sunColor.OnChange = function(value)
        UpdateValue("SunColor", "value4", value)
        -- Color change code here
    end
    

    -- local moonSeparator = parent:AddSeparatorText("Moon")

    local collapsingHeaderMoon = parent:AddCollapsingHeader("Moon")


    moonEnabledCheckbox = collapsingHeaderMoon:AddCheckbox("Enabled")
    moonEnabledCheckbox.IDContext = "moonEnabledCheckbox"
    moonEnabledCheckbox.Checked = false
    moonEnabledCheckbox.SameLine = false
    moonEnabledCheckbox.OnChange = function()
        UpdateValue("MoonEnabled", "value", moonEnabledCheckbox.Checked)
    end

    castLightCheckbox = collapsingHeaderMoon:AddCheckbox("Cast light")
    castLightCheckbox.IDContext = "castLightCheckbox"
    castLightCheckbox.Checked = false
    castLightCheckbox.SameLine = true
    castLightCheckbox.OnChange = function(value)
        if castLightCheckbox.Checked then
        --DPrint(castLightCheckbox.Checked)
            UpdateValue("CastLight", "value", true)
        else
        --DPrint(castLightCheckbox.Checked)
            UpdateValue("CastLight", "value", false)
        end
    end

    moonYaw = collapsingHeaderMoon:AddSlider("Yaw", 0, 0, 360, 0.01)
    moonYaw.IDContext = "moonYaw"
    moonYaw.SameLine = false
    moonYaw.OnChange = function(value)
        --DPrint(moonYaw.Value[1])
        UpdateValue("MoonYaw", "value1", value)
    end

    moonPitch = collapsingHeaderMoon:AddSlider("Pitch", 0, 0, 360, 0.01)
    moonPitch.IDContext = "moonPitch"
    moonPitch.SameLine = false
    moonPitch.OnChange = function(value)
        --DPrint(moonPitch.Value[1])
        UpdateValue("MoonPitch", "value1", value)
    end

    moonIntensity = collapsingHeaderMoon:AddSlider("Intensity", 0, 0, 100000, 0.01)
    moonIntensity.IDContext = "moonIntensity"
    moonIntensity.SameLine = false
    moonIntensity.Logarithmic = true
    moonIntensity.OnChange = function(value)
        --DPrint(moonIntensity.Value[1])
        UpdateValue("MoonInt", "value1", value)
    end

    moonEarthshine = collapsingHeaderMoon:AddSlider("Earthshine", 0, 0, 1, 0.01)
    moonEarthshine.IDContext = "moonEarthshine"
    moonEarthshine.SameLine = false
    moonEarthshine.OnChange = function(value)
        UpdateValue("MoonEarthshine", "value1", value)
    end

    moonGlare = collapsingHeaderMoon:AddSlider("Glare", 0, 0, 10, 0.01)
    moonGlare.IDContext = "moonGlare"
    moonGlare.SameLine = false
    moonGlare.OnChange = function(value)
        UpdateValue("MoonGlare", "value1", value)
    end

    moonRadius = collapsingHeaderMoon:AddSlider("Radius", 0, 0, 100000, 0.01)
    moonRadius.IDContext = "moonRadius"
    moonRadius.SameLine = false
    moonRadius.Logarithmic = true
    moonRadius.OnChange = function(value)
        --DPrint(moonRadius.Value[1])
        UpdateValue("MoonRadius", "value1", value)
    end
    

    moonDistance = collapsingHeaderMoon:AddSlider("Distance", 0, 0, 1000000, 1)
    moonDistance.IDContext = "moonDistance"
    moonDistance.SameLine = false
    moonDistance.Logarithmic = true
    moonDistance.OnChange = function(value)
        UpdateValue("MoonDistance", "value1", value)
    end



    -- tearsRotate = collapsingHeaderMoonExtended:AddSlider("Tears Rotate", 0, 0, 360, 0.01)
    -- tearsRotate.IDContext = "tearsRotate"
    -- tearsRotate.SameLine = false
    -- tearsRotate.OnChange = function(value)
    --     UpdateValue("TearsRotate", "value1", value)
    -- end

    -- tearsScale = collapsingHeaderMoonExtended:AddSlider("Tears Scale", 0, 0, 10, 0.01)
    -- tearsScale.IDContext = "tearsScale"
    -- tearsScale.SameLine = false
    -- tearsScale.OnChange = function(value)
    --     UpdateValue("TearsScale", "value1", value)
    -- end

    
    moonColor = collapsingHeaderMoon:AddColorPicker("Moon color")
    moonColor.IDContext = "colorMoon"
    moonColor.Color = {1.0, 1.0, 1.0, 1.0}
    moonColor.NoAlpha = true
    moonColor.Float = true
    moonColor.PickerHueWheel = false
    moonColor.InputRGB = true
    moonColor.DisplayHex = true
    moonColor.OnChange = function(value)
        UpdateValue("MoonColor", "value4", value)
        -- Color change code here
    end

    -- local starsSeparator = parent:AddSeparatorText("Stars")
    
    local collapsingHeaderStars = parent:AddCollapsingHeader("Stars")

    starsCheckbox = collapsingHeaderStars:AddCheckbox("Stars")
    starsCheckbox.IDContext = "starsCheckbox"
    starsCheckbox.Checked = false
    starsCheckbox.SameLine = false
    starsCheckbox.OnChange = function()
        if starsCheckbox.Checked then
        --DPrint(starsCheckbox.Checked)
            -- UpdateStarsState(1)
            -- Checked code
            UpdateValue("StarsState", "value", true)
        else
        --DPrint(starsCheckbox.Checked)
            -- UpdateStarsState(0)
            -- Unchecked code
            UpdateValue("StarsState", "value", false)
        end
    end
    
    starsAmount = collapsingHeaderStars:AddSlider("Amount", 0, 0, 50, 0.01)
    starsAmount.IDContext = "starsAmount"
    starsAmount.SameLine = false
    starsAmount.OnChange = function(value)
        --DPrint(starsAmount.Value[1])
        UpdateValue("StarsAmount", "value1", value)
    end

    starsIntensity = collapsingHeaderStars:AddSlider("Intensity", 0, 0, 100000, 0.01)
    starsIntensity.IDContext = "starsIntensity"
    starsIntensity.SameLine = false
    starsIntensity.Logarithmic = true
    starsIntensity.OnChange = function(value)
        --DPrint(starsIntensity.Value[1])
        UpdateValue("StarsInt", "value1", value)
    end

    starsSaturation1 = collapsingHeaderStars:AddSlider("Saturation 1", 0, 0, 1, 0.01)
    starsSaturation1.IDContext = "starsSaturation1"
    starsSaturation1.SameLine = false
    starsSaturation1.OnChange = function(value)
        --DPrint(starsSaturation1.Value[1])
        UpdateValue("StarsSaturation1", "value1", value)
    end

    starsSaturation2 = collapsingHeaderStars:AddSlider("Saturation 2", 0, 0, 1, 0.01)
    starsSaturation2.IDContext = "starsSaturation2"
    starsSaturation2.SameLine = false
    starsSaturation2.OnChange = function(value)
        --DPrint(starsSaturation2.Value[1])
        UpdateValue("StarsSaturation2", "value1", value)
    end

    starsShimmer = collapsingHeaderStars:AddSlider("Shimmer", 0, 0, 10, 0.01)
    starsShimmer.IDContext = "starsShimmer"
    starsShimmer.SameLine = false
    starsShimmer.OnChange = function(value)
        --DPrint(starsShimmer.Value[1])
        UpdateValue("StarsShimmer", "value1", value)
    end



    local collapsingHeaderShadows = parent:AddCollapsingHeader("Shadows")


    shadowEnabledCheckbox = collapsingHeaderShadows:AddCheckbox("Shadow enabled")
    shadowEnabledCheckbox.IDContext = "shadowEnabled"
    shadowEnabledCheckbox.Checked = false
    shadowEnabledCheckbox.SameLine = false
    shadowEnabledCheckbox.OnChange = function()
        UpdateValue("ShadowEnabled", "value", shadowEnabledCheckbox.Checked)
    end

    cascadeSpeed = collapsingHeaderShadows:AddSlider("Cascade speed", 0, 0, 1, 0.01)
    cascadeSpeed.IDContext = "cascadeSpeed"
    cascadeSpeed.SameLine = false
    cascadeSpeed.OnChange = function(value)
        --DPrint(cascadeSpeed.Value[1])
        UpdateValue("CascadeSpeed", "value1", value)
    end

    lightSize = collapsingHeaderShadows:AddSlider("Light size", 0, 0, 30, 0.01)
    lightSize.IDContext = "lightSize"
    lightSize.SameLine = false
    lightSize.OnChange = function(value)
        --DPrint(lightSize.Value[1])
        UpdateValue("LightSize", "value1", value)
    end

    cascadeCountSlider = collapsingHeaderShadows:AddSlider("Cascade count", 0, 0, 10, 1)
    cascadeCountSlider.IDContext = "cascadeCount"
    cascadeCountSlider.SameLine = false
    cascadeCountSlider.OnChange = function(value)
        UpdateValue("CascadeCount", "value1", value)
    end

    shadowBiasSlider = collapsingHeaderShadows:AddSlider("Shadow bias", 0, 0, 1, 0.001)
    shadowBiasSlider.IDContext = "shadowBias"
    shadowBiasSlider.SameLine = false
    shadowBiasSlider.OnChange = function(value)
        UpdateValue("ShadowBias", "value1", value)
    end

    shadowFadeSlider = collapsingHeaderShadows:AddSlider("Shadow fade", 0, 0, 1, 0.01)
    shadowFadeSlider.IDContext = "shadowFade"
    shadowFadeSlider.SameLine = false
    shadowFadeSlider.OnChange = function(value)
        UpdateValue("ShadowFade", "value1", value)
    end

    shadowFarPlaneSlider = collapsingHeaderShadows:AddSlider("Shadow far plane", 0, 0, 100000, 1)
    shadowFarPlaneSlider.IDContext = "shadowFarPlane"
    shadowFarPlaneSlider.SameLine = false
    shadowFarPlaneSlider.Logarithmic = true
    shadowFarPlaneSlider.OnChange = function(value)
        UpdateValue("ShadowFarPlane", "value1", value)
    end

    shadowNearPlaneSlider = collapsingHeaderShadows:AddSlider("Shadow near plane", 0, 0, 1000, 0.1)
    shadowNearPlaneSlider.IDContext = "shadowNearPlane"
    shadowNearPlaneSlider.SameLine = false
    shadowNearPlaneSlider.OnChange = function(value)
        UpdateValue("ShadowNearPlane", "value1", value)
    end



    local collapsingHeaderFogLayer = parent:AddCollapsingHeader("Fog")
    local collapsingHeaderFogGeneral = collapsingHeaderFogLayer:AddTree("Fog general")



    fogPhase = collapsingHeaderFogGeneral:AddSlider("Phase", 0, 0, 1, 0.01)
    fogPhase.IDContext = "fogPhase"
    fogPhase.SameLine = false
    fogPhase.OnChange = function(value)
        UpdateValue("FogPhase", "value1", value)
    end

    fogRenderDistance = collapsingHeaderFogGeneral:AddSlider("Render distance", 0, 0, 10000, 1)
    fogRenderDistance.IDContext = "fogRenderDistance"
    fogRenderDistance.SameLine = false
    fogRenderDistance.OnChange = function(value)
        UpdateValue("FogRenderDistance", "value1", value)
    end


    local collapsingHeaderFogLayer1 = collapsingHeaderFogLayer:AddTree("Fog layer 1")

    fogLayer1EnabledCheckbox = collapsingHeaderFogLayer1:AddCheckbox("Enabled")
    fogLayer1EnabledCheckbox.IDContext = "fogLayer1EnabledCheckbox"
    fogLayer1EnabledCheckbox.Checked = false
    fogLayer1EnabledCheckbox.SameLine = false
    fogLayer1EnabledCheckbox.OnChange = function()
        UpdateValue("FogLayer1Enabled", "value", fogLayer1EnabledCheckbox.Checked)
    end

    fogLayer1Density0 = collapsingHeaderFogLayer1:AddSlider("Density 0", 0, 0, 1, 0.01)
    fogLayer1Density0.IDContext = "fogLayer1Density0"
    fogLayer1Density0.SameLine = false
    fogLayer1Density0.OnChange = function(value)
        UpdateValue("FogLayer1Density0", "value1", value)
    end

    fogLayer1Density1 = collapsingHeaderFogLayer1:AddSlider("Density 1", 0, 0, 1, 0.01)
    fogLayer1Density1.IDContext = "fogLayer1Density1"
    fogLayer1Density1.SameLine = false
    fogLayer1Density1.OnChange = function(value)
        UpdateValue("FogLayer1Density1", "value1", value)
    end

    fogLayer1Height0 = collapsingHeaderFogLayer1:AddSlider("Height 0", 0, -10000, 10000, 1)
    fogLayer1Height0.IDContext = "fogLayer1Height0"
    fogLayer1Height0.SameLine = false
    fogLayer1Height0.OnChange = function(value)
        UpdateValue("FogLayer1Height0", "value1", value)
    end

    fogLayer1Height1 = collapsingHeaderFogLayer1:AddSlider("Height 1", 0, -10000, 10000, 1)
    fogLayer1Height1.IDContext = "fogLayer1Height1"
    fogLayer1Height1.SameLine = false
    fogLayer1Height1.OnChange = function(value)
        UpdateValue("FogLayer1Height1", "value1", value)
    end

    fogLayer1NoiseCoverage = collapsingHeaderFogLayer1:AddSlider("Noise coverage", 0, 0, 1, 0.01)
    fogLayer1NoiseCoverage.IDContext = "fogLayer1NoiseCoverage"
    fogLayer1NoiseCoverage.SameLine = false
    fogLayer1NoiseCoverage.OnChange = function(value)
        UpdateValue("FogLayer1NoiseCoverage", "value1", value)
    end

    fogLayer1Albedo = collapsingHeaderFogLayer1:AddColorPicker("Albedo color")
    fogLayer1Albedo.IDContext = "fogLayer1Albedo"
    fogLayer1Albedo.Color = {1.0, 1.0, 1.0, 1.0}
    fogLayer1Albedo.NoAlpha = true
    fogLayer1Albedo.Float = true
    fogLayer1Albedo.PickerHueWheel = false
    fogLayer1Albedo.InputRGB = true
    fogLayer1Albedo.DisplayHex = true
    fogLayer1Albedo.OnChange = function(value)
        UpdateValue("FogLayer1Albedo", "value4", value)
    end

    local collapsingHeaderFogLayer0 = collapsingHeaderFogLayer:AddTree("Fog layer 0")

    fogLayer0EnabledCheckbox = collapsingHeaderFogLayer0:AddCheckbox("Enabled")
    fogLayer0EnabledCheckbox.IDContext = "fogLayer0EnabledCheckbox"
    fogLayer0EnabledCheckbox.Checked = false
    fogLayer0EnabledCheckbox.SameLine = false
    fogLayer0EnabledCheckbox.OnChange = function()
        UpdateValue("FogLayer0Enabled", "value", fogLayer0EnabledCheckbox.Checked)
    end

    fogLayer0Density0 = collapsingHeaderFogLayer0:AddSlider("Density 0", 0, 0, 1, 0.01)
    fogLayer0Density0.IDContext = "fogLayer0Density0"
    fogLayer0Density0.SameLine = false
    fogLayer0Density0.OnChange = function(value)
        UpdateValue("FogLayer0Density0", "value1", value)
    end

    fogLayer0Density1 = collapsingHeaderFogLayer0:AddSlider("Density 1", 0, 0, 1, 0.01)
    fogLayer0Density1.IDContext = "fogLayer0Density1"
    fogLayer0Density1.SameLine = false
    fogLayer0Density1.OnChange = function(value)
        UpdateValue("FogLayer0Density1", "value1", value)
    end

    fogLayer0Height0 = collapsingHeaderFogLayer0:AddSlider("Height 0", 0, -10000, 10000, 1)
    fogLayer0Height0.IDContext = "fogLayer0Height0"
    fogLayer0Height0.SameLine = false
    fogLayer0Height0.OnChange = function(value)
        UpdateValue("FogLayer0Height0", "value1", value)
    end

    fogLayer0Height1 = collapsingHeaderFogLayer0:AddSlider("Height 1", 0, -10000, 10000, 1)
    fogLayer0Height1.IDContext = "fogLayer0Height1"
    fogLayer0Height1.SameLine = false
    fogLayer0Height1.OnChange = function(value)
        UpdateValue("FogLayer0Height1", "value1", value)
    end

    fogLayer0NoiseCoverage = collapsingHeaderFogLayer0:AddSlider("Noise coverage", 0, 0, 1, 0.01)
    fogLayer0NoiseCoverage.IDContext = "fogLayer0NoiseCoverage"
    fogLayer0NoiseCoverage.SameLine = false
    fogLayer0NoiseCoverage.OnChange = function(value)
        UpdateValue("FogLayer0NoiseCoverage", "value1", value)
    end

    fogLayer0Albedo = collapsingHeaderFogLayer0:AddColorPicker("Albedo color")
    fogLayer0Albedo.IDContext = "fogLayer0Albedo"
    fogLayer0Albedo.Color = {1.0, 1.0, 1.0, 1.0}
    fogLayer0Albedo.NoAlpha = true
    fogLayer0Albedo.Float = true
    fogLayer0Albedo.PickerHueWheel = false
    fogLayer0Albedo.InputRGB = true
    fogLayer0Albedo.DisplayHex = true
    fogLayer0Albedo.OnChange = function(value)
        UpdateValue("FogLayer0Albedo", "value4", value)
    end


    local collapsingHeaderSkyLight = parent:AddCollapsingHeader("Sky light")



    cirrusCloudsEnabledCheckbox = collapsingHeaderSkyLight:AddCheckbox("Cirrus clouds enabled")
    cirrusCloudsEnabledCheckbox.IDContext = "cirrusCloudsEnabled"
    cirrusCloudsEnabledCheckbox.Checked = false
    cirrusCloudsEnabledCheckbox.SameLine = false
    cirrusCloudsEnabledCheckbox.OnChange = function()
        UpdateValue("CirrusCloudsEnabled", "value", cirrusCloudsEnabledCheckbox.Checked)
    end

    
    cirrusCloudsIntensitySlider = collapsingHeaderSkyLight:AddSlider("Cirrus clouds intensity", 0, 0, 100, 0.01)
    cirrusCloudsIntensitySlider.IDContext = "cirrusCloudsIntensity"
    cirrusCloudsIntensitySlider.SameLine = false
    cirrusCloudsIntensitySlider.OnChange = function(value)
        UpdateValue("CirrusCloudsIntensity", "value1", value)
    end

    cirrusCloudsAmountSlider = collapsingHeaderSkyLight:AddSlider("Cirrus clouds amount", 0, 0, 1, 0.01)
    cirrusCloudsAmountSlider.IDContext = "cirrusCloudsAmount"
    cirrusCloudsAmountSlider.SameLine = false
    cirrusCloudsAmountSlider.OnChange = function(value)
        UpdateValue("CirrusCloudsAmount", "value1", value)
    end

    cirrusCloudsColor = collapsingHeaderSkyLight:AddColorPicker("Cirrus clouds color")
    cirrusCloudsColor.IDContext = "cirrusCloudsColor"
    cirrusCloudsColor.Color = {1.0, 1.0, 1.0, 1.0}
    cirrusCloudsColor.NoAlpha = true
    cirrusCloudsColor.Float = true
    cirrusCloudsColor.PickerHueWheel = false
    cirrusCloudsColor.InputRGB = true
    cirrusCloudsColor.DisplayHex = true
    cirrusCloudsColor.OnChange = function(value)
        UpdateValue("CirrusCloudsColor", "value4", value)
    end

    rotateSkydomeEnabledCheckbox = collapsingHeaderSkyLight:AddCheckbox("Rotate skydome")
    rotateSkydomeEnabledCheckbox.IDContext = "rotateSkydomeEnabled"
    rotateSkydomeEnabledCheckbox.Checked = false
    rotateSkydomeEnabledCheckbox.SameLine = false
    rotateSkydomeEnabledCheckbox.OnChange = function()
        UpdateValue("RotateSkydomeEnabled", "value", rotateSkydomeEnabledCheckbox.Checked)
    end

    scatteringEnabledCheckbox = collapsingHeaderSkyLight:AddCheckbox("Scattering enabled")
    scatteringEnabledCheckbox.IDContext = "scatteringEnabled"
    scatteringEnabledCheckbox.Checked = false
    scatteringEnabledCheckbox.SameLine = false
    scatteringEnabledCheckbox.OnChange = function()
        UpdateValue("ScatteringEnabled", "value", scatteringEnabledCheckbox.Checked)
    end

    scatteringIntensitySlider = collapsingHeaderSkyLight:AddSlider("Scattering intensity", 0, 0, 10, 0.01)
    scatteringIntensitySlider.IDContext = "scatteringIntensity"
    scatteringIntensitySlider.SameLine = false
    scatteringIntensitySlider.OnChange = function(value)
        UpdateValue("ScatteringIntensity", "value1", value)
    end

    scatteringSunColor = collapsingHeaderSkyLight:AddColorPicker("Scattering sun color")
    scatteringSunColor.IDContext = "scatteringSunColor"
    scatteringSunColor.Color = {1.0, 1.0, 1.0, 1.0}
    scatteringSunColor.NoAlpha = true
    scatteringSunColor.Float = true
    scatteringSunColor.PickerHueWheel = false
    scatteringSunColor.InputRGB = true
    scatteringSunColor.DisplayHex = true
    scatteringSunColor.OnChange = function(value)
        UpdateValue("ScatteringSunColor", "value4", value)
    end

    scatteringSunIntensitySlider = collapsingHeaderSkyLight:AddSlider("Scattering sun intensity", 0, 0, 100, 0.01)
    scatteringSunIntensitySlider.IDContext = "scatteringSunIntensity"
    scatteringSunIntensitySlider.SameLine = false
    scatteringSunIntensitySlider.OnChange = function(value)
        UpdateValue("ScatteringSunIntensity", "value1", value)
    end

    skydomeEnabledCheckbox = collapsingHeaderSkyLight:AddCheckbox("Skydome enabled")
    skydomeEnabledCheckbox.IDContext = "skydomeEnabled"
    skydomeEnabledCheckbox.Checked = false
    skydomeEnabledCheckbox.SameLine = false
    skydomeEnabledCheckbox.OnChange = function()
        UpdateValue("SkydomeEnabled", "value", skydomeEnabledCheckbox.Checked)
    end


    scatteringIntensityScaleSlider = collapsingHeaderSkyLight:AddSlider("Scattering intensity scale", 0, 0, 10, 0.01)
    scatteringIntensityScaleSlider.IDContext = "scatteringIntensityScale"
    scatteringIntensityScaleSlider.SameLine = false
    scatteringIntensityScaleSlider.OnChange = function(value)
        UpdateValue("ScatteringIntensityScale", "value1", value)
    end




    local collapsingHeaderVolumetricCloud = parent:AddCollapsingHeader("Volumetric cloud")



    cloudEnabledCheckbox = collapsingHeaderVolumetricCloud:AddCheckbox("Enabled")
    cloudEnabledCheckbox.IDContext = "cloudEnabled"
    cloudEnabledCheckbox.Checked = false
    cloudEnabledCheckbox.SameLine = false
    cloudEnabledCheckbox.OnChange = function()
        UpdateValue("CloudEnabled", "value", cloudEnabledCheckbox.Checked)
    end
    
    cloudIntensitySlider = collapsingHeaderVolumetricCloud:AddSlider("Intensity", 0, 0, 100000, 0.01)
    cloudIntensitySlider.IDContext = "cloudIntensity"
    cloudIntensitySlider.SameLine = false
    cloudIntensitySlider.OnChange = function(value)
        UpdateValue("CloudIntensity", "value1", value)
    end

    cloudAmbientLightFactorSlider = collapsingHeaderVolumetricCloud:AddSlider("Ambient light factor", 0, 0, 10, 0.01)
    cloudAmbientLightFactorSlider.IDContext = "cloudAmbientLightFactor"
    cloudAmbientLightFactorSlider.SameLine = false
    cloudAmbientLightFactorSlider.OnChange = function(value)
        UpdateValue("CloudAmbientLightFactor", "value1", value)
    end

    cloudEndHeightSlider = collapsingHeaderVolumetricCloud:AddSlider("End height", 0, 0, 20000, 1)
    cloudEndHeightSlider.IDContext = "cloudEndHeight"
    cloudEndHeightSlider.SameLine = false
    cloudEndHeightSlider.OnChange = function(value)
        UpdateValue("CloudEndHeight", "value1", value)
    end

    cloudHorizonDistanceSlider = collapsingHeaderVolumetricCloud:AddSlider("Horizon distance", 0, 0, 100000, 1)
    cloudHorizonDistanceSlider.IDContext = "cloudHorizonDistance"
    cloudHorizonDistanceSlider.SameLine = false
    cloudHorizonDistanceSlider.OnChange = function(value)
        UpdateValue("CloudHorizonDistance", "value1", value)
    end

    cloudStartHeightSlider = collapsingHeaderVolumetricCloud:AddSlider("Start height", 0, 0, 10000, 1)
    cloudStartHeightSlider.IDContext = "cloudStartHeight"
    cloudStartHeightSlider.SameLine = false
    cloudStartHeightSlider.OnChange = function(value)
        UpdateValue("CloudStartHeight", "value1", value)
    end

    cloudCoverageStartDistanceSlider = collapsingHeaderVolumetricCloud:AddSlider("Coverage start distance", 0, 0, 100000, 1)
    cloudCoverageStartDistanceSlider.IDContext = "cloudCoverageStartDistance"
    cloudCoverageStartDistanceSlider.SameLine = false
    cloudCoverageStartDistanceSlider.OnChange = function(value)
        UpdateValue("CloudCoverageStartDistance", "value1", value)
    end

    cloudCoverageWindSpeedSlider = collapsingHeaderVolumetricCloud:AddSlider("Coverage wind speed", 0, 0, 100, 0.01)
    cloudCoverageWindSpeedSlider.IDContext = "cloudCoverageWindSpeed"
    cloudCoverageWindSpeedSlider.SameLine = false
    cloudCoverageWindSpeedSlider.OnChange = function(value)
        UpdateValue("CloudCoverageWindSpeed", "value1", value)
    end

    cloudDetailScaleSlider = collapsingHeaderVolumetricCloud:AddSlider("Detail scale", 0, 0, 10, 0.01)
    cloudDetailScaleSlider.IDContext = "cloudDetailScale"
    cloudDetailScaleSlider.SameLine = false
    cloudDetailScaleSlider.OnChange = function(value)
        UpdateValue("CloudDetailScale", "value1", value)
    end


    cloudShadowFactorSlider = collapsingHeaderVolumetricCloud:AddSlider("Shadow factor", 0, 0, 1, 0.01)
    cloudShadowFactorSlider.IDContext = "cloudShadowFactor"
    cloudShadowFactorSlider.SameLine = false
    cloudShadowFactorSlider.OnChange = function(value)
        UpdateValue("CloudShadowFactor", "value1", value)
    end

    cloudSunLightFactorSlider = collapsingHeaderVolumetricCloud:AddSlider("Sun light factor", 0, 0, 10, 0.01)
    cloudSunLightFactorSlider.IDContext = "cloudSunLightFactor"
    cloudSunLightFactorSlider.SameLine = false
    cloudSunLightFactorSlider.OnChange = function(value)
        UpdateValue("CloudSunLightFactor", "value1", value)
    end

    cloudSunRayLengthSlider = collapsingHeaderVolumetricCloud:AddSlider("Sun ray length", 0, 0, 1, 0.01)
    cloudSunRayLengthSlider.IDContext = "cloudSunRayLength"
    cloudSunRayLengthSlider.SameLine = false
    cloudSunRayLengthSlider.OnChange = function(value)
        UpdateValue("CloudSunRayLength", "value1", value)
    end

    cloudBaseColor = collapsingHeaderVolumetricCloud:AddColorPicker("Base color")
    cloudBaseColor.IDContext = "cloudBaseColor"
    cloudBaseColor.Color = {1.0, 1.0, 1.0, 1.0}
    cloudBaseColor.NoAlpha = true
    cloudBaseColor.Float = true
    cloudBaseColor.PickerHueWheel = false
    cloudBaseColor.InputRGB = true
    cloudBaseColor.DisplayHex = true
    cloudBaseColor.OnChange = function(value)
        UpdateValue("CloudBaseColor", "value4", value)
    end

    cloudTopColor = collapsingHeaderVolumetricCloud:AddColorPicker("Top color")
    cloudTopColor.IDContext = "cloudTopColor"
    cloudTopColor.Color = {1.0, 1.0, 1.0, 1.0}
    cloudTopColor.NoAlpha = true
    cloudTopColor.Float = true
    cloudTopColor.PickerHueWheel = false
    cloudTopColor.InputRGB = true
    cloudTopColor.DisplayHex = true
    cloudTopColor.OnChange = function(value)
        UpdateValue("CloudTopColor", "value4", value)
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

    local valuesApplyButton = parent:AddButton("Apply if something won't apply")
    valuesApplyButton.IDContext = "sunValuesDayLoad"
    valuesApplyButton.SameLine = false
    valuesApplyButton.OnClick = function()
        Ext.Net.PostMessageToServer("valuesApplyDay", "")
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