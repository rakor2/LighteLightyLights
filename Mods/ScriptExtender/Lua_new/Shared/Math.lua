Color = {}

-- Orbit calculations _ai
Orbit = {}

-- Calculate initial radius from light to character _ai
function Orbit:CalculateInitialRadius(lightX, lightZ, charX, charZ)
    return math.sqrt((lightX - charX)^2 + (lightZ - charZ)^2)
end

-- -- Calculate orbit position around character _ai
-- function Orbit:CalculatePosition(charPos, angle, radius, height)
--     -- Convert angle to radians _ai
--     local rad = math.rad(angle)
    
--     DPrint("[Math] Orbit Calculation:") -- _ai
--     DPrint(string.format("  Input: angle=%.2f(%.2f rad), radius=%.2f, height=%.2f", angle, rad, radius, height)) -- _ai
    
--     -- Calculate new position _ai
--     local x = charPos.x + radius * math.cos(rad)
--     local y = charPos.y + height
--     local z = charPos.z + radius * math.sin(rad)
    
--     DPrint(string.format("  Result: x=%.2f, y=%.2f, z=%.2f", x, y, z)) -- _ai
--     return x, y, z
-- end

-- Calculate rotation angles to look at target position _ai
function Orbit:CalculateLookAtRotation(fromX, fromY, fromZ, toX, toY, toZ)
    -- Calculate direction vector _ai
    local dx = toX - fromX
    local dy = toY - fromY
    local dz = toZ - fromZ
    
    -- Calculate distance _ai
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    if distance == 0 then return 0, 0, 0 end
    
    -- Normalize direction vector _ai
    dx = dx / distance
    dy = dy / distance
    dz = dz / distance
    
    -- Calculate pitch (rx) - rotation around X axis _ai
    local pitch = math.deg(math.asin(-dy))
    
    -- Calculate yaw (ry) - rotation around Y axis _ai
    local yaw = math.deg(Ext.Math.Atan2(dx, dz))
    
    -- Roll (rz) remains unchanged as we only need to point at target _ai
    return pitch, yaw, 0
end

-- Vector calculations _ai
Vector = {}

-- Calculate direction vector from two points _ai
function Vector:CalculateDirection(cPos, tPos)
    return {
        x = tPos.x - cPos.x,
        y = tPos.y - cPos.y,
        z = tPos.z - cPos.z
    }
end

-- Normalize vector _ai
function Vector:Normalize(vector)
    local length = math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    if length == 0 then return {x = 0, y = 0, z = 0} end
    
    return {
        x = vector.x / length,
        y = vector.y / length,
        z = vector.z / length
    }
end

-- Calculate rotation angles from direction vector _ai
function Vector:DirectionToRotation(dirVector)
    local normalizedDir = Vector:Normalize(dirVector)
    
    -- Calculate pitch (around X axis) _ai
    local pitch = math.deg(math.asin(-normalizedDir.y))
    
    -- Calculate yaw (around Y axis) _ai
    local yaw = math.deg(Ext.Math.Atan2(normalizedDir.x, normalizedDir.z))
    
    return {
        pitch = pitch,
        yaw = yaw,
        roll = 0  -- We don't need roll for light direction _ai
    }
end

-- -- Calculate camera direction from camera position and target _ai
-- function Vector:CalculateCameraDirection(cameraPos, targetPos)
--     local direction = Vector:CalculateDirection(cameraPos, targetPos)
--     return Vector:Normalize(direction)
-- end

-- Calculate vector between camera and character _ai
function Vector:CalculateCameraCharacterVector(cameraPos, charPos)
    return {
        x = charPos.x - cameraPos.x,
        y = charPos.y - cameraPos.y,
        z = charPos.z - cameraPos.z
    }
end

-- Convert temperature to RGB _ai
function KelvinToRGB(kelvin)
    local temp = kelvin / 100
    local r, g, b
    
    if temp <= 66 then
        r = 255
        g = temp
        g = 99.4708025861 * math.log(g) - 161.1195681661
        
        if temp <= 19 then
            b = 0
        else
            b = temp - 10
            b = 138.5177312231 * math.log(b) - 305.0447927307
        end
    else
        r = temp - 60
        r = 329.698727446 * (r ^ -0.1332047592)
        g = temp - 60
        g = 288.1221695283 * (g ^ -0.0755148492)
        b = 255
    end
    
    -- Clamp values between 0 and 255 then normalize to 0-1 range _ai
    local function clamp(x, min, max)
        return math.min(math.max(x, min), max)
    end
    
    return {
        clamp(r, 0, 255) / 255,
        clamp(g, 0, 255) / 255,
        clamp(b, 0, 255) / 255,
        1.0
    }
end