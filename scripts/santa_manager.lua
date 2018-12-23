local SantaManager = {}
local Santa = require("scripts/santa")
local SantaStates = require("scripts/santa_state")
local Logging = require("scripts/logging")
local Colors = require("scripts/color")
local Utils = require("scripts/utils")
local debug = false

function SantaManager.OnTick()
	local santaGroup = MOD.SantaGroup
	if santaGroup == nil then return end
	if debug then Logging.Log("SantaManager.OnTick() state: " .. santaGroup.state) end

	if santaGroup.state == SantaStates.spawning then SantaManager.Spawning()
	elseif santaGroup.state == SantaStates.arriving then SantaManager.Arriving()
	elseif santaGroup.state == SantaStates.landing_air then SantaManager.LandingAir()
	elseif santaGroup.state == SantaStates.landing_ground then SantaManager.LandingGround()
	elseif santaGroup.state == SantaStates.landed then SantaManager.Landed()
	elseif santaGroup.state == SantaStates.vto then SantaManager.VTO()
	elseif santaGroup.state == SantaStates.taking_off_ground then SantaManager.TakingOffGround()
	elseif santaGroup.state == SantaStates.taking_off_air then SantaManager.TakingOffAir(0)
	elseif santaGroup.state == SantaStates.departing then SantaManager.Departing()
	elseif santaGroup.state == SantaStates.disappearing then SantaManager.Disappearing()
	end
end

function SantaManager.Spawning()
	--TODO make clouds around his appearence spot for him to ride out of
	local santaGroup = MOD.SantaGroup
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + santaGroup.tickMoveSpeed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y + santaGroup.flyingHeightTiles
	}
	Santa.SpawnSantaEntity(santaEntityPos)
	santaGroup.state = SantaStates.arriving
	local messageText = settings.global["santa-called-message"].value
	if messageText ~= nil and messageText ~= "" then
		game.print(messageText, Colors[settings.global["santa-message-color"].value])
	end
end

function SantaManager.Arriving()
	local santaGroup = MOD.SantaGroup
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + santaGroup.tickMoveSpeed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y - santaGroup.flyingHeightTiles
	}
	santaGroup.santaEntity.teleport(santaEntityPos)
	if santaGroup.currentPos.x >= santaGroup.landingStartPos.x then
		santaGroup.state = SantaStates.landing_air
	end
end

function SantaManager.LandingAir()
	local santaGroup = MOD.SantaGroup
	local touchdownDistanceTiles = santaGroup.altitudeChangeDistanceTiles / 2
	local touchdownPosX = santaGroup.landedPos.x - touchdownDistanceTiles
	local distanceToTouchdown = touchdownPosX - santaGroup.currentPos.x
	local height = (santaGroup.flyingHeightTiles / touchdownDistanceTiles) * distanceToTouchdown
	local speed = (santaGroup.tickMoveSpeed / santaGroup.altitudeChangeDistanceTiles) * distanceToTouchdown
	speed = math.max(speed, (santaGroup.tickMoveSpeed*0.75))
	height = math.max(height, 0)

	if debug then Logging.Log("distanceToTouchdown: " .. distanceToTouchdown .. " - height: " .. height .. " - speed: " .. speed) end
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + speed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y - height
	}
	santaGroup.santaEntity.teleport(santaEntityPos)
	if height < 3 then
		Utils.KillEverythingInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox))
	end
	if height == 0 then
		santaGroup.state = SantaStates.landing_ground
	end
end

function SantaManager.LandingGround()
	local santaGroup = MOD.SantaGroup
	local distanceToStoped = santaGroup.landedPos.x - santaGroup.currentPos.x
	local speed = (santaGroup.tickMoveSpeed / santaGroup.altitudeChangeDistanceTiles) * distanceToStoped
	speed = math.max(speed, 0.03)
	if distanceToStoped < speed then
		speed = distanceToStoped
	end

	if debug then Logging.Log("distanceToStoped: " .. distanceToStoped .. " - speed: " .. speed) end
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + speed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = santaGroup.currentPos
	santaGroup.santaEntity.teleport(santaEntityPos)
	Utils.KillEverythingInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox))
	if santaGroup.currentPos.x == santaGroup.landedPos.x then
		santaGroup.state = SantaStates.landed
		Santa.SpawnSantaEntity(santaGroup.landedPos)
		local messageText = settings.global["santa-arrived-message"].value
		if messageText ~= nil and messageText ~= "" then
			game.print(messageText, Colors[settings.global["santa-message-color"].value])
		end
	end
end

function SantaManager.Landed()
end

function SantaManager.VTO()
end

function SantaManager.TakingOffGround()
end

function SantaManager.TakingOffAir()
end

function SantaManager.Departing()
end

function SantaManager.Disappearing()
end

return SantaManager
