Style = {}

-- Style definitions _ai
StyleDefinitions = {
    {
        name = "Maleenka Pink",
        funcName = "Main"
    },
    {
        name = "Alithea Purple",
        funcName = "Main8"
    },
    {
        name = "ImGui Blue",
        funcName = "Main7"
    },
    {
        name = "Velvet Glow of a Forgotten Amethyst Star",
        funcName = "Main2"
    },
    {
        name = "Arctic Breeze Dancing Over the Moonlit Waves",
        funcName = "Main3"
    },
    {
        name = "Mystical Essence of the Enchanted Forest's Breath",
        funcName = "Main4"
    },
    {
        name = "Golden Dreams of a Sunset Lost in Time",
        funcName = "Main5"
    },
    {
        name = "Lavender Twilight Kissed by the Reverberations of Forever",
        funcName = "Main6"
    }
}

-- Style names for display only _ai
StyleNames = {}
for i, style in ipairs(StyleDefinitions) do
    StyleNames[i] = style.name
end

-- Style settings storage _ai
StyleSettings = {
    selectedStyle = 1
}


Ext.IMGUI.LoadFont("Font", "Mods/LighterLightyLights_6aa50183-bce4-576e-749f-3a2c60233b09/GUI/QuadraatOffcPro.ttf", 35.0)

-- Ext.IMGUI.EnableDemo(true)


Style.buttonSize = {
    default = function(button)
        button.Size = {130, 35}
    end,
    
    disabled = function(button)
        button.Size = {130, 35}
        button.Disabled = true
        button:SetColor("Button", {0.1, 0.1, 0.1, 1.0})         -- Dark red
    end,

    disabled2 = function(button)
        button.Disabled = true
        button:SetColor("Button", {0.1, 0.1, 0.1, 1.0})         -- Dark red
    end
}

-- Button confirm style _ai
Style.buttonConfirm = {
    default = function(button)
        button.Size = {130, 35}
        button:SetColor("Button", {0.55, 0.0, 0.0, 1.0})  
        button:SetColor("ButtonHovered", {0.35, 0.0, 0.0, 1.0})
        button:SetColor("ButtonActive", {0.25, 0.0, 0.0, 1.0})
    end
}

function Style.ApplyCommonStyles(mainWindow)
    -- Set font if available _ai
    -- Ext.IMGUI.SetScale(1.5)
    mainWindow.Font = "Font"
    -- Common styles _ai
    mainWindow:SetStyle("ButtonTextAlign", 0.5, 0.5)
    mainWindow:SetStyle("FramePadding", 6, 2)
    mainWindow:SetStyle("ItemSpacing", 7, 5)
    mainWindow:SetStyle("ItemInnerSpacing", 7, 3)
    mainWindow:SetStyle("WindowPadding", 3, 7)
    mainWindow:SetStyle("WindowBorderSize", 0)
    mainWindow:SetStyle("ScrollbarSize", 15)
    mainWindow:SetStyle("FrameRounding", 2)
    mainWindow:SetStyle("WindowTitleAlign", 0.5)
    mainWindow:SetStyle("SeparatorTextBorderSize", 2)
    mainWindow:SetStyle("SeparatorTextPadding", 0, 1)
    mainWindow:SetStyle("SeparatorTextAlign", 0.022, 0.5)
    mainWindow:SetStyle("DisabledAlpha", 0.1)
    mainWindow:SetStyle("WindowRounding", 2)
    mainWindow:SetStyle("ChildRounding", 2)
    mainWindow:SetStyle("PopupRounding", 2)
    mainWindow:SetStyle("ScrollbarRounding", 2)
    mainWindow:SetStyle("GrabRounding", 2)
    mainWindow:SetStyle("TabRounding", 2)

end



