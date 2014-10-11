local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("SchemaReload");
COMMAND.tip = "Reloads the schema.";
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(ply, arguments)
    local directory = Clockwork.kernel:GetSchemaFolder().."/schema"
    
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
    
    cwREFRESHER:ReloadSchema()

    Clockwork.player:Notify(ply, Clockwork.kernel:GetSchemaFolder().." reloaded!");
end;

COMMAND:Register();