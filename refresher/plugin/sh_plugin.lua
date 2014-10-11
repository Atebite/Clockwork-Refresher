local PLUGIN = PLUGIN;

PLUGIN:SetGlobalAlias("cwREFRESHER");
    
function RELOAD_NIL()end

function RELOAD_PLUGIN(plugin)
    Clockwork.plugin.buffer[plugin.folderName] = plugin;
	Clockwork.plugin.stored[plugin.name] = plugin;
end

if SERVER then

function PLUGIN:ReloadEntity(directory, entityname)       			
    local server_code = 'ENT = {Type = "anim", Folder = "'..directory..'/entities/entities/'..entityname..'"};';
    local client_code = server_code;
    
    if (file.Exists("gamemodes/"..directory.."/entities/entities/"..entityname.."/init.lua", "GAME")) then
        server_code = server_code .. "\n" .. file.Read( "gamemodes/"..directory.."/entities/entities/"..entityname.."/init.lua", "GAME" )
    end
    
    if (file.Exists("gamemodes/"..directory.."/entities/entities/"..entityname.."/cl_init.lua", "GAME")) then
        client_code = client_code .. "\n" .. file.Read( "gamemodes/"..directory.."/entities/entities/"..entityname.."/cl_init.lua", "GAME" )
    end;
    
    if (file.Exists("gamemodes/"..directory.."/entities/entities/"..entityname.."/shared.lua", "GAME")) then
        local shared_code = file.Read( "gamemodes/"..directory.."/entities/entities/"..entityname.."/shared.lua", "GAME" )
        server_code = server_code .. "\n" .. shared_code
        client_code = client_code .. "\n" .. shared_code
    end;
    
    server_code = string.Replace( server_code, "Clockwork.kernel:IncludePrefixed", "RELOAD_NIL" )
    server_code = string.Replace( server_code, "AddCSLuaFile", "RELOAD_NIL" )
    client_code = string.Replace( client_code, "Clockwork.kernel:IncludePrefixed", "RELOAD_NIL" )
    server_code = string.Replace( server_code, "include", "RELOAD_NIL" )
    client_code = string.Replace( client_code, "include", "RELOAD_NIL" )
    
    server_code = server_code .. "\n" .. 'scripted_ents.Register(ENT, "'..entityname..'"); ENT = nil;'
    client_code = client_code .. "\n" .. 'scripted_ents.Register(ENT, "'..entityname..'"); ENT = nil;'
    
    RunString(server_code)
    for k2,ply in pairs(player.GetAll()) do
        Clockwork.datastream:Start(ply, "ReloadLuaString",{client_code})
    end
end

function PLUGIN:ReloadEffect(directory, effectname)

end

function PLUGIN:ReloadWeapon(directory, weaponname)        			
    local server_code = 'SWEP = { Folder = "'..directory..'/entities/weapons/'..weaponname..'", Base = "weapon_base", Primary = {}, Secondary = {} };';
    local client_code = 'SWEP = { Folder = "'..directory..'/entities/weapons/'..weaponname..'", Base = "weapon_base", Primary = {}, Secondary = {} };';
    
    if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..weaponname.."/init.lua", "GAME")) then
        server_code = server_code .. "\n" .. file.Read( "gamemodes/"..directory.."/entities/weapons/"..weaponname.."/init.lua", "GAME" )
    end
    
    if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..weaponname.."/cl_init.lua", "GAME")) then
        client_code = client_code .. "\n" .. file.Read( "gamemodes/"..directory.."/entities/weapons/"..weaponname.."/cl_init.lua", "GAME" )
    end;
    
    if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..weaponname.."/shared.lua", "GAME")) then
        local shared_code = file.Read( "gamemodes/"..directory.."/entities/weapons/"..weaponname.."/shared.lua", "GAME" )
        server_code = server_code .. "\n" .. shared_code
        client_code = client_code .. "\n" .. shared_code
    end;
    
    server_code = string.Replace( server_code, "Clockwork.kernel:IncludePrefixed", "RELOAD_NIL" )
    server_code = string.Replace( server_code, "AddCSLuaFile", "RELOAD_NIL" )
    client_code = string.Replace( client_code, "Clockwork.kernel:IncludePrefixed", "RELOAD_NIL" )
    
    server_code = server_code .. "\n" .. 'weapons.Register(SWEP, "'..weaponname..'"); SWEP = nil;'
    client_code = client_code .. "\n" .. 'weapons.Register(SWEP, "'..weaponname..'"); SWEP = nil;'
    
    RunString(server_code)
    for k2,ply in pairs(player.GetAll()) do
        Clockwork.datastream:Start(ply, "ReloadLuaString",{client_code})
    end
end

