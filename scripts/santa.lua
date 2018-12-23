local Santa = {}
local SantaStates = require("scripts/santa_state")
local Logging = require("scripts/logging")

local debug = false
local santaTickMoveSpeed = 0.4
local santaAltitudeChangeDistanceTiles = 60
local santaFlyingHeightTiles = 6

function Santa.CallSantaCommand(commandDetails)
	if MOD.SantaGroup ~= nil then
		game.players[commandDetails.player_index].print("Santa is already on the map and there is only 1 of him!")
		return
	end
	game.players[commandDetails.player_index].print("Santa called")

	Santa.CreateSantaGroup()
	Santa.SpawnSantaEntity()
end

function Santa.CreateSantaGroup()
	local landedPos = {
		x = tonumber(settings.global["santa-landed-spot-x"].value),
		y = tonumber(settings.global["santa-landed-spot-y"].value)
	}
	local landingStartPos = {
		x = landedPos.x - santaAltitudeChangeDistanceTiles,
		y = landedPos.y
	}
	local takeOffEndPos = {
		x = landedPos.x + santaAltitudeChangeDistanceTiles,
		y = landedPos.y
	}
	local spawnPos = {
		x = landedPos.x - tonumber(settings.global["santa-spawn-tiles-left"].value),
		y = landedPos.y
	}
	local disappearPos = {
		x = landedPos.x + tonumber(settings.global["santa-disappear-tiles-right"].value),
		y = landedPos.y
    }
	local surface = game.surfaces[1]

    MOD.SantaGroup = {
		santaEntity = nil,
		surface = surface,
		state = SantaStates.spawning,
		currentPos = spawnPos,
		spawnPos = spawnPos,
		landingStartPos = landingStartPos,
		landedPos = landedPos,
		takeOffEndPos = takeOffEndPos,
		disappearPos = disappearPos
    }
    if debug then Logging.Log("Santa Created") end
end

function Santa.SpawnSantaEntity()
	local santaGroup = MOD.SantaGroup
	--TODO needs to account for flyingHeightTiles
	local creationPos = nil
	local entityName = nil
	if santaGroup.state == SantaStates.spawning then
		creationPos = santaGroup.spawnPos
		entityName = "biter-santa-flying"
	elseif santaGroup.state == SantaStates.landed then
		creationPos = santaGroup.landedPos
		entityName = "biter-santa-landed"
	elseif santaGroup.state == SantaStates.taking_off then
		creationPos = santaGroup.landedPos
		entityName = "biter-santa-flying"
	else
		return
	end
	Santa.RemoveSantaEntity()
	santaGroup.santaEntity = santaGroup.surface.create_entity{name = entityName, position = creationPos, direction = defines.direction.east, force = game.forces["neutral"]}
	santaGroup.santaEntity.destructible = false
end

function Santa.RemoveSantaEntity()
	if MOD.SantaGroup.santaEntity == nil then return end
	if MOD.SantaGroup.santaEntity.valid then
		MOD.SantaGroup.santaEntity.destroy()
	end
end

function Santa.DismissSantaCommand(commandDetails)
	game.players[commandDetails.player_index].print("Santa dismissed")
	--TODO
end

function Santa.DeleteSantaCommand(commandDetails)
	game.players[commandDetails.player_index].print("Santa deleted")
	if MOD.SantaGroup == nil then return end
	Santa.RemoveSantaEntity()
	MOD.SantaGroup = nil
end

function Santa.Manage ()
	local santaGroup = MOD.SantaGroup
	if santaGroup == nil then return end
	if debug then Logging.Log("Santa.Manage state: " .. santaGroup.state) end

	if santaGroup.state == SantaStates.spawning then
		--TODO make clouds around his appearence spot for him to ride out of
		santaGroup.currentPos = {
			x = santaGroup.currentPos.x + santaTickMoveSpeed,
			y = santaGroup.currentPos.y
		}
		local santaEntityPos = {
			x = santaGroup.currentPos.x,
			y = santaGroup.currentPos.y + santaFlyingHeightTiles
		}
		santaGroup.santaEntity.teleport(santaEntityPos)
		santaGroup.state = SantaStates.arriving
	elseif santaGroup.state == SantaStates.arriving then
		santaGroup.currentPos = {
			x = santaGroup.currentPos.x + santaTickMoveSpeed,
			y = santaGroup.currentPos.y
		}
		local santaEntityPos = {
			x = santaGroup.currentPos.x,
			y = santaGroup.currentPos.y - santaFlyingHeightTiles
		}
		santaGroup.santaEntity.teleport(santaEntityPos)
		if santaGroup.currentPos.x >= santaGroup.landingStartPos.x then
			santaGroup.state = SantaStates.landing_air
		end
	elseif santaGroup.state == SantaStates.landing_air then
		local touchdownDistanceTiles = santaAltitudeChangeDistanceTiles / 2
		local touchdownPosX = santaGroup.landedPos.x - touchdownDistanceTiles
		local distanceToTouchdown = touchdownPosX - santaGroup.currentPos.x
		local height = (santaFlyingHeightTiles / touchdownDistanceTiles) * distanceToTouchdown
		local speed = (santaTickMoveSpeed / santaAltitudeChangeDistanceTiles) * distanceToTouchdown
		speed = math.max(speed, (santaTickMoveSpeed*0.75))
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
		if height == 0 then
			santaGroup.state = SantaStates.landing_ground
			Santa.SpawnSantaEntity()
		end
	elseif santaGroup.state == SantaStates.landing_ground then
		local distanceToStoped = santaGroup.landedPos.x - santaGroup.currentPos.x
		local speed = (santaTickMoveSpeed / santaAltitudeChangeDistanceTiles) * distanceToStoped
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
		if santaGroup.currentPos.x == santaGroup.landedPos.x then
			santaGroup.state = SantaStates.landed
			Santa.SpawnSantaEntity()
			game.print("Santa has arrived for all the good and bad little boys and girls!")
		end
	elseif santaGroup.state == SantaStates.landed then
		--do nothing
	elseif santaGroup.state == SantaStates.taking_off then
	elseif santaGroup.state == SantaStates.departing then
	elseif santaGroup.state == SantaStates.disappearing then
	end
end

return Santa
