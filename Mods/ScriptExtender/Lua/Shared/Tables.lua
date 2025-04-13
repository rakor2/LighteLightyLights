-- Store client-side spawned lights list _ai
ClientSpawnedLights = {}

-- Store server-side spawned lights list _ai
ServerSpawnedLights = {}

-- Store light UUIDs on server _ai
uuidServer = {}

-- Store light UUIDs on client _ai
uuidClient = {}

-- Store light entities _ai
entClient = {}

-- Store light VFX entities _ai
vfxEntClient = {}

-- Store VFX ready states _ai
vfxEntClientReady = {}

-- Add this to store color values for each light _ai
LightColorValues = {}

-- Add this to store intensity values for each light _ai
LightIntensityValues = {}

-- Add this to store radius values for each light _ai
LightRadiusValues = {}

-- Store saved positions for each light _ai
SavedLightPositions = {}

-- Store saved intensities for each light _ai
savedIntensities = {}

-- Global styles table _ai
Styles = {}


LightTemperatureValues = {}


VeRsIoNs = {
    ["1.1.5.10"] = "1.1.5_crab"
}

-- Hotkey settings storage _ai
HotkeySettings = {
    selectedKey = "None",
    selectedModifier = "None"
}


-- SDL key modifier values _ai
KeyModifiers = {
    SHIFT = 0x0001,
    CTRL = 0x0040,
    ALT = 0x0100
}

-- Keyboard keys table _ai
KeyboardKeys = {
    "None",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
    "NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9",
    "BACKSLASH", "SLASH", "MINUS", "EQUALS", "LBRACKET", "RBRACKET",
    "SEMICOLON", "APOSTROPHE", "PERIOD", "COMMA", "GRAVE"
}

-- Keyboard modifiers _ai
KeyboardModifiers = {
    "None",
    "Ctrl",
    "Alt",
    "Shift",
    "Ctrl+Alt",
    "Ctrl+Shift",
    "Alt+Shift",
    "Ctrl+Alt+Shift"
}

-- Light type options _ai
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

-- Initialize UsedLightSlots with empty tables for each type _ai
UsedLightSlots = {
    ["Directional_5"] = {},
    ["Directional_10"] = {},
    ["Directional_20"] = {},
    ["Directional_30"] = {},
    ["Directional_40"] = {},
    ["Directional_60"] = {},
    ["Directional_90"] = {},
    ["Directional_150"] = {},
    ["Directional_180"] = {},
    ["Point"] = {},
    ["Torch"] = {}
}

-- Store orbit state for each light _ai
currentAngle = {}
currentRadius = {}
currentHeight = {}

-- Store rotation offsets for each light _ai
lightRotation = {
    tilt = {},  -- rx offset
    yaw = {},   -- ry offset
    roll = {}   -- rz offset
}

-- Store last movement mode for each light _ai
lastMode = {} -- "orbit" or "default"

-- Favorites lists for ATM and LTN templates _ai
ATMFavoritesList = {}
LTNFavoritesList = {}

-- Storage for current values _ai
currentValues = {
    intensity = {},
    radius = {}
}

-- Origin point variables _ai
originPoint = {
    entity = nil,
    enabled = false,
    position = {x = 0, y = 0, z = 0}
}