--[[
	MOD = {
		Log(text) - control.lua
		SantaGroup - santa.lua > Santa.CreateSanta()
	}
]]



local Santa = require("scripts/santa")



local RegisterCommands = function()
	commands.remove_command("call-santa")
	commands.add_command("call-santa", {"api-description.call-santa"}, Santa.CallSantaCommand)
	commands.remove_command("dismiss-santa")
	commands.add_command("dismiss-santa", {"api-description.dismiss-santa"}, Santa.DismissSantaCommand)
	commands.remove_command("delete-santa")
	commands.add_command("delete-santa", {"api-description.delete-santa"}, Santa.DeleteSantaCommand)
end

local CreateGlobals = function()
	if global.MOD == nil then global.MOD = {} end
end

local ReferenceGlobals = function()
	MOD = global.MOD
end

local OnStartup = function()
	CreateGlobals()
	ReferenceGlobals()
	RegisterCommands()
end

local OnLoad = function()
	ReferenceGlobals()
	RegisterCommands()
end

local OnTick = function()
	Santa.Manage()
end





script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_tick, OnTick)
