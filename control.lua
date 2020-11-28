local Santa = require("scripts/santa")
local SantaActivity = require("scripts/santa_activity")

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
