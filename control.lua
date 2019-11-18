local Santa = require("scripts/santa")
local SantaManager = require("scripts/santa_manager")
local Events = require("utility/events")

local OnLoad = function()
    Santa.OnLoad()
    SantaManager.OnLoad()
end

local OnStartup = function()
    OnLoad()
end

script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_configuration_changed(OnStartup)
Events.RegisterEvent(defines.events.on_tick)
