local Santa = require("scripts/santa")
local SantaActivity = require("scripts/santa_activity")
local Events = require("utility/events")

local OnLoad = function()
    Santa.OnLoad()
    SantaActivity.OnLoad()
end

local OnStartup = function()
    OnLoad()
end

script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_configuration_changed(OnStartup)
Events.RegisterEvent(defines.events.on_tick)
