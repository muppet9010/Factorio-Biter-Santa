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
	local maxVTOHeightRiseRate = 0.05
	local altitudeChangeDistanceTiles = 80
	local flyingHeightTiles = 10
	local groundDamageHeight = 2.5
	local phaseInOutDistance = math.floor(20 / tickMoveSpeed) * tickMoveSpeed
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
	local idealSpawnTilesLeft = (math.floor((tonumber(settings.global["santa-spawn-tiles-left"].value) - landingDistance) / tickMoveSpeed) * tickMoveSpeed) + landingDistance
	if debug then Logging.Log("idealSpawnTilesLeft: " .. idealSpawnTilesLeft) end
	local spawnPos = {
		x = landedPos.x - math.max(idealSpawnTilesLeft, (landingDistance + phaseInOutDistance)),
		y = landedPos.y
	}
	local disappearPos = {
		x = landedPos.x + tonumber(settings.global["santa-disappear-tiles-right"].value),
		y = landedPos.y
	}
	local phaseOutSmokeTriggerXPos = disappearPos.x - (240 * tickMoveSpeed)
	local surface = game.surfaces[1]
	local takeoffSettingRaw = settings.global["santa-takeoff-method"].value
	local takeoffMode, vtoUpPattern, vtoClimbPattern
	if takeoffSettingRaw == "rolling horizontal takeoff" then
		takeoffMode = "rolling"
	elseif takeoffSettingRaw == "vertical takeoff" then
		takeoffMode = "vto"
		local transitionHeight = math.max((flyingHeightTiles / 2), (groundDamageHeight + 1))
		local heightReached, currentRiseRate
		vtoUpPattern, heightReached, currentRiseRate = Santa.CalculateVTOUpPattern(transitionHeight, maxVTOHeightRiseRate)
		vtoClimbPattern = Santa.CalculateVTOClimbPattern(heightReached, flyingHeightTiles, tickMoveSpeed, currentRiseRate)
	end

    MOD.SantaGroup = {
		nextStateTick = nil,
		santaEntity = nil,
		santaEntityShadow = nil,
		surface = surface,
		state = SantaStates.pre_spawning,
		currentPos = spawnPos,
		spawnPos = spawnPos,
		landingStartPos = landingStartPos,
		landedPos = landedPos,
		takeOffEndPos = takeOffEndPos,
		disappearPos = disappearPos,
		tickMoveSpeed = tickMoveSpeed,
		altitudeChangeDistanceTiles = altitudeChangeDistanceTiles,
		flyingHeightTiles = flyingHeightTiles,
		groundDamageHeight = groundDamageHeight,
		collisionBox = game.entity_prototypes["biter-santa-landed"].collision_box,
		descendSpeedReducton = descendSpeedReducton,
		descentPattern = descentPattern,
		groundSlowdownPattern = groundSlowdownPattern,
		stateIteration = 1,
		takeoffMode = takeoffMode,
		vtoUpPattern = vtoUpPattern,
		vtoClimbPattern = vtoClimbPattern,
		phaseOutSmokeTriggerXPos = phaseOutSmokeTriggerXPos
	}
	if debug then
		Logging.LogPrint("Santa Created")
		Logging.Log(Logging.TableContentsToString(MOD.SantaGroup, "MOD.SantaGroup"))
	end
end

function Santa.SpawnSantaEntity(creationPos)
	local santaGroup = MOD.SantaGroup
	local entityName
	local height
	if santaGroup.state == SantaStates.spawning then
		entityName = "biter-santa-flying"
		height = santaGroup.flyingHeightTiles
	elseif santaGroup.state == SantaStates.landed then
		entityName = "biter-santa-landed"
		height = 0
	elseif santaGroup.state == SantaStates.taking_off_ground or santaGroup.state == SantaStates.vto_up then
		entityName = "biter-santa-flying"
		height = 0
	else
		return
	end
	Santa.RemoveSantaEntity()
	santaGroup.santaEntity = santaGroup.surface.create_entity{name = entityName, position = creationPos, direction = defines.direction.east, force = "neutral"}
	santaGroup.santaEntity.destructible = false
	Santa.CreateSantaEntityShadow(height)
end

function Santa.CreateSantaEntityShadow(height)
	local santaGroup = MOD.SantaGroup
	santaGroup.santaEntityShadow = santaGroup.surface.create_entity{name = "biter-santa-shadow", position = Santa.CalculateShadowSantaPosition(height), direction = defines.direction.east, force = "neutral"}
	santaGroup.santaEntityShadow.destructible = false
end

