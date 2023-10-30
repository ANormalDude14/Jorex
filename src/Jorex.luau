--[[
    @Interface JorexBaseType
    .JorexBase  string
--]]
type JorexBaseType = {
  ----------------------------------------
  JorexBaseId:string;    -- ID:
  Dispatch:(
    JorexBaseA: JorexBaseType
  ) -> nil?,
  NewJorexSignal : (
    JorexId: string
  ) -> (),
  SignalNetwork : {}        
  --------------------------------------
} local HostedJorexBaseTypes : {
    [string]: JorexBaseType
} = { 
    --//
};
--[[
    @class Jorex
--]]
local Jorex = { };
--[[ // JorexPreInstance //
    kinda lazy to write
    Instance.new() and seperately 
    define Its properties, this should help
--]]
function Jorex:JorexPreInstance(JorexInstanceId: string, JorexPropertyTable: {}): Instance | nil?
    local JorexInstance = Instance.new(JorexInstanceId, nil)
    for _Index, Properties in ipairs(JorexPropertyTable) do task.wait() 
        JorexInstance[Properties] = Properties or {};
    end
    return JorexInstance;
end
--[[
    @param JoraBaseDef JorexBaseType
--]]
function Jorex:define(UserJorexBase : JorexBaseType): JorexBaseType | nil
    if not (Jorex:JorexBaseFound(UserJorexBase.JorexBaseId)) then
        local JorexBase : JorexBaseType = UserJorexBase :: JorexBaseType
        if (JorexBase.SignalNetwork ~= nil) then
            local JorexFolder : Folder = Jorex:JorexPreInstance("Folder", {
                Parent = game:GetService("ReplicatedStorage"),
                Name   = JorexBase.JorexBaseId
            });
            function JorexBase.JorexSignal(JorexId: string, JorexData)
                local JorexSignal : RemoteEvent = Jorex:JorexPreInstance("RemoteEvent", 
                { Name = JorexId, Parent = JorexFolder });
                return {
                    FireJorexSignal = function(JorexData: any?) 
                       if (game:GetService("RunService"):IsClient()) then JorexSignal:FireClient(JorexData) end
                       JorexSignal:FireServer(JorexData);
                    end
                }
            end
        end
        HostedJorexBaseTypes[UserJorexBase.JorexBaseId] = JorexBase
        function JorexBase:Dispatch(): nil?
            HostedJorexBaseTypes[JorexBase.JorexBaseId] = nil;
        end
        return JorexBase;
    end
end
--[[

--]]
function Jorex:FetchSignal(JorexBase : JorexBaseType, JorexSignal: string, callback : () -> ()?): nil | ()->()
    if (JorexBase[JorexSignal] ~= nil) then
       return JorexBase[JorexSignal] 
    end
    return callback() or nil;
end
--[[

--]]
function Jorex:AddJorexScripts(Table: {ModuleScript}): nil
    local ScriptTable : {ModuleScript} = {}
    for Index, JorexScripts in ipairs(Table) do task.wait()
        if not (JorexScripts:IsA("ModuleScript") and typeof(require(JorexScripts)) == 'table') then error(
            `{script.Name} - Invalid set of table data`
        , 0) end
        table.insert(ScriptTable, JorexScripts)
    end
    return ScriptTable
end
--[[

--]]
function Jorex:InitializeJorexEngine(): nil 
   if (#Jorex:AddJorexScripts() == nil) then
       return warn(`{script.Name} - Attempt at loading nil table`, 1)
   end
   for _Index, ModuleScripts in ipairs(#Jorex:AddJorexScripts()) do
       if (ModuleScripts:IsA("ModuleScript") and typeof(require(ModuleScripts)) == 'table') then
           task.delay(1, function() 
               do
                  local JorexScript = require(ModuleScripts);
                  JorexScript:JorexStart();
               end
               warn(`Jorex has successfully loaded JorexScripts`)
          end)
        else return warn(`{script.Name} - Invalid set of table data`) end
   end
end
--[[

--]]
return table.freeze(Jorex);