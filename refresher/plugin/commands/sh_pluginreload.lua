local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PluginReload");
COMMAND.tip = "Reloads a plugin, yes!.";
COMMAND.text = "<string test>";
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(ply, arguments)
    local plugin = Clockwork.plugin:FindByID(arguments[1])
    
    if plugin then
        local directory = plugin:GetBaseDir()

        local files, entityFolders = cwFile.Find(directory.."/entities/entities/*", "LUA", "namedesc");
        
        for k, v in pairs(entityFolders) do
            if (v != ".." and v != ".") then    
                cwREFRESHER:ReloadEntity(directory, v)  
            end
        end
        
        local files, entityFolders = cwFile.Find(directory.."/entities/weapons/*", "LUA", "namedesc");
        
        for k, v in pairs(entityFolders) do
            if (v != ".." and v != ".") then  
                cwREFRESHER:ReloadWeapon(directory, v)  
            end
        end
        
        local reloadList = { "libraries", "directory", "system", "factions", "classes", "attributes", "items", "derma", "commands"}
        for _, reload in pairs(reloadList) do
            for k, v in pairs(cwFile.Find(directory.."/"..reload.."/*.lua", "LUA", "namedesc")) do
                cwREFRESHER:ReloadExtra(directory.."/"..reload.."/"..v)
            end;
        end
        
        cwREFRESHER:ReloadPlugin(directory, arguments[1])
    
        Clockwork.player:Notify(ply, arguments[1].." reloaded!");
    else
		Clockwork.player:Notify(ply, arguments[1].." is not a valid plugin!");
    end
end;

COMMAND:Register();