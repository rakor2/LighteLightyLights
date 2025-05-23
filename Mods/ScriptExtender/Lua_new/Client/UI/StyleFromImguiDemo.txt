ImVec4* colors = ImGui::GetStyle().Colors;
colors[ImGuiCol_Text]                   = ImVec4(0.94f, 0.94f, 0.94f, 1.00f);
colors[ImGuiCol_TextDisabled]           = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
colors[ImGuiCol_WindowBg]               = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
colors[ImGuiCol_ChildBg]                = ImVec4(0.11f, 0.11f, 0.11f, 1.00f);
colors[ImGuiCol_PopupBg]                = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
colors[ImGuiCol_Border]                 = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
colors[ImGuiCol_BorderShadow]           = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
colors[ImGuiCol_FrameBg]                = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);
colors[ImGuiCol_FrameBgHovered]         = ImVec4(0.27f, 0.27f, 0.27f, 0.92f);
colors[ImGuiCol_FrameBgActive]          = ImVec4(0.39f, 0.39f, 0.39f, 0.90f);
colors[ImGuiCol_TitleBg]                = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
colors[ImGuiCol_TitleBgActive]          = ImVec4(0.09f, 0.09f, 0.09f, 1.00f);
colors[ImGuiCol_TitleBgCollapsed]       = ImVec4(0.05f, 0.05f, 0.05f, 1.00f);
colors[ImGuiCol_MenuBarBg]              = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
colors[ImGuiCol_ScrollbarBg]            = ImVec4(0.23f, 0.23f, 0.23f, 0.00f);
colors[ImGuiCol_ScrollbarGrab]          = ImVec4(0.23f, 0.23f, 0.23f, 1.00f);
colors[ImGuiCol_ScrollbarGrabHovered]   = ImVec4(0.58f, 0.58f, 0.58f, 1.00f);
colors[ImGuiCol_ScrollbarGrabActive]    = ImVec4(0.58f, 0.58f, 0.58f, 1.00f);
colors[ImGuiCol_CheckMark]              = ImVec4(0.94f, 0.94f, 0.94f, 1.00f);
colors[ImGuiCol_SliderGrab]             = ImVec4(0.55f, 0.55f, 0.55f, 0.00f);
colors[ImGuiCol_SliderGrabActive]       = ImVec4(0.55f, 0.55f, 0.55f, 0.00f);
colors[ImGuiCol_Button]                 = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);
colors[ImGuiCol_ButtonHovered]          = ImVec4(0.25f, 0.25f, 0.25f, 1.00f);
colors[ImGuiCol_ButtonActive]           = ImVec4(0.34f, 0.34f, 0.34f, 1.00f);
colors[ImGuiCol_Header]                 = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
colors[ImGuiCol_HeaderHovered]          = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
colors[ImGuiCol_HeaderActive]           = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
colors[ImGuiCol_Separator]              = ImVec4(1.00f, 0.61f, 0.61f, 1.00f);
colors[ImGuiCol_SeparatorHovered]       = ImVec4(1.00f, 0.61f, 0.61f, 1.00f);
colors[ImGuiCol_SeparatorActive]        = ImVec4(1.00f, 0.64f, 0.64f, 0.78f);
colors[ImGuiCol_ResizeGrip]             = ImVec4(0.13f, 0.13f, 0.13f, 1.00f);
colors[ImGuiCol_ResizeGripHovered]      = ImVec4(0.87f, 0.53f, 0.53f, 1.00f);
colors[ImGuiCol_ResizeGripActive]       = ImVec4(0.72f, 0.44f, 0.44f, 1.00f);
colors[ImGuiCol_TabHovered]             = ImVec4(0.25f, 0.25f, 0.25f, 1.00f);
colors[ImGuiCol_Tab]                    = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);
colors[ImGuiCol_TabSelected]            = ImVec4(0.34f, 0.34f, 0.34f, 1.00f);
colors[ImGuiCol_TabSelectedOverline]    = ImVec4(1.00f, 0.64f, 0.64f, 0.78f);

        -- Window styles from ImGui Demo _ai
        mainWindow:SetColor("Text", {0.94, 0.94, 0.94, 1.00})
        mainWindow:SetColor("TextDisabled", {0.60, 0.60, 0.60, 1.00})
        mainWindow:SetColor("WindowBg", {0.08, 0.08, 0.08, 1.00})
        mainWindow:SetColor("ChildBg", {0.11, 0.11, 0.11, 1.00})
        mainWindow:SetColor("PopupBg", {0.07, 0.07, 0.07, 1.00})
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
        mainWindow:SetColor("SliderGrab", {0.55, 0.55, 0.55, 0.00})
        mainWindow:SetColor("SliderGrabActive", {0.55, 0.55, 0.55, 0.00})
        mainWindow:SetColor("Button", {0.15, 0.15, 0.15, 1.00})
        mainWindow:SetColor("ButtonHovered", {0.25, 0.25, 0.25, 1.00})
        mainWindow:SetColor("ButtonActive", {0.34, 0.34, 0.34, 1.00})
        mainWindow:SetColor("Header", {0.08, 0.08, 0.08, 1.00})
        mainWindow:SetColor("HeaderHovered", {0.08, 0.08, 0.08, 1.00})
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

        mainWindow:SetStyle("ItemSpacing", 5)
        mainWindow:SetStyle("WindowPadding", 3, 3)
        mainWindow:SetStyle("WindowBorderSize", 0)
        mainWindow:SetStyle("ScrollbarSize", 15)
        mainWindow:SetStyle("FrameRounding", 2)
        mainWindow:SetStyle("WindowTitleAlign", 0.5)
        mainWindow:SetStyle("SeparatorTextBorderSize", 2)
        mainWindow:SetStyle("SeparatorTextPadding", 0, 1)
        mainWindow:SetStyle("SeparatorTextAlign", 0, 0.5)