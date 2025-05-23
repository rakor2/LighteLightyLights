-- Position update subscription _ai
local positionUpdateSubscription = nil
local updateTick = 0


-- Get camera position and target data _ai
-- function GetCameraData()
--     local camera = Ext.Entity.GetAllEntitiesWithComponent("Camera")

--     local cameraPos = camera.GameCameraBehavior.field_150
--     local targetPos = camera.GameCameraBehavior.TargetDestination
    
--     return {x = cameraPos[1], y = cameraPos[2], z = cameraPos[3]},
--            {x = targetPos[1], y = targetPos[2], z = targetPos[3]}
-- end

function GetCameraData()
    local cameras = Ext.Entity.GetAllEntitiesWithComponent("Camera")
    for _, cameraEntity in ipairs(cameras) do
        local cameraComp = cameraEntity:GetAllComponents()
        if cameraComp and cameraComp.Camera.Active == true and cameraComp.GameCameraBehavior then

                DPrint("USING GCB")
                
                local cameraPos = cameraComp.GameCameraBehavior.field_150
                local targetPos = cameraComp.GameCameraBehavior.TargetDestination
            return {x = cameraPos[1], y = cameraPos[2], z = cameraPos[3]},
                   {x = targetPos[1], y = targetPos[2], z = targetPos[3]}
        end
    end
end

function CameraLookAt()
    local cameras = Ext.Entity.GetAllEntitiesWithComponent("Camera")
    for _, cameraEntity in ipairs(cameras) do
        local cameraComp = cameraEntity:GetAllComponents().Camera 
        if cameraComp and cameraComp.Active == true then
            _D(cameraEntity.Camera.Controller.LookAt)
            _D(cameraEntity.Transform)
        end
    end
end

function CameraPos()
    local cameras = Ext.Entity.GetAllEntitiesWithComponent("Camera")
    for _, cameraEntity in ipairs(cameras) do
        local cameraComp = cameraEntity:GetAllComponents().Camera 
        if cameraComp and cameraComp.Active == true then
            _D(cameraEntity.Transform)
        end
    end
end

Ext.RegisterConsoleCommand("cam", CameraLookAt)

function GetHostPositionClient()
    local pos = _C().Transform.Transform.Translate
    if pos and pos[1] and pos[2] and pos[3] then
        return {x = pos[1], y = pos[2], z = pos[3]}
    end
    return nil
end

-- Start position updates _ai
function StartPositionUpdates()
    if positionUpdateSubscription then return end
    
    positionUpdateSubscription = Ext.Events.Tick:Subscribe(function()
        updateTick = updateTick + 1
        if updateTick >= 2 then
            updateTick = 0
            local pos = GetHostPositionClient()
            if pos then
                SendClientPositionToServer(pos)
            end
        end
    end)
end

-- Stop position updates _ai
function StopPositionUpdates()
    if positionUpdateSubscription then
        Ext.Events.Tick:Unsubscribe(positionUpdateSubscription)
        positionUpdateSubscription = nil
    end
end


function FindTLPreviewDummyPlayer()
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

function FindTLPreviewDummyCompanion()
    timelineActorDataEntities = Ext.Entity.GetAllEntitiesWithComponent("TimelineActorData")
    DDump(timelineActorDataEntities)
    for i = 1, #timelineActorDataEntities do
        DDump(i)
        if timelineActorDataEntities[i].TLPreviewDummy and timelineActorDataEntities[i].TLPreviewDummy.Name ~= "DUM_" then
            local dummyName = timelineActorDataEntities[i].TLPreviewDummy.Name
            DDump(dummyName)
                playerDummyEntity = timelineActorDataEntities[i]
                DDump(playerDummyEntity)
        end
    end
end

Ext.RegisterConsoleCommand("tlc", FindTLPreviewDummyCompanion)

function GetPlayerDummyPosition()
    local ent = FindTLPreviewDummyPlayer()
    if not ent then return end
    local dummyPos = ent.Transform.Transform.Translate
    x = dummyPos[1]
    y = dummyPos[2]
    z = dummyPos[3]
    -- DPrint("[C][LLL] Player dummy found:", ent.TLPreviewDummy.Name, "at postition:", x, y, z)
    return {x = dummyPos[1], y = dummyPos[2], z = dummyPos[3]}
end

function StartCutscenePositionUpdates()
    if positionUpdateSubscription then return end
    positionUpdateSubscription = Ext.Events.Tick:Subscribe(function()
        updateTick = updateTick + 1
        if updateTick >= 2 then 
            updateTick = 0
            local pos = GetPlayerDummyPosition()
            SendCutscenePositionToServer(pos)
        end
    end)
end


function StopCutscenePositionUpdates()
    if positionUpdateSubscription then
        Ext.Events.Tick:Unsubscribe(positionUpdateSubscription)
        positionUpdateSubscription = nil
    end
end


Ext.RegisterConsoleCommand("xd", FindTLPreviewDummyPlayer)
Ext.RegisterConsoleCommand("xd2", GetPlayerDummyPosition)

-- Send client position to server _ai
function SendClientPositionToServer(pos)
    Ext.Net.PostMessageToServer("UpdateClientPosition", Ext.Json.Stringify(pos))
end

function SendCutscenePositionToServer(pos)
    Ext.Net.PostMessageToServer("UpdateCutscenePosition", Ext.Json.Stringify(pos))
end
