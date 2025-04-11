
-- VFX Entity

Ext.RegisterNetListener("vfxEntity", function(channel, payload)
    local function GetLightVFXEntity(light)
        local entClient = Ext.Entity.Get("UUID с сервера")
        DPrint(entClient)
        if entClient ~= nil then
            return vfxEntClient = entClient.Visual.Visual.Attachments[1].Visual.VisualEntity
        end
        DPrint(vfxEntClient)
    end
end)


-- Color

local function ChangeVFXHue(vfxEntClient, targetHue, targetHueAngleWidth)
    targetHueAngleWidth = targetHueAngleWidth or 15
    local components = vfxEntClient.Effect.Timeline.Components
    for _, component in ipairs(components) do
        for _, values in pairs(component.Properties) do
            if values.AttributeName == "Color" then
                for _, frame in ipairs(values.Frames) do
                    if not (frame.Color[1] == 1 and frame.Color[2] == 1 and frame.Color[3] == 1)
                    and not (frame.Color[1] == 0 and frame.Color[2] == 0 and frame.Color[3] == 0) then
                        local h, s, l = Color:RGB2HSL({frame.Color[1], frame.Color[2], frame.Color[3]})
                        local shiftedHue = HueShift(h * 360, targetHue, targetHueAngleWidth) / 360
                        local rgb = Color:HSL2RGB(shiftedHue, s, l)
                        rgb[4] = frame.Color[4]
                        frame.Color = rgb
                    end
                end
            end
        end
    end
end

local function ChangeSpellPrepColors()
    local effects = Ext.Entity.GetAllEntitiesWithComponent("Effect")
    for i, entity in ipairs(effects) do
        if string.find(entity.Effect.EffectName, "VFX_Spells_") then
            local components = entity.Effect.Timeline.Components
            for _, component in ipairs(components) do
                for property, values in pairs(component.Properties) do
                    if values.AttributeName == "Color" then
                        for _, frame in ipairs(values.Frames) do
                            if not (frame.Color[1] == 1 and frame.Color[2] == 1 and frame.Color[3] == 1)
                            and not (frame.Color[1] == 0 and frame.Color[2] == 0 and frame.Color[3] == 0) then
                                local h, s, l = Color:RGB2HSL({frame.Color[1], frame.Color[2], frame.Color[3]})
                                local shiftedHue = HueShift(h * 360, TargetHue, TargetAngleWidth) / 360
                                local rgb = Color:HSL2RGB(shiftedHue, s, l)
                                rgb[4] = frame.Color[4]
                                frame.Color = rgb
                            end
                        end
                    end
                end
            end
        end
    end
end


Possible fix

@Focus
            -- Get Entity and VFX with delay _ai
            Ext.OnNextTick(function()
                entClient[i] = Ext.Entity.Get(light.uuid)
                DPrint(string.format("[Client] entClient[%d] = %s (UUID: %s)", i, tostring(entClient[i]), light.uuid))
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
                            local attachments = vis2.Attachments
                            if attachments ~= nil then
                                for attachNum, attachment in pairs(attachments) do
                                    local attachVis = attachment.Visual
                                    if attachVis ~= nil then
                                        local attachVisEntity = attachVis.Entity
                                        if attachVisEntity ~= nil then
                                            DPrint(string.format("Attachment %s visual entity found after % ticks.", attachNum, tick))
                                            vfxEntClient[i] = attachVisEntity
                                            DPrint(string.format("[Client] vfxEntClient[%d] = %s (from entClient UUID: %s)", i, tostring(vfxEntClient[i]), light.uuid))
                                            Ext.Events.Tick:Unsubscribe(handlerId)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)



"You could also wrap the attachment access in a pcall to prevent the error from terminating the function, but it can be nice to check each property on a separate line if you wanted to see how the entity populates over time."
---@param entity EntityHandle
---@return EntityHandle|nil
local function GetVisualAttachmentEntity(entity)
    return entity.Visual.Visual.Attachments[1].Visual.VisualEntity
end

-- Near line 16
            -- Get Entity and VFX with delay _ai
            Ext.OnNextTick(function()
                entClient[i] = Ext.Entity.Get(light.uuid)
                DPrint(string.format("[Client] entClient[%d] = %s (UUID: %s)", i, tostring(entClient[i]), light.uuid))

                local handlerId
                handlerId = Ext.Events.Tick:Subscribe(function()
                    local b, vfxEntity = pcall(GetVisualAttachmentEntity, entClient[i])
                    if b and vfxEntity then
                        vfxEntClient[i] = vfxEntity
                        DPrint(string.format("[Client] vfxEntClient[%d] = %s (from entClient UUID: %s)", i, tostring(vfxEntClient[i]), light.uuid))
                        Ext.Events.Tick:Unsubscribe(handlerId)
                    end
                end)
            end)



--Kelvin2RGB js

// From http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/

    // Start with a temperature, in Kelvin, somewhere between 1000 and 40000.  (Other values may work,
    //  but I can't make any promises about the quality of the algorithm's estimates above 40000 K.)

    
function colorTemperatureToRGB(kelvin){
    var temp = kelvin / 100;
    var red, green, blue;
    if( temp <= 66 ){ 
        red = 255; 
        green = temp;
        green = 99.4708025861 * Math.log(green) - 161.1195681661;
        if( temp <= 19){
            blue = 0;
        } else {
            blue = temp-10;
            blue = 138.5177312231 * Math.log(blue) - 305.0447927307;
        }
    } else {
        red = temp - 60;
        red = 329.698727446 * Math.pow(red, -0.1332047592);
        green = temp - 60;
        green = 288.1221695283 * Math.pow(green, -0.0755148492 );
        blue = 255;
    }
    return {
        r : clamp(red,   0, 255),
        g : clamp(green, 0, 255),
        b : clamp(blue,  0, 255)
    }
}

function clamp( x, min, max ) {
    if(x<min){ return min; }
    if(x>max){ return max; }
    return x;
}




--Material color

local function UpdateMaterial(material, color)
    for i,param in ipairs(material.MaterialInstance.Parameters.Vector3Parameters) do
        if param.ParameterName == "Cloth_Primary" then
            material:SetVector3("Cloth_Primary", color)
        end
    end
end

local function UpdateVisualMaterial(visual, color)
    for i,attachment in pairs(visual.Attachments) do
        UpdateVisualMaterial(attachment.Visual, color)
    end

    for i,desc in pairs(visual.ObjectDescs) do
        UpdateMaterial(desc.Renderable.ActiveMaterial, color)
    end
end

local function SetClothColor(color)
    local c = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")[1]
    local visual = c.Visual.Visual
    UpdateVisualMaterial(visual, color)
end

local win = Ext.IMGUI.NewWindow("ColorTest")
local picker = win:AddColorPicker("Cloth_Primary")
picker.OnChange = function ()
    SetClothColor({picker.Color[1], picker.Color[2], picker.Color[3]})
end


material:SetScalar()
material:SetVector3()