function PLUGIN:ReloadExtra(path)
    local code = file.Read( path, "LUA" )
    code = string.Replace( code, "Clockwork.kernel:IncludePrefixed", "RELOAD_NIL" )
    code = string.Replace( code, "AddCSLuaFile", "RELOAD_NIL" )
    
    if string.find(path, "items") then
        code = string.Replace( code, "ITEM:Register();", "ITEM.wasRefreshed = true;ITEM:Register();")
    end
    
    if string.find(path, "sv_") then
        RunString(code)
    elseif string.find(path, "cl_") then
        for k2,ply in pairs(player.GetAll()) do
            Clockwork.datastream:Start(ply, "ReloadLuaString",{code})
        end
    else
        RunString(code)
        for k2,ply in pairs(player.GetAll()) do
            Clockwork.datastream:Start(ply, "ReloadLuaString",{code})
        end
    end
    
    if string.find(path, "items") then
        local itemsTable = Clockwork.item:GetAll();
    
        for k, v in pairs(itemsTable) do
            if (v.wasRefreshed) then
                if (v.baseItem and !Clockwork.item:Merge(v, v.baseItem)) then
                    itemsTable[k] = nil;
                end
            end
        end;

        for k, v in pairs(itemsTable) do
            if (v.wasRefreshed) then
                if (v.OnSetup) then v:OnSetup(); end;
                
                if (Clockwork.item:IsWeapon(v)) then
                    Clockwork.item.weapons[v.weaponClass] = v;
                end;
                
                Clockwork.plugin:Call("ClockworkItemInitialized", v);
                
                v.wasRefreshed = false;
            end
        end;
        for k2,ply in pairs(player.GetAll()) do
            Clockwork.datastream:Start(ply, "ReloadLuaString",{[[
            local itemsTable = Clockwork.item:GetAll();
    
            for k, v in pairs(itemsTable) do
                if (v.wasRefreshed) then
                    if (v.baseItem and !Clockwork.item:Merge(v, v.baseItem)) then
                        itemsTable[k] = nil;
                    end
                end
            end;

            for k, v in pairs(itemsTable) do
                if (v.wasRefreshed) then
                    if (v.OnSetup) then v:OnSetup(); end;
                    
                    if (Clockwork.item:IsWeapon(v)) then
                        Clockwork.item.weapons[v.weaponClass] = v;
                    end;
                    
                    Clockwork.plugin:Call("ClockworkItemInitialized", v);
                    
                    v.wasRefreshed = false;
                end
            end;
            ]]})
        end
    end
end