function Santa.CalculateShadowSantaPosition(height)
	local santaGroup = MOD.SantaGroup
	local heightMod = height / 100
	local shadowPos = {
		x = santaGroup.currentPos.x + (60 * heightMod),
		y = santaGroup.currentPos.y + (48 * heightMod)
	}
	return shadowPos
end

function Santa.RemoveSantaEntity()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity ~= nil and santaGroup.santaEntity.valid then
		santaGroup.santaEntity.destroy()
	end
	if santaGroup.santaEntityShadow ~= nil and santaGroup.santaEntityShadow.valid then
		santaGroup.santaEntityShadow.destroy()
	end
end

function Santa.DismissSantaCommand(commandDetails)
	if commandDetails ~= nil then
		if MOD.SantaGroup == nil then
			game.players[commandDetails.player_index].print("Santa is not on the map!")
			return
		elseif MOD.SantaGroup.state ~= SantaStates.landed then
			game.players[commandDetails.player_index].print("Santa can only be dismissed when landed")
			return
		end
		game.players[commandDetails.player_index].print("Santa dismissed")
	end
	Santa.TakeOff()
end

function Santa.DeleteSantaCommand(commandDetails)
	if commandDetails ~= nil then
		game.players[commandDetails.player_index].print("Santa deleted")
	end
	Santa.DeleteSanta()
end

function Santa.DeleteSanta()
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
	if debug then Logging.Log("descentDistance: " .. descentDistance) end
	local stoppingDistance = 0
	for k, speed in pairs(groundSlowdownPattern) do
		stoppingDistance = stoppingDistance + speed
	end
	if debug then Logging.Log("stoppingDistance: " .. stoppingDistance) end
	local landingDistance = descentDistance + stoppingDistance
	if debug then Logging.Log("landingDistance: " .. landingDistance) end
	return landingDistance
end

function Santa.IsSantaEntityValid()
	local santaGroup = MOD.SantaGroup
	if santaGroup.santaEntity == nil or not santaGroup.santaEntity.valid then
		return false
	elseif santaGroup.santaEntityShadow == nil or not santaGroup.santaEntityShadow.valid then
		return false
	end
	return true
end

function Santa.NotValidEntityOccured()
	game.print("Critical Error - Santa Entity Invalid")
	Santa.DeleteSantaCommand()
end

function Santa.CreateWheelSparks(santaEntityPosition)
	local santaGroup = MOD.SantaGroup
	local wheelGroundSpots = {
		{
			x = santaEntityPosition.x - 0.9,
			y = santaEntityPosition.y + 0.9
		},
		{
			x = santaEntityPosition.x - 2,
			y = santaEntityPosition.y + 0.9
		},
		{
			x = santaEntityPosition.x - 5,
			y = santaEntityPosition.y + 0.9
		},
		{
			x = santaEntityPosition.x - 6.1,
			y = santaEntityPosition.y + 0.9
		}
	}
	for k, pos in pairs(wheelGroundSpots) do
		santaGroup.surface.create_trivial_smoke{name = "santa-wheel-sparks", position = pos}
	end
end

function Santa.CreateFlyingBiterSmoke(santaEntityPosition)
	local santaGroup = MOD.SantaGroup
	local topBiterRowYPos = santaEntityPosition.y + 0.2
	local bottomBiterRowYPos = santaEntityPosition.y + 0.9
	local biterSmokeSpotsXPos = {
		santaEntityPosition.x + 6.5,
		santaEntityPosition.x + 5.7,
		santaEntityPosition.x + 4.7,
		santaEntityPosition.x + 3.9,
		santaEntityPosition.x + 3,
		santaEntityPosition.x + 2.2,
		santaEntityPosition.x + 1.1,
		santaEntityPosition.x + 0.3,
	}
	for k, xPos in pairs(biterSmokeSpotsXPos) do
		santaGroup.surface.create_trivial_smoke{name = "santa-biter-air-smoke", position = {x = xPos, y = topBiterRowYPos}}
		santaGroup.surface.create_trivial_smoke{name = "santa-biter-air-smoke", position = {x = xPos, y = bottomBiterRowYPos}}
	end

	local topWheelRowYPos = santaEntityPosition.y + 0
	local bottomWheelRowYPos = santaEntityPosition.y + 1.1
	local wheelSmokeSpotsXPos = {
		santaEntityPosition.x - 0.9,
		santaEntityPosition.x - 2,
		santaEntityPosition.x - 5,
		santaEntityPosition.x - 6.1
	}
	for k, xPos in pairs(wheelSmokeSpotsXPos) do
		santaGroup.surface.create_trivial_smoke{name = "santa-biter-air-smoke", position = {x = xPos, y = topWheelRowYPos}}
		santaGroup.surface.create_trivial_smoke{name = "santa-biter-air-smoke", position = {x = xPos, y = bottomWheelRowYPos}}
	end
