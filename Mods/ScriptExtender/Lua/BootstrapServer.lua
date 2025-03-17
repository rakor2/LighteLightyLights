Ext.Require("Server/_init.lua")
Ext.Require("Shared/_init.lua")

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
    print("[S][LLL] LevelGameplayStarted")
    Ext.Net.BroadcastMessage("LevelStarted", "")
end)
