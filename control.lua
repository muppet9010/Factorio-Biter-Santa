local Santa = require("scripts/santa")
local SantaManager = require("scripts/santa_manager")
local Events = require("utility/events")

local RegisterCommands = function()
    commands.remove_command("call-santa")
    commands.add_command("call-santa", {"api-description.call-santa"}, Santa.CallSantaCommand)
    commands.remove_command("dismiss-santa")
    commands.add_command("dismiss-santa", {"api-description.dismiss-santa"}, Santa.DismissSantaCommand)
    commands.remove_command("delete-santa")
    commands.add_command("delete-santa", {"api-description.delete-santa"}, Santa.DeleteSantaCommand)
end

local OnLoad = function()
    RegisterCommands()
    SantaManager.OnLoad()
end

local OnStartup = function()
    OnLoad()
end

script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_configuration_changed(OnStartup)
Events.RegisterEvent(defines.events.on_tick)
