Ext.Require("Server/_init.lua")
Ext.Require("Shared/_init.lua")

clear = false

if clear == true then
    Ext.Timer.WaitFor(500, function ()
        Ext.Utils.Print("\27[2J\27[H\27[3J")    
    end)

end 


function CacheLTNServer()
    Ext.Net.BroadcastMessage("ManualCache", "")
end

Ext.RegisterConsoleCommand("cacheltn", CacheLTNServer)


Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
    Ext.Net.BroadcastMessage("LLL_LevelStarted","")
end)