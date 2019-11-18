local Santa = require("scripts/santa")
local SantaManager = require("scripts/santa_manager")

local RegisterCommands = function()
    commands.remove_command("call-santa")
    commands.add_command("call-santa", {"api-description.call-santa"}, Santa.CallSantaCommand)
    commands.remove_command("dismiss-santa")
    commands.add_command("dismiss-santa", {"api-description.dismiss-santa"}, Santa.DismissSantaCommand)
    commands.remove_command("delete-santa")
    commands.add_command("delete-santa", {"api-description.delete-santa"}, Santa.DeleteSantaCommand)
end

local OnStartup = function()
    RegisterCommands()
end

local OnLoad = function()
    RegisterCommands()
end

local OnTick = function()
    SantaManager.OnTick()
end

script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_tick, OnTick)
