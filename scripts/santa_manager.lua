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

	if santaGroup.state == SantaStates.pre_spawning then SantaManager.PreSpawning()
	elseif santaGroup.state == SantaStates.spawning then SantaManager.Spawning()
	elseif santaGroup.state == SantaStates.arriving then SantaManager.Arriving()
	elseif santaGroup.state == SantaStates.landing_air then SantaManager.LandingAir()
	elseif santaGroup.state == SantaStates.landing_ground then SantaManager.LandingGround()
	elseif santaGroup.state == SantaStates.landed then SantaManager.Landed()
	elseif santaGroup.state == SantaStates.vto_up then SantaManager.VTOUp()
	elseif santaGroup.state == SantaStates.vto_climb then SantaManager.VTOClimb()
	elseif santaGroup.state == SantaStates.taking_off_ground then SantaManager.TakingOffGround()
	elseif santaGroup.state == SantaStates.taking_off_air then SantaManager.TakingOffAir(0)
	elseif santaGroup.state == SantaStates.departing then SantaManager.Departing()
	elseif santaGroup.state == SantaStates.disappearing then SantaManager.Disappearing()
	end
end

function SantaManager.PreSpawning()
	local santaGroup = MOD.SantaGroup
	Santa.GeneratePhaseInOutSmokeTickIteration(santaGroup.spawnPos)
	if santaGroup.nextStateTick ~= nil and game.tick >= santaGroup.nextStateTick then
		santaGroup.state = SantaStates.spawning
		santaGroup.nextStateTick = nil
		santaGroup.stateIteration = 1
	end
end

function SantaManager.Spawning()
	local santaGroup = MOD.SantaGroup
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y - santaGroup.flyingHeightTiles
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
	if not Santa.IsSantaEntityValid() then
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
	if debug then Logging.Log(santaGroup.currentPos.x .. " >= " .. santaGroup.landingStartPos.x) end
	if Utils.FuzzyCompareDoubles(santaGroup.currentPos.x, ">=", santaGroup.landingStartPos.x) then
		santaGroup.state = SantaStates.landing_air
	end
end

function SantaManager.LandingAir()
	local santaGroup = MOD.SantaGroup
	if not Santa.IsSantaEntityValid() then
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
	if height < santaGroup.groundDamageHeight then
		Utils.KillAllObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
	end
	if santaGroup.stateIteration > #santaGroup.descentPattern then
		santaGroup.state = SantaStates.landing_ground
		santaGroup.stateIteration = 1
	end
end

function SantaManager.LandingGround()
	local santaGroup = MOD.SantaGroup
	if not Santa.IsSantaEntityValid() then
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
	Utils.KillAllObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
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
	if not Santa.IsSantaEntityValid() then
		return Santa.NotValidEntityOccured()
	end
end

function SantaManager.VTOUp()
	local santaGroup = MOD.SantaGroup
	if not Santa.IsSantaEntityValid() then
		return Santa.NotValidEntityOccured()
	end
	local height = santaGroup.vtoUpPattern[santaGroup.stateIteration]
	santaGroup.stateIteration = santaGroup.stateIteration + 1
	if debug then Logging.Log("height: " .. height) end
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y - height
	}
	Santa.MoveSantaEntity(santaEntityPos, height)
	Santa.CreateVTOFlames(santaEntityPos)
	if height < santaGroup.groundDamageHeight then
		Utils.KillAllObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
	end
	if santaGroup.stateIteration > #santaGroup.vtoUpPattern then
		santaGroup.state = SantaStates.vto_climb
		santaGroup.stateIteration = 1
	end
end

function SantaManager.VTOClimb()
	local santaGroup = MOD.SantaGroup
	if not Santa.IsSantaEntityValid() then
		return Santa.NotValidEntityOccured()
	end
	local speed = santaGroup.vtoClimbPattern[santaGroup.stateIteration].speed
	local height = santaGroup.vtoClimbPattern[santaGroup.stateIteration].height
	santaGroup.stateIteration = santaGroup.stateIteration + 1

	if debug then Logging.Log("height: " .. height .. " - speed: " .. speed) end
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + speed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y - height
	}
	Santa.MoveSantaEntity(santaEntityPos, height)
	if height < (santaGroup.flyingHeightTiles * 0.75) then
		Santa.CreateVTOFlames(santaEntityPos)
	end
	if santaGroup.stateIteration > #santaGroup.vtoClimbPattern then
		santaGroup.state = SantaStates.departing
		santaGroup.stateIteration = 1
	end
end

function SantaManager.TakingOffGround()
	local santaGroup = MOD.SantaGroup
	if not Santa.IsSantaEntityValid() then
		return Santa.NotValidEntityOccured()
	end
	local speed = santaGroup.groundSlowdownPattern[santaGroup.stateIteration]
	santaGroup.stateIteration = santaGroup.stateIteration - 1
	if debug then Logging.Log("speed: " .. speed) end
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + speed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = santaGroup.currentPos
	Santa.MoveSantaEntity(santaEntityPos)
	Utils.KillAllObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
	if santaGroup.stateIteration == 0 then
		santaGroup.state = SantaStates.taking_off_air
		santaGroup.stateIteration = #santaGroup.descentPattern
	end
end

function SantaManager.TakingOffAir()
	local santaGroup = MOD.SantaGroup
	if not Santa.IsSantaEntityValid() then
		return Santa.NotValidEntityOccured()
	end
	local speed = santaGroup.descentPattern[santaGroup.stateIteration].speed
	local height = santaGroup.descentPattern[santaGroup.stateIteration].height
	santaGroup.stateIteration = santaGroup.stateIteration - 1

	if debug then Logging.Log("height: " .. height .. " - speed: " .. speed) end
	santaGroup.currentPos = {
		x = santaGroup.currentPos.x + speed,
		y = santaGroup.currentPos.y
	}
	local santaEntityPos = {
		x = santaGroup.currentPos.x,
		y = santaGroup.currentPos.y - height
	}
	Santa.MoveSantaEntity(santaEntityPos, height)
	if height < santaGroup.groundDamageHeight then
		Utils.KillAllObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
	end
	if santaGroup.stateIteration == 0 then
		santaGroup.state = SantaStates.departing
		santaGroup.stateIteration = 1
	end
end

function SantaManager.Departing()
	local santaGroup = MOD.SantaGroup
	if not Santa.IsSantaEntityValid() then
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
	if Utils.FuzzyCompareDoubles(santaGroup.currentPos.x, ">=", santaGroup.phaseOutSmokeTriggerXPos) then
		Santa.GeneratePhaseInOutSmokeTickIteration(santaGroup.disappearPos)
	end
	if debug then Logging.Log(santaGroup.currentPos.x .. " >= " .. santaGroup.disappearPos.x) end
	if Utils.FuzzyCompareDoubles(santaGroup.currentPos.x, ">=", santaGroup.disappearPos.x) then
		santaGroup.state = SantaStates.disappearing
		santaGroup.stateIteration = 1
	end
end

function SantaManager.Disappearing()
	if not Santa.IsSantaEntityValid() then
		return Santa.NotValidEntityOccured()
	end
	Santa.DeleteSanta()
end

return SantaManager
