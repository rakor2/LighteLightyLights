Ext.Require("Shared/_init.lua")
Ext.Require("Client/_init.lua")

Settings = {}

function Settings.Save()
    local settings = {
        key = HotkeySettings.selectedKey,
        modifier = HotkeySettings.selectedModifier,
        style = StyleSettings.selectedStyle
    }
    local json = Ext.Json.Stringify(settings)
    Ext.IO.SaveFile("LightyLights/settings.json", json)
end

function Settings.Load()
    local json = Ext.IO.LoadFile("LightyLights/settings.json")
    if json then
        local settings = Ext.Json.Parse(json)
        
        -- Update settings _ai
        HotkeySettings.selectedKey = settings.key or "None"
        HotkeySettings.selectedModifier = settings.modifier or "None"
        StyleSettings.selectedStyle = settings.style or 1
    end
end
Settings.Load()
print("LightyLights: Settings loaded")

-- Load favorites when mod initializes _ai
function LoadFavoritesFromFile()
    local exists = Ext.IO.LoadFile("LightyLights/AnL_Favorites.json")
    
    -- Initialize empty lists and arrays _ai
    ATMFavoritesList = {}
    LTNFavoritesList = {}
    ATMFavorites = {}
    LTNFavorites = {}
    
    if exists then
        -- print("[Client] Found favorites file")
        local success, favorites = pcall(function()
            return Ext.Json.Parse(exists)
        end)
        
        if success and favorites then
            -- print("[Client] Successfully parsed favorites file")
            
            -- Load lists _ai
            ATMFavoritesList = favorites.atm or {}
            LTNFavoritesList = favorites.ltn or {}
            
            -- Rebuild arrays _ai
            for _, fav in ipairs(ATMFavoritesList) do
                table.insert(ATMFavorites, fav.index)
            end
            
            for _, fav in ipairs(LTNFavoritesList) do
                table.insert(LTNFavorites, fav.index)
            end
            
            -- print("[Client] Loaded ATM favorites count:", #ATMFavoritesList)
            -- print("[Client] Loaded LTN favorites indices count:", #ATMFavorites)
            -- print("[Client] Loaded LTN favorites count:", #LTNFavoritesList)
            -- print("[Client] Loaded LTN favorites indices count:", #LTNFavorites)
        else
            -- print("[Client] Error parsing favorites file:", favorites)
        end
    else
        -- print("[Client] No favorites file found - using empty lists")
    end
end
LoadFavoritesFromFile()
print("LightyLights: AnL favorites loaded")

-- Ext.Events.SessionLoaded:Subscribe(function()
-- end)

-- return Settings

local savedValuesTable = {
    SunYaw = {},
    SunPitch = {},
    SunInt = {},
    MoonCastLight = {},
    MoonYaw = {},
    MoonPitch = {},
    MoonInt = {},
    MoonRadius = {},
    StarsState = {},
    StarsAmount = {},
    StarsInt = {},
    StarsSaturation1 = {},
    StarsSaturation2 = {},
    StarsShimmer = {},
    CascadeSpeed = {},
    LightSize = {}
}


local function CacheSavedValues()
    print("[C][LLL] CacheSavedValues")
    local json = Ext.Json.Stringify(savedValuesTable)
    Ext.IO.SaveFile("LightyLights/LTN_Cache.json", json)

end



function SaveValuesToTable()


        for i = 1, #ltn_templates do

            savedValuesTable.SunYaw[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.Yaw
            savedValuesTable.SunPitch[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.Pitch
            savedValuesTable.SunInt[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.SunIntensity
            savedValuesTable.MoonCastLight[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.CastLightEnabled
            savedValuesTable.MoonYaw[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Yaw
            savedValuesTable.MoonPitch[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Pitch
            savedValuesTable.MoonInt[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Intensity
            savedValuesTable.MoonRadius[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Moon.Radius
            savedValuesTable.StarsState[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsEnabled
            savedValuesTable.StarsAmount[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsAmount
            savedValuesTable.StarsInt[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsIntensity
            savedValuesTable.StarsSaturation1[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsSaturation[1]
            savedValuesTable.StarsSaturation2[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsSaturation[2]
            savedValuesTable.StarsShimmer[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.SkyLight.ProcStarsShimmer
            savedValuesTable.CascadeSpeed[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.CascadeSpeed
            savedValuesTable.LightSize[i] = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting.Sun.LightSize

        end

        CacheSavedValues()

end

Ext.RegisterNetListener("LevelStarted", function()
    print("[C][LLL] LevelGameplayStarted")
    if Ext.IO.LoadFile("LightyLights/LTN_Cache.json") == nil then
        print("[C][LLL] Saving values . . . ")
    SaveValuesToTable()
    end
end)