function PLUGIN:ReloadPlugin(directory, pluginname)
    local explodeDir = string.Explode("/", directory);
	local folderName = string.lower(explodeDir[#explodeDir - 1]);
    
    local oldPlugin = Clockwork.plugin:FindByID(pluginname)
    local server_code = 'local PLUGIN = Clockwork.plugin:New()'
    
    local client_code = server_code
    
    for k, v in pairs(cwFile.Find(directory.."/*.lua", "LUA", "namedesc")) do
        local code = file.Read( directory.."/"..v, "LUA" )
        code = string.Replace( code, "Clockwork.kernel:IncludePrefixed", "RELOAD_NIL" )
        code = string.Replace( code, "AddCSLuaFile", "RELOAD_NIL" )
        
        if string.find(v, "sv_") then
            server_code = server_code .. "\n" .. code
        elseif string.find(v, "cl_") then
            client_code = client_code .. "\n" .. code
        else
            server_code = server_code .. "\n" .. code
            client_code = client_code .. "\n" .. code
        end
    end
    
    server_code = server_code .. "\n" .. "RELOAD_PLUGIN(PLUGIN);PLUGIN = nil;"
    client_code = client_code .. "\n" .. "RELOAD_PLUGIN(PLUGIN);PLUGIN = nil;"
    
    RunString(server_code)
    for k2,ply in pairs(player.GetAll()) do
        Clockwork.datastream:Start(ply, "ReloadLuaString",{client_code})
    end
    
    local plugin = Clockwork.plugin:FindByID(pluginname)
    
    if plugin.Refreshed then
        plugin:Refreshed(oldPlugin)
    end
    
    if plugin.ClockworkAddSharedVars then
        plugin:ClockworkAddSharedVars(Clockwork.kernel:GetSharedVars():Global(true),Clockwork.kernel:GetSharedVars():Player(true))
    end
end

function PLUGIN:ReloadSchema()
    local oldSchema = Schema
    local server_code = 'Schema = Clockwork.plugin:New()'
    
    local client_code = server_code
    
    for k, v in pairs(cwFile.Find(Clockwork.kernel:GetSchemaFolder().."/schema/*.lua", "LUA", "namedesc")) do
        local code = file.Read( Clockwork.kernel:GetSchemaFolder().."/schema/"..v, "LUA" )
        code = string.Replace( code, "Clockwork.kernel:IncludePrefixed", "RELOAD_NIL" )
        code = string.Replace( code, "AddCSLuaFile", "RELOAD_NIL" )
        
        if string.find(v, "sv_") then
            server_code = server_code .. "\n" .. code
        elseif string.find(v, "cl_") then
            client_code = client_code .. "\n" .. code
        else
            server_code = server_code .. "\n" .. code
            client_code = client_code .. "\n" .. code
        end
    end
    
    server_code = server_code .. "\n" .. "RELOAD_PLUGIN(Schema);"
    client_code = client_code .. "\n" .. "RELOAD_PLUGIN(Schema);"
    
    RunString(server_code)
    for k2,ply in pairs(player.GetAll()) do
        Clockwork.datastream:Start(ply, "ReloadLuaString",{client_code})
    end
    
    if Schema.Refreshed then
        Schema:Refreshed(oldSchema)
    end
    
    if Schema.ClockworkAddSharedVars then
        Schema:ClockworkAddSharedVars(Clockwork.kernel:GetSharedVars():Global(true),Clockwork.kernel:GetSharedVars():Player(true))
    end
end

if system.IsWindows() then
    require("fsw")
end

local function stringFindAny(hay, needles)
    for _,v in pairs(needles) do
        if string.find(hay,v) then return true end
    end
    return false
end
function PLUGIN:FSWOnChanged(fullpath)
    local path = string.Replace(string.Replace(fullpath,FSWGetDirectory().."\\",""),"\\","/")
    
    if string.find(path,"gamemodes/clockwork/plugins") then
        local entitypos = string.find(path,"/entities/entities/");
        local weaponpos = string.find(path,"/entities/weapons/");
        if stringFindAny(path,{ "libraries", "directory", "system", "factions", "classes", "attributes", "items", "derma", "commands"}) then
            self:ReloadExtra(string.Replace(path,"gamemodes/",""))
        elseif entitypos then
            local split = string.Split( path, "/" ) 
            self:ReloadEntity(string.Replace(string.Left( path, entitypos-1 ),"gamemodes/",""), split[#split-1])
        elseif weaponpos then
            local split = string.Split( path, "/" ) 
            self:ReloadWeapon(string.Replace(string.Left( path, weaponpos-1 ),"gamemodes/",""), split[#split-1])
        else
            local split = string.Split( path, "/" )
            self:ReloadPlugin(string.Replace(string.Replace(path,"gamemodes/",""),"/"..split[#split],""), split[#split-2])
        end
    elseif string.find(path,"gamemodes/"..Clockwork.kernel:GetSchemaFolder().."/plugins") then
        local entitypos = string.find(path,"/entities/entities/");
        local weaponpos = string.find(path,"/entities/weapons/");
        if stringFindAny(path,{ "libraries", "directory", "system", "factions", "classes", "attributes", "items", "derma", "commands"}) then
            self:ReloadExtra(string.Replace(path,"gamemodes/",""))
        elseif entitypos then
            local split = string.Split( path, "/" ) 
            self:ReloadEntity(string.Replace(string.Left( path, entitypos-1 ),"gamemodes/",""), split[#split-1])
        elseif weaponpos then
            local split = string.Split( path, "/" ) 
            self:ReloadWeapon(string.Replace(string.Left( path, weaponpos-1 ),"gamemodes/",""), split[#split-1])
        else
            local split = string.Split( path, "/" )
            self:ReloadPlugin(string.Replace(string.Replace(path,"gamemodes/",""),"/"..split[#split],""), split[#split-2])
        end
    elseif string.find(path,"gamemodes/"..Clockwork.kernel:GetSchemaFolder()) then
        print(path)
        local entitypos = string.find(path,"/entities/entities/");
        local weaponpos = string.find(path,"/entities/weapons/");
        if stringFindAny(path,{ "libraries", "directory", "system", "factions", "classes", "attributes", "items", "derma", "commands"}) then
            self:ReloadExtra(string.Replace(path,"gamemodes/",""))
        elseif entitypos then
            local split = string.Split( path, "/" ) 
            self:ReloadEntity(string.Replace(string.Left( path, entitypos-1 ),"gamemodes/",""), split[#split-1])
        elseif weaponpos then
            local split = string.Split( path, "/" ) 
            self:ReloadWeapon(string.Replace(string.Left( path, weaponpos-1 ),"gamemodes/",""), split[#split-1])
        else
            self:ReloadSchema()
        end
    end
end

elseif CLIENT then

Clockwork.datastream:Hook("ReloadLuaString", function(data)
        RunString(data[1])
    end)
    
end