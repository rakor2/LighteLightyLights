-- DDump(Light_Actual_Templates_Slots)

-- Light_Actual_Templates_Slots.Directional_5[1].active = true

function GetFreeSlots(lightType)
    freeSlots = {}
    for type, light in ipairs(lightType) do
        if light.active == false then
            table.insert(freeSlots, light)
        end
    end
    
    return freeSlots
end

function GetUsedSlots(lightType)
    usedSlots = {}
    for type, light in ipairs(lightType) do
        if light.active == true then
            table.insert(usedSlots, light)
        end
    end
    
    return usedSlots
end



for key, _ in pairs (Light_Actual_Templates_Slots) do
    GetFreeSlots(Light_Actual_Templates_Slots[key])
    GetUsedSlots(Light_Actual_Templates_Slots[key])
end


lightTypeNames = {
    "Point",
    "Directional 5°",
    "Directional 10°",
    "Directional 20°",
    "Directional 30°",
    "Directional 40°",
    "Directional 60°",
    "Directional 90°",
    "Directional 150°",
    "Directional 180°"
}


lightTypes = {
    "Point",
    "Directional_5",
    "Directional_10", 
    "Directional_20",
    "Directional_30",
    "Directional_40",
    "Directional_60",
    "Directional_90",
    "Directional_150",
    "Directional_180"
}


function IndexToLightType(index)
    return lightTypes[index]
end


function CreateLight(lightType)
    -- DPrint(lightType)
    local freeSlotsLight = GetFreeSlots(Light_Actual_Templates_Slots[lightType])

    -- if freeSlotsLight[1] ~= nil then
    --     DDump(freeSlotsLight)
    -- else
    --     DDump(usedSlots)
    -- end

    -- DDump(freeSlots)

    if freeSlotsLight[1] ~= nil then
        local light = freeSlotsLight[1].uuid

        DPrint('Sent UUID: ' .. light .. ' and type: ' .. tostring(lightType))

        local payload = {
            lightUuid = freeSlotsLight[1].uuid,
            lightType = tostring(lightType)
        }

        Ext.Net.PostMessageToServer('CreateLight', Ext.Json.Stringify(payload))

        freeSlotsLight[1].active = true
        table.insert(usedSlots, freeSlotsLight[1])
    else
        DPrint('No available slots')
    end
end

function DeleteLight(index, indexFromCombo)
    local usedLightSlots = GetUsedSlots(lightType)
    local light = usedLightSlots[indexFromCombo]
    
    if light then
        light.active = false
    end

end

-- for i = 1, 21 do 
-- CreateLight(Light_Actual_Templates_Slots.Directional_5)
-- end
-- DDump(usedSlots)


-- DeleteLight(Light_Actual_Templates_Slots.Directional_5, 3)
-- DeleteLight(Light_Actual_Templates_Slots.Directional_5, 5)
-- DeleteLight(Light_Actual_Templates_Slots.Directional_5, 1)
-- DeleteLight(Light_Actual_Templates_Slots.Directional_5, 20)
-- DDump(usedSlots)
-- CreateLight(Light_Actual_Templates_Slots.Directional_5)
-- DDump(usedSlots)
-- DDump(freeSlots)