-- Window styles _ai
Style.MainWindow = {
    Main = function(mainWindow)
        -- Colors settings _ai
        mainWindow:SetColor("Text", {0.94, 0.94, 0.94, 1.00})
        mainWindow:SetColor("TextDisabled", {0.60, 0.60, 0.60, 1.00})
        mainWindow:SetColor("WindowBg", {0.08, 0.08, 0.08, 1.00})
        mainWindow:SetColor("ChildBg", {0.11, 0.11, 0.11, 1.00})
        mainWindow:SetColor("PopupBg", {0.1, 0.1, 0.1, 1.00})
        mainWindow:SetColor("Border", {0.07, 0.07, 0.07, 1.00})
        mainWindow:SetColor("BorderShadow", {0.07, 0.07, 0.07, 1.00})
        mainWindow:SetColor("FrameBg", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("FrameBgHovered", {0.27, 0.27, 0.27, 0.92})
        mainWindow:SetColor("FrameBgActive", {0.39, 0.39, 0.39, 0.90})
        mainWindow:SetColor("TitleBg", {0.12, 0.12, 0.12, 1.00})
        mainWindow:SetColor("TitleBgActive", {0.09, 0.09, 0.09, 1.00})
        mainWindow:SetColor("TitleBgCollapsed", {0.05, 0.05, 0.05, 1.00})
        mainWindow:SetColor("MenuBarBg", {0.07, 0.07, 0.07, 1.00})
        mainWindow:SetColor("ScrollbarBg", {0.23, 0.23, 0.23, 0.00})
        mainWindow:SetColor("ScrollbarGrab", {0.23, 0.23, 0.23, 1.00})
        mainWindow:SetColor("ScrollbarGrabHovered", {0.58, 0.58, 0.58, 1.00})
        mainWindow:SetColor("ScrollbarGrabActive", {0.58, 0.58, 0.58, 1.00})
        mainWindow:SetColor("CheckMark", {0.94, 0.94, 0.94, 1.00})
        mainWindow:SetColor("SliderGrab", {0.2, 0.2, 0.2, 1.00})
        mainWindow:SetColor("SliderGrabActive", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("Button", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("ButtonHovered", {0.25, 0.25, 0.25, 1.00})
        mainWindow:SetColor("ButtonActive", {0.34, 0.34, 0.34, 1.00})
        mainWindow:SetColor("Header", {0.08, 0.08, 0.08, 1.00})
        mainWindow:SetColor("HeaderHovered", {0.2, 0.2, 0.2, 1.00})
        mainWindow:SetColor("HeaderActive", {0.08, 0.08, 0.08, 1.00})
        mainWindow:SetColor("Separator", {1.00, 0.61, 0.61, 1.00})
        mainWindow:SetColor("SeparatorHovered", {1.00, 0.61, 0.61, 1.00})
        mainWindow:SetColor("SeparatorActive", {1.00, 0.64, 0.64, 0.78})
        mainWindow:SetColor("ResizeGrip", {0.13, 0.13, 0.13, 1.00})
        mainWindow:SetColor("ResizeGripHovered", {0.87, 0.53, 0.53, 1.00})
        mainWindow:SetColor("ResizeGripActive", {0.72, 0.44, 0.44, 1.00})
        mainWindow:SetColor("Tab", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("TabHovered", {0.25, 0.25, 0.25, 1.00})
        mainWindow:SetColor("TabActive", {0.34, 0.34, 0.34, 1.00})

        Style.ApplyCommonStyles(mainWindow)

    end
}

Style.MainWindow2 = {
    Main2 = function(mainWindow)
        -- Colors settings _ai
        mainWindow:SetColor("Text", {0.90, 0.85, 0.95, 1.00})
        mainWindow:SetColor("TextDisabled", {0.60, 0.55, 0.65, 1.00}) 
        mainWindow:SetColor("WindowBg", {0.07, 0.03, 0.12, 1.00})
        mainWindow:SetColor("ChildBg", {0.10, 0.06, 0.16, 1.00}) 
        mainWindow:SetColor("PopupBg", {0.12, 0.08, 0.18, 1.00})
        mainWindow:SetColor("Border", {0.20, 0.10, 0.25, 1.00})
        mainWindow:SetColor("BorderShadow", {0.05, 0.02, 0.08, 1.00})
        mainWindow:SetColor("FrameBg", {0.14, 0.07, 0.20, 1.00})
        mainWindow:SetColor("FrameBgHovered", {0.20, 0.12, 0.28, 0.92})
        mainWindow:SetColor("FrameBgActive", {0.30, 0.15, 0.40, 0.90})
        mainWindow:SetColor("TitleBg", {0.10, 0.05, 0.15, 1.00})
        mainWindow:SetColor("TitleBgActive", {0.15, 0.08, 0.22, 1.00})
        mainWindow:SetColor("TitleBgCollapsed", {0.05, 0.03, 0.10, 1.00})
        mainWindow:SetColor("MenuBarBg", {0.12, 0.07, 0.18, 1.00})
        mainWindow:SetColor("ScrollbarBg", {0.08, 0.05, 0.12, 0.00})
        mainWindow:SetColor("ScrollbarGrab", {0.25, 0.15, 0.35, 1.00})
        mainWindow:SetColor("ScrollbarGrabHovered", {0.35, 0.20, 0.45, 1.00})
        mainWindow:SetColor("ScrollbarGrabActive", {0.40, 0.25, 0.50, 1.00})
        mainWindow:SetColor("CheckMark", {0.80, 0.60, 1.00, 1.00})
        mainWindow:SetColor("SliderGrab", {0.70, 0.40, 0.90, 1.00})
        mainWindow:SetColor("SliderGrabActive", {0.80, 0.50, 1.00, 1.00})
        mainWindow:SetColor("Button", {0.15, 0.10, 0.25, 1.00})
        mainWindow:SetColor("ButtonHovered", {0.25, 0.15, 0.35, 1.00})
        mainWindow:SetColor("ButtonActive", {0.35, 0.20, 0.45, 1.00})
        mainWindow:SetColor("Header", {0.10, 0.06, 0.18, 1.00})
        mainWindow:SetColor("HeaderHovered", {0.20, 0.12, 0.30, 1.00})
        mainWindow:SetColor("HeaderActive", {0.30, 0.15, 0.40, 1.00})
        mainWindow:SetColor("Separator", {0.50, 0.30, 0.60, 1.00})
        mainWindow:SetColor("SeparatorHovered", {0.65, 0.40, 0.75, 1.00})
        mainWindow:SetColor("SeparatorActive", {0.75, 0.50, 0.85, 0.90})
        mainWindow:SetColor("ResizeGrip", {0.20, 0.10, 0.30, 1.00})
        mainWindow:SetColor("ResizeGripHovered", {0.50, 0.30, 0.70, 1.00})
        mainWindow:SetColor("ResizeGripActive", {0.60, 0.40, 0.80, 1.00})
        mainWindow:SetColor("Tab", {0.10, 0.07, 0.20, 1.00})
        mainWindow:SetColor("TabHovered", {0.20, 0.12, 0.30, 1.00})
        mainWindow:SetColor("TabActive", {0.30, 0.18, 0.40, 1.00})

        Style.ApplyCommonStyles(mainWindow)
    end
}

-- Blue theme _ai
Style.MainWindow3 = {
    Main3 = function(mainWindow)
        mainWindow:SetColor("Text", {0.88, 0.92, 0.96, 1.00})
        mainWindow:SetColor("TextDisabled", {0.60, 0.65, 0.70, 1.00})
        mainWindow:SetColor("WindowBg", {0.04, 0.10, 0.16, 1.00})
        mainWindow:SetColor("ChildBg", {0.06, 0.12, 0.18, 1.00})
        mainWindow:SetColor("PopupBg", {0.08, 0.14, 0.20, 1.00})
        mainWindow:SetColor("Border", {0.12, 0.16, 0.22, 1.00})
        mainWindow:SetColor("BorderShadow", {0.02, 0.04, 0.08, 1.00})
        mainWindow:SetColor("FrameBg", {0.10, 0.14, 0.20, 1.00})
        mainWindow:SetColor("FrameBgHovered", {0.16, 0.22, 0.30, 0.92})
        mainWindow:SetColor("FrameBgActive", {0.20, 0.28, 0.38, 0.90})
        mainWindow:SetColor("TitleBg", {0.06, 0.12, 0.18, 1.00})
        mainWindow:SetColor("TitleBgActive", {0.08, 0.14, 0.22, 1.00})
        mainWindow:SetColor("TitleBgCollapsed", {0.04, 0.08, 0.12, 1.00})
        mainWindow:SetColor("MenuBarBg", {0.08, 0.14, 0.20, 1.00})
        mainWindow:SetColor("ScrollbarBg", {0.10, 0.16, 0.24, 0.00})
        mainWindow:SetColor("ScrollbarGrab", {0.20, 0.28, 0.38, 1.00})
        mainWindow:SetColor("ScrollbarGrabHovered", {0.28, 0.36, 0.48, 1.00})
        mainWindow:SetColor("ScrollbarGrabActive", {0.32, 0.40, 0.52, 1.00})
        mainWindow:SetColor("CheckMark", {0.88, 0.92, 0.96, 1.00})
        mainWindow:SetColor("SliderGrab", {0.40, 0.48, 0.60, 1.00})
        mainWindow:SetColor("SliderGrabActive", {0.48, 0.56, 0.70, 1.00})
        mainWindow:SetColor("Button", {0.12, 0.18, 0.28, 1.00})
        mainWindow:SetColor("ButtonHovered", {0.20, 0.26, 0.38, 1.00})
        mainWindow:SetColor("ButtonActive", {0.28, 0.34, 0.48, 1.00})
        mainWindow:SetColor("Header", {0.10, 0.16, 0.24, 1.00})
        mainWindow:SetColor("HeaderHovered", {0.16, 0.22, 0.34, 1.00})
        mainWindow:SetColor("HeaderActive", {0.20, 0.28, 0.42, 1.00})
        mainWindow:SetColor("Separator", {0.32, 0.40, 0.50, 1.00})
        mainWindow:SetColor("SeparatorHovered", {0.40, 0.48, 0.60, 1.00})
        mainWindow:SetColor("SeparatorActive", {0.48, 0.56, 0.70, 0.90})
        mainWindow:SetColor("ResizeGrip", {0.16, 0.24, 0.34, 1.00})
        mainWindow:SetColor("ResizeGripHovered", {0.32, 0.40, 0.52, 1.00})
        mainWindow:SetColor("ResizeGripActive", {0.40, 0.48, 0.60, 1.00})
        mainWindow:SetColor("Tab", {0.10, 0.14, 0.20, 1.00})
        mainWindow:SetColor("TabHovered", {0.18, 0.24, 0.32, 1.00})
        mainWindow:SetColor("TabActive", {0.24, 0.30, 0.40, 1.00})

        Style.ApplyCommonStyles(mainWindow)
    end
}

-- Green theme _ai
Style.MainWindow4 = {
    Main4 = function(mainWindow)
        mainWindow:SetColor("Text", {0.85, 0.92, 0.80, 1.00})
        mainWindow:SetColor("TextDisabled", {0.50, 0.58, 0.48, 1.00})
        mainWindow:SetColor("WindowBg", {0.08, 0.12, 0.08, 1.00})
        mainWindow:SetColor("ChildBg", {0.10, 0.14, 0.10, 1.00})
        mainWindow:SetColor("PopupBg", {0.12, 0.18, 0.12, 1.00})
        mainWindow:SetColor("Border", {0.16, 0.22, 0.18, 1.00})
        mainWindow:SetColor("BorderShadow", {0.04, 0.06, 0.04, 1.00})
        mainWindow:SetColor("FrameBg", {0.14, 0.20, 0.14, 1.00})
        mainWindow:SetColor("FrameBgHovered", {0.18, 0.26, 0.18, 0.92})
        mainWindow:SetColor("FrameBgActive", {0.22, 0.30, 0.22, 0.90})
        mainWindow:SetColor("TitleBg", {0.10, 0.14, 0.10, 1.00})
        mainWindow:SetColor("TitleBgActive", {0.12, 0.18, 0.12, 1.00})
        mainWindow:SetColor("TitleBgCollapsed", {0.08, 0.10, 0.08, 1.00})
        mainWindow:SetColor("MenuBarBg", {0.12, 0.16, 0.12, 1.00})
        mainWindow:SetColor("ScrollbarBg", {0.10, 0.14, 0.10, 0.00})
        mainWindow:SetColor("ScrollbarGrab", {0.20, 0.28, 0.20, 1.00})
        mainWindow:SetColor("ScrollbarGrabHovered", {0.26, 0.34, 0.26, 1.00})
        mainWindow:SetColor("ScrollbarGrabActive", {0.30, 0.40, 0.30, 1.00})
        mainWindow:SetColor("CheckMark", {0.76, 0.88, 0.72, 1.00})
        mainWindow:SetColor("SliderGrab", {0.50, 0.68, 0.50, 1.00})
        mainWindow:SetColor("SliderGrabActive", {0.60, 0.80, 0.60, 1.00})
        mainWindow:SetColor("Button", {0.16, 0.22, 0.16, 1.00})
        mainWindow:SetColor("ButtonHovered", {0.20, 0.28, 0.20, 1.00})
        mainWindow:SetColor("ButtonActive", {0.26, 0.34, 0.26, 1.00})
        mainWindow:SetColor("Header", {0.14, 0.20, 0.14, 1.00})
        mainWindow:SetColor("HeaderHovered", {0.18, 0.26, 0.18, 1.00})
        mainWindow:SetColor("HeaderActive", {0.22, 0.30, 0.22, 1.00})
        mainWindow:SetColor("Separator", {0.40, 0.50, 0.40, 1.00})
        mainWindow:SetColor("SeparatorHovered", {0.48, 0.60, 0.48, 1.00})
        mainWindow:SetColor("SeparatorActive", {0.58, 0.72, 0.58, 0.90})
        mainWindow:SetColor("ResizeGrip", {0.16, 0.22, 0.16, 1.00})
        mainWindow:SetColor("ResizeGripHovered", {0.28, 0.36, 0.28, 1.00})
        mainWindow:SetColor("ResizeGripActive", {0.34, 0.44, 0.34, 1.00})
        mainWindow:SetColor("Tab", {0.14, 0.18, 0.14, 1.00})
        mainWindow:SetColor("TabHovered", {0.20, 0.28, 0.20, 1.00})
        mainWindow:SetColor("TabActive", {0.26, 0.34, 0.26, 1.00})
        
        Style.ApplyCommonStyles(mainWindow)
    end
}

-- Warm Gold theme _ai
Style.MainWindow5 = {
    Main5 = function(mainWindow)

        mainWindow:SetColor("Text", {0.95, 0.88, 0.70, 1.00})
        mainWindow:SetColor("TextDisabled", {0.60, 0.50, 0.38, 1.00})
        mainWindow:SetColor("WindowBg", {0.12, 0.08, 0.06, 1.00})
        mainWindow:SetColor("ChildBg", {0.16, 0.12, 0.10, 1.00})
        mainWindow:SetColor("PopupBg", {0.18, 0.14, 0.12, 1.00})
        mainWindow:SetColor("Border", {0.30, 0.24, 0.20, 1.00})
        mainWindow:SetColor("BorderShadow", {0.08, 0.06, 0.04, 1.00})
        mainWindow:SetColor("FrameBg", {0.20, 0.16, 0.12, 1.00})
        mainWindow:SetColor("FrameBgHovered", {0.28, 0.22, 0.16, 0.92})
        mainWindow:SetColor("FrameBgActive", {0.34, 0.28, 0.20, 0.90})
        mainWindow:SetColor("TitleBg", {0.14, 0.10, 0.08, 1.00})
        mainWindow:SetColor("TitleBgActive", {0.18, 0.12, 0.10, 1.00})
        mainWindow:SetColor("TitleBgCollapsed", {0.10, 0.08, 0.06, 1.00})
        mainWindow:SetColor("MenuBarBg", {0.20, 0.16, 0.12, 1.00})
        mainWindow:SetColor("ScrollbarBg", {0.18, 0.14, 0.12, 0.00})
        mainWindow:SetColor("ScrollbarGrab", {0.28, 0.22, 0.16, 1.00})
        mainWindow:SetColor("ScrollbarGrabHovered", {0.36, 0.28, 0.20, 1.00})
        mainWindow:SetColor("ScrollbarGrabActive", {0.42, 0.34, 0.26, 1.00})
        mainWindow:SetColor("CheckMark", {0.90, 0.80, 0.60, 1.00})
        mainWindow:SetColor("SliderGrab", {0.50, 0.40, 0.28, 1.00})
        mainWindow:SetColor("SliderGrabActive", {0.62, 0.50, 0.36, 1.00})
        mainWindow:SetColor("Button", {0.22, 0.18, 0.12, 1.00})
        mainWindow:SetColor("ButtonHovered", {0.30, 0.24, 0.18, 1.00})
        mainWindow:SetColor("ButtonActive", {0.38, 0.30, 0.22, 1.00})
        mainWindow:SetColor("Header", {0.18, 0.14, 0.10, 1.00})
        mainWindow:SetColor("HeaderHovered", {0.24, 0.20, 0.14, 1.00})
        mainWindow:SetColor("HeaderActive", {0.30, 0.24, 0.18, 1.00})
        mainWindow:SetColor("Separator", {0.60, 0.48, 0.36, 1.00})
        mainWindow:SetColor("SeparatorHovered", {0.72, 0.58, 0.42, 1.00})
        mainWindow:SetColor("SeparatorActive", {0.84, 0.68, 0.52, 0.90})
        mainWindow:SetColor("ResizeGrip", {0.20, 0.16, 0.12, 1.00})
        mainWindow:SetColor("ResizeGripHovered", {0.40, 0.32, 0.24, 1.00})
        mainWindow:SetColor("ResizeGripActive", {0.50, 0.40, 0.30, 1.00})
        mainWindow:SetColor("Tab", {0.20, 0.16, 0.12, 1.00})
        mainWindow:SetColor("TabHovered", {0.30, 0.24, 0.18, 1.00})
        mainWindow:SetColor("TabActive", {0.38, 0.30, 0.22, 1.00})
        
        Style.ApplyCommonStyles(mainWindow)
    end
}

-- Sunset theme _ai
Style.MainWindow6 = {
    Main6 = function(mainWindow)
        
        mainWindow:SetColor("Text", {0.85, 0.80, 0.95, 1.00})
        mainWindow:SetColor("TextDisabled", {0.60, 0.55, 0.70, 1.00})
        mainWindow:SetColor("WindowBg", {0.08, 0.06, 0.12, 1.00})
        mainWindow:SetColor("ChildBg", {0.10, 0.08, 0.16, 1.00})
        mainWindow:SetColor("PopupBg", {0.12, 0.10, 0.20, 1.00})
        mainWindow:SetColor("Border", {0.18, 0.16, 0.28, 1.00})
        mainWindow:SetColor("BorderShadow", {0.04, 0.02, 0.06, 1.00})
        mainWindow:SetColor("FrameBg", {0.10, 0.08, 0.16, 1.00})
        mainWindow:SetColor("FrameBgHovered", {0.14, 0.12, 0.22, 0.90})
        mainWindow:SetColor("FrameBgActive", {0.18, 0.16, 0.30, 0.80})
        mainWindow:SetColor("TitleBg", {0.08, 0.06, 0.14, 1.00})
        mainWindow:SetColor("TitleBgActive", {0.12, 0.10, 0.20, 1.00})
        mainWindow:SetColor("TitleBgCollapsed", {0.06, 0.04, 0.10, 1.00})
        mainWindow:SetColor("MenuBarBg", {0.10, 0.08, 0.16, 1.00})
        mainWindow:SetColor("ScrollbarBg", {0.08, 0.06, 0.12, 0.00})
        mainWindow:SetColor("ScrollbarGrab", {0.20, 0.18, 0.32, 1.00})
        mainWindow:SetColor("ScrollbarGrabHovered", {0.26, 0.24, 0.40, 1.00})
        mainWindow:SetColor("ScrollbarGrabActive", {0.32, 0.30, 0.48, 1.00})
        mainWindow:SetColor("CheckMark", {0.76, 0.70, 0.88, 1.00})
        mainWindow:SetColor("SliderGrab", {0.42, 0.38, 0.58, 1.00})
        mainWindow:SetColor("SliderGrabActive", {0.50, 0.46, 0.68, 1.00})
        mainWindow:SetColor("Button", {0.12, 0.10, 0.20, 1.00})
        mainWindow:SetColor("ButtonHovered", {0.18, 0.16, 0.30, 1.00})
        mainWindow:SetColor("ButtonActive", {0.24, 0.22, 0.36, 1.00})
        mainWindow:SetColor("Header", {0.14, 0.12, 0.24, 1.00})
        mainWindow:SetColor("HeaderHovered", {0.20, 0.18, 0.32, 1.00})
        mainWindow:SetColor("HeaderActive", {0.26, 0.24, 0.40, 1.00})
        mainWindow:SetColor("Separator", {0.50, 0.46, 0.70, 1.00})
        mainWindow:SetColor("SeparatorHovered", {0.60, 0.56, 0.80, 1.00})
        mainWindow:SetColor("SeparatorActive", {0.70, 0.66, 0.90, 0.90})
        mainWindow:SetColor("ResizeGrip", {0.16, 0.14, 0.26, 1.00})
        mainWindow:SetColor("ResizeGripHovered", {0.26, 0.24, 0.40, 1.00})
        mainWindow:SetColor("ResizeGripActive", {0.32, 0.30, 0.48, 1.00})
        mainWindow:SetColor("Tab", {0.14, 0.12, 0.24, 1.00})
        mainWindow:SetColor("TabHovered", {0.20, 0.18, 0.32, 1.00})
        mainWindow:SetColor("TabActive", {0.26, 0.24, 0.40, 1.00})
                     
        Style.ApplyCommonStyles(mainWindow)
    end
}


Style.MainWindow7 = {
    Main7 = function(mainWindow)
        
        mainWindow:SetColor("Text", {1.00, 1.00, 1.00, 1.00})
        mainWindow:SetColor("TextDisabled", {0.50, 0.50, 0.50, 1.00})
        mainWindow:SetColor("WindowBg", {0.08, 0.08, 0.08, 1})
        mainWindow:SetColor("ChildBg", {0.14, 0.14, 0.14, 1})
        mainWindow:SetColor("PopupBg", {0.08, 0.08, 0.08, 1})
        mainWindow:SetColor("Border", {0.43, 0.43, 0.50, 0.50})
        mainWindow:SetColor("BorderShadow", {0.00, 0.00, 0.00, 0.00})
        mainWindow:SetColor("FrameBg", {0.16, 0.29, 0.48, 0.54})
        mainWindow:SetColor("FrameBgHovered", {0.26, 0.59, 0.98, 0.40})
        mainWindow:SetColor("FrameBgActive", {0.26, 0.59, 0.98, 0.67})
        mainWindow:SetColor("TitleBg", {0.04, 0.04, 0.04, 1.00})
        mainWindow:SetColor("TitleBgActive", {0.16, 0.29, 0.48, 1.00})
        mainWindow:SetColor("TitleBgCollapsed", {0.00, 0.00, 0.00, 0.51})
        mainWindow:SetColor("MenuBarBg", {0.14, 0.14, 0.14, 1.00})
        mainWindow:SetColor("ScrollbarBg", {0.02, 0.02, 0.02, 0.53})
        mainWindow:SetColor("ScrollbarGrab", {0.31, 0.31, 0.31, 1.00})
        mainWindow:SetColor("ScrollbarGrabHovered", {0.41, 0.41, 0.41, 1.00})
        mainWindow:SetColor("ScrollbarGrabActive", {0.51, 0.51, 0.51, 1.00})
        mainWindow:SetColor("CheckMark", {0.26, 0.59, 0.98, 1.00})
        mainWindow:SetColor("SliderGrab", {0.24, 0.52, 0.88, 1.00})
        mainWindow:SetColor("SliderGrabActive", {0.26, 0.59, 0.98, 1.00})
        mainWindow:SetColor("Button", {0.26, 0.59, 0.98, 0.40})
        mainWindow:SetColor("ButtonHovered", {0.26, 0.59, 0.98, 1.00})
        mainWindow:SetColor("ButtonActive", {0.06, 0.53, 0.98, 1.00})
        mainWindow:SetColor("Header", {0.26, 0.59, 0.98, 0.31})
        mainWindow:SetColor("HeaderHovered", {0.26, 0.59, 0.98, 0.80})
        mainWindow:SetColor("HeaderActive", {0.26, 0.59, 0.98, 1.00})
        mainWindow:SetColor("Separator", {0.43, 0.43, 0.50, 0.50})
        mainWindow:SetColor("SeparatorHovered", {0.10, 0.40, 0.75, 0.78})
        mainWindow:SetColor("SeparatorActive", {0.10, 0.40, 0.75, 1.00})
        mainWindow:SetColor("ResizeGrip", {0.26, 0.59, 0.98, 0.20})
        mainWindow:SetColor("ResizeGripHovered", {0.26, 0.59, 0.98, 0.67})
        mainWindow:SetColor("ResizeGripActive", {0.26, 0.59, 0.98, 0.95})
        mainWindow:SetColor("Tab", {0.18, 0.35, 0.58, 0.86})
        mainWindow:SetColor("TabHovered", {0.26, 0.59, 0.98, 0.80})
        mainWindow:SetColor("TabActive", {0.20, 0.41, 0.68, 1.00})
        mainWindow:SetColor("TabUnfocused", {0.07, 0.10, 0.15, 0.97})
        mainWindow:SetColor("TabUnfocusedActive", {0.14, 0.26, 0.42, 1.00})
        
        Style.ApplyCommonStyles(mainWindow)
        
        mainWindow:SetStyle("WindowRounding", 0)
        mainWindow:SetStyle("ChildRounding", 0)
        mainWindow:SetStyle("FrameRounding", 0)
        mainWindow:SetStyle("PopupRounding", 0)
        mainWindow:SetStyle("ScrollbarRounding", 0)
        mainWindow:SetStyle("GrabRounding", 0)
        mainWindow:SetStyle("TabRounding", 0)
        mainWindow:SetStyle("ButtonTextAlign", 0.5, 0.5)


    end
}

Style.MainWindow8 = {
    Main8 = function(mainWindow)

        mainWindow:SetColor("Text", {0.94, 0.94, 0.94, 1.00})
        mainWindow:SetColor("TextDisabled", {0.60, 0.60, 0.60, 1.00})
        mainWindow:SetColor("WindowBg", {0.08, 0.08, 0.08, 1.00})
        mainWindow:SetColor("ChildBg", {0.11, 0.11, 0.11, 1.00})
        mainWindow:SetColor("PopupBg", {0.1, 0.1, 0.1, 1.00})
        mainWindow:SetColor("Border", {0.07, 0.07, 0.07, 1.00})
        mainWindow:SetColor("BorderShadow", {0.07, 0.07, 0.07, 1.00})
        mainWindow:SetColor("FrameBg", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("FrameBgHovered", {0.27, 0.27, 0.27, 0.92})
        mainWindow:SetColor("FrameBgActive", {0.39, 0.39, 0.39, 0.90})
        mainWindow:SetColor("TitleBg", {0.12, 0.12, 0.12, 1.00})
        mainWindow:SetColor("TitleBgActive", {0.09, 0.09, 0.09, 1.00})
        mainWindow:SetColor("TitleBgCollapsed", {0.05, 0.05, 0.05, 1.00})
        mainWindow:SetColor("MenuBarBg", {0.07, 0.07, 0.07, 1.00})
        mainWindow:SetColor("ScrollbarBg", {0.23, 0.23, 0.23, 0.00})
        mainWindow:SetColor("ScrollbarGrab", {0.23, 0.23, 0.23, 1.00})
        mainWindow:SetColor("ScrollbarGrabHovered", {0.58, 0.58, 0.58, 1.00})
        mainWindow:SetColor("ScrollbarGrabActive", {0.58, 0.58, 0.58, 1.00})
        mainWindow:SetColor("CheckMark", {0.94, 0.94, 0.94, 1.00})
        mainWindow:SetColor("SliderGrab", {0.2, 0.2, 0.2, 1.00})
        mainWindow:SetColor("SliderGrabActive", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("Button", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("ButtonHovered", {0.25, 0.25, 0.25, 1.00})
        mainWindow:SetColor("ButtonActive", {0.34, 0.34, 0.34, 1.00})
        mainWindow:SetColor("Header", {0.08, 0.08, 0.08, 1.00})
        mainWindow:SetColor("HeaderHovered", {0.2, 0.2, 0.2, 1.00})
        mainWindow:SetColor("HeaderActive", {0.08, 0.08, 0.08, 1.00})
        mainWindow:SetColor("Separator", {0.557, 0.118, 0.314, 1.00})
        mainWindow:SetColor("SeparatorHovered", {0.557, 0.118, 0.314, 1.00})
        mainWindow:SetColor("SeparatorActive", {0.557, 0.118, 0.314, 0.78})
        mainWindow:SetColor("ResizeGrip", {0.13, 0.13, 0.13, 1.00})
        mainWindow:SetColor("ResizeGripHovered", {0.557, 0.118, 0.314, 1.00})
        mainWindow:SetColor("ResizeGripActive", {0.557, 0.118, 0.314, 0.95})
        mainWindow:SetColor("Tab", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("TabHovered", {0.25, 0.25, 0.25, 1.00})
        mainWindow:SetColor("TabActive", {0.34, 0.34, 0.34, 1.00})

        Style.ApplyCommonStyles(mainWindow)

    end
}

return Style


