UI = {}
Window = {}

local OPENONRESETQUESTIONMARK = true


function UI:Init()
    self.MCM = Window:LLMCM()
    self.Window = Window:LLWindow()
    self.Combo = Window:LightsCombo()
end




function Window:LLMCM()

    local function LightyLightsMCMTab(tab)

        local openButton = tab:AddButton("Open")
        openButton.OnClick = function()

            self.Window.Open = not self.Window.Open

        end
    end
    
    Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Lighty Lights", LightyLightsMCMTab)

end



function Window:LLWindow()

    self.Window = Ext.IMGUI.NewWindow("Lighty Lights")
    self.Window.Open = OPENONRESETQUESTIONMARK
    self.Window.Closeable = true
    self.Window.AlwaysAutoResize = false
    self.Window:SetSize({643, 700})
    -- self.Window.HorizontalScrollbar = true
    -- self.Window.AlwaysVerticalScrollbar = true
    -- self.Window.NoDecoration = true


    StyleV2:RegisterWindow(self.Window)

    ApplyStyle(self.Window, 1)

    parent = self.Window


end



function Window:LightsCombo()

    -- selectedClientWall = Walls[1]
    

    -- self.templatesCombo = parent:AddCombo('')
    -- self.templatesCombo.IDContext = 'comboClientOptions'
    -- self.templatesCombo.Options = lightTypeNames
    -- self.templatesCombo.SelectedIndex = 0
    -- self.templatesCombo.HeightLargest = true
    -- self.templatesCombo.OnChange = function()
    --     IndexToLightType(Window:TemplatesSelectedIndex())
    -- end

    local createButton = parent:AddButton('Create')
    createButton.SameLine = false
    createButton.IDContext = 'createBtn'
    createButton.OnClick = function ()
        CreateLight(IndexToLightType((Window:TemplatesSelectedIndex())))
    end

    local lightTypeText = parent:AddText('Type:')

    local createButton = parent:AddButton('Point')
    createButton.SameLine = false
    createButton.IDContext = 'Point'
    createButton.OnClick = function ()

    end

    local createButton = parent:AddButton('Spot')
    createButton.SameLine = false
    createButton.IDContext = 'Spot'
    createButton.OnClick = function ()

    end

    local createButton = parent:AddButton('Direction')
    createButton.SameLine = false
    createButton.IDContext = 'Spot'
    createButton.OnClick = function ()

    end

    self.createdCombo = parent:AddCombo('')
    self.createdCombo.IDContext = 'comboServerOPtions'
    self.createdCombo.Options = {} --createdWallsOptions
    self.createdCombo.SelectedIndex = 0
    self.createdCombo.HeightLargest = true
    self.createdCombo.OnChange = function()
        -- Ext.Net.PostMessageToServer("SelectedServerWall", tostring(self.comboWallsServer.SelectedIndex + 1))
        -- GetWallParameters()

    end

    local createdLightsText = parent:AddText('Created lights')
    createdLightsText.SameLine = true

    local renameInput = parent:AddInputText('')
    renameInput.IDContext = 'inputDasdasd'
    renameInput.OnChange = function ()

        
    end

    local renameButton = parent:AddButton('Rename')
    renameButton.IDContext = 'sdfkasdf'
    renameButton.SameLine = true
    renameButton.OnClick = function ()
        
    end


    local dupeButton = parent:AddButton('Duplicate')
    dupeButton.IDContext = 'dupeBtn'
    -- self.dupeButton:SetColor("Button", {0.10, 0.10, 0.10, 1.00})
    dupeButton.SameLine = false
    dupeButton.Disabled = false
    dupeButton.OnClick = function ()
        -- Ext.Net.PostMessageToServer("DupeWall", Ext.Json.Stringify(selectedClientWall))
        -- DDump(selectedClientWall)
        -- Ext.Net.PostMessageToServer("SelectedServerWall", tostring(#createdWallsOptions + 1))
    end

    local dupe2Button = parent:AddButton('Duplicate 2')
    dupe2Button.IDContext = 'dupeBtn2'
    -- self.dupeButton:SetColor("Button", {0.10, 0.10, 0.10, 1.00})
    dupe2Button.SameLine = true
    dupe2Button.Disabled = false
    dupeButton.OnClick = function ()
        -- Ext.Net.PostMessageToServer("DupeWall", Ext.Json.Stringify(selectedClientWall))
        -- DDump(selectedClientWall)
        -- Ext.Net.PostMessageToServer("SelectedServerWall", tostring(#createdWallsOptions + 1))
    end




    local deleteButton = parent:AddButton('Delete')
    deleteButton.IDContext = 'dupeBtn'
    deleteButton.SameLine = true
    deleteButton.OnClick = function ()

        -- if self.comboWallsServer.SelectedIndex ~= -1 then

        --     Ext.Net.PostMessageToServer("DeleteWall", tostring(self.comboWallsServer.SelectedIndex + 1))
        --     local selectedIndex = self.comboWallsServer.SelectedIndex
        --     table.remove(createdWallsOptions, tonumber(self.comboWallsServer.SelectedIndex + 1))
        --     self.comboWallsServer.Options = createdWallsOptions
        --     -- DPrint(self.comboWallsServer.SelectedIndex)
        --     if self.comboWallsServer.SelectedIndex  == 0 then
        --         -- DPrint('xd')
        --         self.comboWallsServer.SelectedIndex = #createdWallsOptions
        --         Window:UpdateCombo()
        --     else
        --         -- DPrint('not xd')
        --         self.comboWallsServer.SelectedIndex = selectedIndex - 1
        --     end
        -- else
        --     return DPrint('No backgrounds')
        -- end

    end


    -- local deleteTimer = nil

    deleteAllButton = parent:AddButton('Delete all')
    deleteAllButton.IDContext = 'dupeBtn'
    deleteAllButton.SameLine = true

    deleteAllButton.OnClick = function ()
    --     deleteAllButton.Visible = false
    --     deleteAllConfirmButton.Visible = true

    --     deleteAllButton.Visible = false
    --     deleteAllConfirmButton.Visible = true

    --     deleteTimer = Ext.Timer.WaitFor(1000, function()
    --         deleteAllButton.Visible = true
    --         deleteAllConfirmButton.Visible = false
    -- end)

end

    local deleteAllConfirmButton = parent:AddButton('Confirm')

    deleteAllConfirmButton:SetColor("Button", {0.55, 0.0, 0.0, 1.00})
    deleteAllConfirmButton:SetColor("ButtonHovered", {0.35, 0.0, 0.0, 1.0})
    deleteAllConfirmButton:SetColor("ButtonActive", {0.25, 0.0, 0.0, 1.0})

    deleteAllConfirmButton.Visible = false
    deleteAllConfirmButton.IDContext = 'dupeBtn'
    deleteAllConfirmButton.SameLine = true
    deleteAllConfirmButton.OnClick = function ()

        -- Ext.Timer.Cancel(deleteTimer)

        -- deleteAllButton.Visible = true
        -- deleteAllConfirmButton.Visible = false

        -- Ext.Net.PostMessageToServer("DeleteAll", Ext.Json.Stringify(selectedClientWall))

        -- wallOptions = {}
        -- createdWallsOptions = {}
        -- createdWalls = {}

        -- Window:UpdateCombo()

    end


end

function Window:TemplatesSelectedIndex()
    return self.templatesCombo.SelectedIndex + 1
end




UI:Init()