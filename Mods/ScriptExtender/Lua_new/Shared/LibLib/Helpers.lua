---AahzLib
---Ext.OnNextTick, but variable ticks
---@param ticks integer
---@param fn function
function TickTimer(ticks, fn)
    local ticksPassed = 0
    local eventID
    eventID = Ext.Events.Tick:Subscribe(function()
        ticksPassed = ticksPassed + 1
        if ticksPassed >= ticks then
            fn()
            Ext.Events.Tick:Unsubscribe(eventID)
        end
    end)
end



---LibLib

Hellpers = {}


--Extracts name from a template, S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679 will return Player ShadowHeart
--Osi.DisplayName or whatever is bad, becasuse for some templates (most of them) it returns simple names like Elf or Goblin
---@param templateName string
---@return string
function ExtractDisplayName(templateName)
    if not templateName or templateName == "" then
        return "Unknown"
    end
    
    templateName = templateName:gsub("_%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$", "")

    local prefixes = {"S_", "GLO_", "BASE_", "GOB_", "LOW_", "CINE_", "FOR_", "WYR_", "PUZ_", "CAMP_", "CAMP_",
    "GUS_", "QUEST_", "ORIGIN_", "UNI_", "TEST_", "LOOT_", "TUT_", "WLD_", "INTRO_", "UND_", "EPI_", "TEMP_",
    "MOO_", "END_", "CAMP_", "CAMP_", "TWN_", "PLA_", "COL_", "SCL_"}
    for _, prefix in ipairs(prefixes) do
        if templateName:sub(1, #prefix) == prefix then
            templateName = templateName:sub(#prefix + 1)
        end
    end
    
    for _, prefix in ipairs(prefixes) do
        if templateName:sub(1, #prefix) == prefix then
            templateName = templateName:sub(#prefix + 1)
        end
    end

    templateName = templateName:gsub("_", " ")
    
    return templateName
end




--Shorts UUIDs
---@param uuid string
---@param howmuchleft integer
---@return ShortUuid string
function UUIDShortner(uuid, howmuchleft)
    if type(uuid) ~= "string" then
        return "?"
    end
    
    return string.sub(uuid, 1, howmuchleft)
end




--Gets templates by type
---@param type string
---@return string
function GetTemplates(type)
    templatesCache = {}
    if templatesCache[type] then
        return templatesCache[type]
    end

    local templates = Ext.Template.GetAllRootTemplates()
    
    local vanillaTemplates = {}
    for _, templateData in pairs(templates) do
        if templateData.TemplateType == type then
            table.insert(vanillaTemplates, templateData)
        end
    end
    
    templatesCache[type] = vanillaTemplates
    return vanillaTemplates
end



function Hellpers:GetUserID()
    local userID = _C().UserReservedFor.UserID
    return userID
end

function Hellpers:GetCameraEntity()
    local cameras = Ext.Entity.GetAllEntitiesWithComponent("Camera")
    for _, camera in ipairs(cameras) do
        if camera and camera.Camera.Active == true then
            local cameraEntity = camera
            return cameraEntity
        end
    end
end


function Hellpers:GetCameraData()

    local cameraEntity = Hellpers:GetCameraEntity()
                    
    local cameraPos = cameraEntity.GameCameraBehavior.field_150
    local targetPos = cameraEntity.GameCameraBehavior.TargetDestination

    return cameraPos, targetPos
end


-- function Hellpers:CameraLookAt()
--     local cameras = Ext.Entity.GetAllEntitiesWithComponent("Camera")
--     for _, cameraEntity in ipairs(cameras) do
--         local cameraComp = cameraEntity:GetAllComponents().Camera
--         if cameraComp and cameraComp.Active == true then
--             _D(cameraEntity.Camera.Controller.LookAt)
--             _D(cameraEntity.Transform)
--         end
--     end
-- end



function Hellpers:CameraPosition()

    local cameraEntity = Hellpers:GetCameraEntity()
    local cameraPos = cameraEntity.Transform
    return cameraPos
end


function Hellpers:CameraRotation()

    local cameraEntity = Hellpers:GetCameraEntity()
    local cameraRot = cameraEntity.RotationQuat
    return cameraRot
end


function Hellpers:GetHostPosition()
    if Ext.IsServer == true then
        local posServer = _C().Transform.Transform.Translate
        return posServer
    else
        local posClient = _C().Transform.Transform.Translate
        return posClient
    end
end


function Hellpers:FindTLPreviewDummyPlayer()
    timelineActorDataEntities = Ext.Entity.GetAllEntitiesWithComponent("TimelineActorData")
    for i = 1, #timelineActorDataEntities do
        if timelineActorDataEntities[i].TLPreviewDummy and timelineActorDataEntities[i].TLPreviewDummy.Name ~= "DUM_" then
            local dummyName = timelineActorDataEntities[i].TLPreviewDummy.Name
            local star_p, end_p = string.find(dummyName, "Player")
                if star_p then
                    playerDummyEntity = timelineActorDataEntities[i]
                    return playerDummyEntity
                end
        end
    end
end


function Hellpers:GetPlayerTLPreviewDummyPosition()
    local playerEntity = Hellpers:FindTLPreviewDummyPlayer()
    local tlDummyPos = playerEntity.Transform.Transform.Translate
    return tlDummyPos
end

function GetPlayerPosition(cameraEntity)
    cameraEntity = Hellpers:GetCameraEntity()
        if cameraEntity.Camera.PostProcess.DOF.DOF == true then

        else
        Hellpers:GetHostPosition()
    end
end


--Gets Translate of an entity
---@param uuid string
---@return entityTranslate table x,y,z
function Hellpers:GetEntTranslate(uuid)
    if Ext.IsServer == true then
        if Ext.Entity.Get(uuid).Transform then
            local entityTranslateServer = Ext.Entity.Get(uuid).Transform.Transform.Translate
            return entityTranslateServer
        end

    else
        if Ext.Entity.Get(uuid).Transform then
            local entityTranslateClient = Ext.Entity.Get(uuid).Transform.Transform.Translate
            return entityTranslateClient
        end
    end
    return nil
end


--Gets RotationQuat of an entity
---@param uuid string
---@return entityRotationQuat table x,y,z,w
function Hellpers:GetEntRotationQuat(uuid)
    if Ext.IsServer == true then
        if Ext.Entity.Get(uuid).Transform then
            local entityRotationQuatServer = Ext.Entity.Get(uuid).Transform.Transform.RotationQuat
            return entityRotationQuatServer
        end

    else
        if Ext.Entity.Get(uuid).Transform then
            local entityRotationQuatClient = Ext.Entity.Get(uuid).Transform.Transform.RotationQuat
            return entityRotationQuatClient
        end
    end
end


--Gets Scale of an entity
---@param uuid string
---@return entityTranslate table x,y,z
function Hellpers:GetEntScale(uuid)
    if Ext.IsServer == true then
        if Ext.Entity.Get(uuid).Transform then
            local entityScaleServer = Ext.Entity.Get(uuid).Transform.Transform.Scale
            return entityScaleServer
        end

    else
        if Ext.Entity.Get(uuid).Transform then
            local entityScaleClient = Ext.Entity.Get(uuid).Transform.Transform.Scale
            return entityScaleClient
        end
    end
end



function Hellpers:SetEntTranslate(entity, translate)
    if Ext.IsServer == true then
        if entity.Transform then
            entity.Transform.Transform.Translate = translate
        end

    else
        if entity.Transform then
            entity.Transform.Transform.Translate = translate
        end
    end
end



function Hellpers:SetEntRotationQuat(entity, rotationQuat)
    if Ext.IsServer == true then
        if entity.Transform then
            entity.Transform.Transform.RotationQuat = rotationQuat
        end

    else
        if entity.Transform then
            entity.Transform.Transform.RotationQuat = rotationQuat
        end
    end
end



function Hellpers:SetEntTranslate(entity, scale)
    if Ext.IsServer == true then
        if entity.Transform then
            entity.Transform.Transform.Scale = scale
        end

    else
        if entity.Transform then
            entity.Transform.Transform.Scale = scale
        end
    end
end


