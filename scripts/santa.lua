local Santa = {}
local SantaStates = require("scripts/santa_state")
local Logging = require("scripts/logging")
local Utils = require("scripts/utils")
local debug = false

function Santa.CallSantaCommand(commandDetails)
	if commandDetails ~= nil then
		if MOD.SantaGroup ~= nil then
			game.players[commandDetails.player_index].print("Santa is already on the map and there is only 1 of him!")
			return
		end
		game.players[commandDetails.player_index].print("Santa called")
	end

	Santa.CreateSantaGroup()
end

function Santa.CreateSantaGroup()
	local tickMoveSpeed = 0.4
	local descendSpeedReducton = 0.25
	local altitudeChangeDistanceTiles = 80
	local flyingHeightTiles = 10
	local landedPos = {
		x = tonumber(settings.global["santa-landed-spot-x"].value),
		y = tonumber(settings.global["santa-landed-spot-y"].value)
	}

	local groundSlowdownStartingSpeed = tickMoveSpeed - (tickMoveSpeed * descendSpeedReducton)
	local descentPattern = Santa.CalculateDescentPattern(tickMoveSpeed, groundSlowdownStartingSpeed, altitudeChangeDistanceTiles, flyingHeightTiles)
	local groundSlowdownPattern = Santa.CalculateGroundSlowdownPattern(groundSlowdownStartingSpeed)
	local landingDistance = Santa.CalculateLandingDistance(descentPattern, groundSlowdownPattern)

	local landingStartPos = {
		x = landedPos.x - landingDistance,
		y = landedPos.y
	}
	local takeOffEndPos = {
		x = landedPos.x + altitudeChangeDistanceTiles,
		y = landedPos.y
	}
	local spawnTilesLeft = math.floor(tonumber(settings.global["santa-spawn-tiles-left"].value) / tickMoveSpeed) * tickMoveSpeed
	local spawnPos = {
		x = landingStartPos.x - spawnTilesLeft,
		y = landingStartPos.y
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
		disappearPos = disappearPos,
		tickMoveSpeed = tickMoveSpeed,
		altitudeChangeDistanceTiles = altitudeChangeDistanceTiles,
		flyingHeightTiles = flyingHeightTiles,
		collisionBox = game.entity_prototypes["biter-santa-landed"].collision_box,
		descendSpeedReducton = descendSpeedReducton,
		descentPattern = descentPattern,
		groundSlowdownPattern = groundSlowdownPattern,
		stateIteration = 1
	}
    if debug then Logging.LogPrint("Santa Created: " .. Logging.TableContentsToString(MOD.SantaGroup, "MOD.SantaGroup")) end
end

function Santa.SpawnSantaEntity(creationPos)
	local santaGroup = MOD.SantaGroup
	--TODO needs to account for flyingHeightTiles
	local entityName
	if santaGroup.state == SantaStates.spawning then
		entityName = "biter-santa-flying"
	elseif santaGroup.state == SantaStates.landed then
		entityName = "biter-santa-landed"
	elseif santaGroup.state == SantaStates.taking_off then
		entityName = "biter-santa-flying"
	else
		return
	end
	Santa.RemoveSantaEntity()
	santaGroup.santaEntity = santaGroup.surface.create_entity{name = entityName, position = creationPos, direction = defines.direction.east, force = "neutral"}
	santaGroup.santaEntity.destructible = false
end

function Santa.RemoveSantaEntity()
	if MOD.SantaGroup.santaEntity == nil then return end
	if MOD.SantaGroup.santaEntity.valid then
		MOD.SantaGroup.santaEntity.destroy()
	end
end

function Santa.DismissSantaCommand(commandDetails)
	if commandDetails ~= nil then
		game.players[commandDetails.player_index].print("Santa dismissed")
	end
	--TODO
end

function Santa.DeleteSantaCommand(commandDetails)
	if commandDetails ~= nil then
		game.players[commandDetails.player_index].print("Santa deleted")
	end
	if MOD.SantaGroup == nil then return end
	Santa.RemoveSantaEntity()
	MOD.SantaGroup = nil
end

function Santa.CalculateDescentPattern(tickMoveSpeed, endingSpeed, altitudeChangeDistanceTiles, flyingHeightTiles)
	local averageSpeed = tickMoveSpeed - ((tickMoveSpeed - endingSpeed) / 2)
	local numberOfFrames = math.floor(altitudeChangeDistanceTiles / averageSpeed)

	local range = 30
	local jumpSize = range / (numberOfFrames + 1)
	local samplePoints = {}
	for i=1, (numberOfFrames + 1) do
		samplePoints[i] = (i * jumpSize) - (range/2)
	end

	local heightSpreader = 0.2
	local heightValue = flyingHeightTiles + heightSpreader
	local currentSpeed = tickMoveSpeed
	local speedDecrease = (tickMoveSpeed - endingSpeed) / numberOfFrames
	local steepness = 0.3
	local descentPattern = {}
	for i, sp in pairs(samplePoints) do
		currentSpeed = currentSpeed - speedDecrease
		local currentHeight = Utils.LogisticEquation(sp, heightValue, steepness) - 0.1
		if currentHeight < flyingHeightTiles and currentHeight > 0 then
			table.insert(descentPattern, {
				speed = currentSpeed,
				height = currentHeight
			})
		end
	end

	return descentPattern
end

function Santa.CalculateGroundSlowdownPattern(startingSpeed)
	local slowdownPattern = {}
	local slowdownPercentPerSecond = 0.75
	local slowdownPercentPerTick = slowdownPercentPerSecond / 60
	local currentSpeed = startingSpeed
	while currentSpeed > 0.01 do
		currentSpeed = currentSpeed - (currentSpeed * slowdownPercentPerTick)
		table.insert(slowdownPattern, currentSpeed)
	end
	return slowdownPattern
end

function Santa.CalculateLandingDistance(descentPattern, groundSlowdownPattern)
	local descentDistance = 0
	for k, data in pairs(descentPattern) do
		descentDistance = descentDistance + data.speed
	end
	if debug then Logging.LogPrint("descentDistance: " .. descentDistance) end
	local stoppingDistance = 0
	for k, speed in pairs(groundSlowdownPattern) do
		stoppingDistance = stoppingDistance + speed
	end
	if debug then Logging.LogPrint("stoppingDistance: " .. stoppingDistance) end
	local landingDistance = descentDistance + stoppingDistance
	if debug then Logging.LogPrint("landingDistance: " .. landingDistance) end
	return landingDistance
end

function Santa.NotValidEntityOccured()
	game.print("Critical Error - Santa Entity Invalid")
	Santa.DeleteSantaCommand()
end

return Santa