end

function Santa.MoveSantaEntity(santaEntityPos, height)
	local santaGroup = MOD.SantaGroup
	if height == nil then height = 0 end
	santaGroup.santaEntity.teleport(santaEntityPos)
	if height > 0 then
		Santa.CreateFlyingBiterSmoke(santaEntityPos)
	end
	santaGroup.santaEntityShadow.teleport(Santa.CalculateShadowSantaPosition(height))
end

function Santa.TakeOff()
	local santaGroup = MOD.SantaGroup
	if santaGroup.takeoffMode == "rolling" then
		santaGroup.state = SantaStates.taking_off_ground
	elseif santaGroup.takeoffMode == "vto" then
		santaGroup.state = SantaStates.vto_up
	end
	Santa.SpawnSantaEntity(santaGroup.landedPos)
end

function Santa.CalculateVTOUpPattern(targetHeight, maxRiseRate)
	local vtoUpPattern = {}
	local currentRise = 0.001
	local riseIncrease = 1.1
	local currentHeight = 0
	while currentHeight < targetHeight do
		currentRise = math.min((currentRise * riseIncrease), maxRiseRate)
		currentHeight = (currentHeight + currentRise)
		table.insert(vtoUpPattern, currentHeight)
	end
	return vtoUpPattern, currentHeight, currentRise
end

function Santa.CalculateVTOClimbPattern(startHeight, targetHeight, maxSpeed, currentRiseRate)
	local vtoClimbPattern = {}
	local heightRiseSlowdown = 0.75
	local speedIncreaseRate = 1.02
	local minRiseRate = 0.015
	local currentHeight = startHeight
	local nearTargetHeight = targetHeight - 1
	local currentSpeed = 0.01
	while Utils.FuzzyCompareDoubles(currentHeight, "<", nearTargetHeight) do
		if Utils.FuzzyCompareDoubles(currentRiseRate, ">", minRiseRate) then
			currentRiseRate = math.max((currentRiseRate * heightRiseSlowdown), minRiseRate)
		end
		if Utils.FuzzyCompareDoubles(currentSpeed, "<=", maxSpeed) then
			currentSpeed = math.min((currentSpeed * speedIncreaseRate), maxSpeed)
		end
		currentHeight = currentHeight + currentRiseRate
		table.insert(vtoClimbPattern, {height = currentHeight, speed = currentSpeed})
	end
	while Utils.FuzzyCompareDoubles(currentHeight, "<", targetHeight) or Utils.FuzzyCompareDoubles(currentSpeed, "<", maxSpeed) do
		currentHeight = math.min((currentHeight + currentRiseRate), targetHeight)
		currentSpeed = math.min((currentSpeed * speedIncreaseRate), maxSpeed)
		table.insert(vtoClimbPattern, {height = currentHeight, speed = currentSpeed})
	end
	return vtoClimbPattern
end

function Santa.CreateVTOFlames(santaEntityPosition)
	local santaGroup = MOD.SantaGroup
	local flamePos1 = {
		x = santaEntityPosition.x - 1.5,
		y = santaEntityPosition.y + 2.1
	}
	santaGroup.surface.create_trivial_smoke{name = "santa-biter-vto-flame", position = flamePos1}
	local flamePos2 = {
		x = santaEntityPosition.x - 5.6,
		y = santaEntityPosition.y + 2.1
	}
	santaGroup.surface.create_trivial_smoke{name = "santa-biter-vto-flame", position = flamePos2}
end

function Santa.GeneratePhaseInOutSmokeTickIteration(santaGroupPosition)
	local santaGroup = MOD.SantaGroup
	if santaGroup.stateIteration <= 60 then
		if santaGroup.stateIteration % 6 == 0 then
			santaGroup.nextStateTick = game.tick + 180
			local smokePos = {
				x = santaGroupPosition.x,
				y = santaGroupPosition.y - santaGroup.flyingHeightTiles
			}
			Santa.CreatePhaseInOutSmoke(smokePos)
		end
		santaGroup.stateIteration = santaGroup.stateIteration + 1
	end
end

function Santa.CreatePhaseInOutSmoke(santaEntityPosition)
	local santaGroup = MOD.SantaGroup
	santaGroup.surface.create_trivial_smoke{ name = "santa-biter-transition-smoke-massive", position = {x = santaEntityPosition.x, y = santaEntityPosition.y}}
end

return Santa
