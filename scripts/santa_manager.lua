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
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
	local speed = santaGroup.tickMoveSpeed
	local height = santaGroup.flyingHeightTiles
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + speed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y - height
	}
	Santa.MoveSantaEntity(santaEntityPos, height)
	Santa.CreateFlyingBiterSmoke(santaEntityPos)
	if debug then Logging.Log(santaGroup.currentPos.x .. " >= " .. santaGroup.landingStartPos.x) end
	if Utils.FuzzyCompareDoubles(">=", santaGroup.currentPos.x, santaGroup.landingStartPos.x) then
		santaGroup.state = SantaStates.landing_air
	end
end

function SantaManager.LandingAir()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
	local distanceToStopped = santaGroup.landedPos.x - santaGroup.currentPos.x
	local speed = santaGroup.descentPattern[santaGroup.stateIteration].speed
	local height = santaGroup.descentPattern[santaGroup.stateIteration].height
	santaGroup.stateIteration = santaGroup.stateIteration + 1

	if debug then Logging.Log("distanceToStopped: " .. distanceToStopped .. " - height: " .. height .. " - speed: " .. speed) end
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + speed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y - height
	}
	Santa.MoveSantaEntity(santaEntityPos, height)
	if height < 2.5 then
		Utils.KillEverythingInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity)
	end
	if santaGroup.stateIteration > #santaGroup.descentPattern then
		santaGroup.state = SantaStates.landing_ground
		santaGroup.stateIteration = 1
	end
end

function SantaManager.LandingGround()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
	local distanceToStopped = santaGroup.landedPos.x - santaGroup.currentPos.x
	local speed = santaGroup.groundSlowdownPattern[santaGroup.stateIteration]
	santaGroup.stateIteration = santaGroup.stateIteration + 1
	if debug then Logging.Log("distanceToStopped: " .. distanceToStopped .. " - speed: " .. speed) end
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + speed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = santaGroup.currentPos
	Santa.MoveSantaEntity(santaEntityPos)
	Utils.KillEverythingInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity)
	if speed > 0.05 then
		Santa.CreateWheelSparks(santaEntityPos)
	end
	if santaGroup.stateIteration > #santaGroup.groundSlowdownPattern then
		santaGroup.state = SantaStates.landed
		santaGroup.stateIteration = 1
		Santa.SpawnSantaEntity(santaGroup.landedPos)
		local messageText = settings.global["santa-arrived-message"].value
		if messageText ~= nil and messageText ~= "" then
			game.print(messageText, Colors[settings.global["santa-message-color"].value])
		end
	end
end

function SantaManager.Landed()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
end

function SantaManager.VTO()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
end

function SantaManager.TakingOffGround()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
end

function SantaManager.TakingOffAir()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
end

function SantaManager.Departing()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
end

function SantaManager.Disappearing()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return Santa.NotValidEntityOccured()
	end
end

return SantaManager
