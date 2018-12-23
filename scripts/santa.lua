local Santa = {}
local SantaStates = require("scripts/santa_state")
local Logging = require("scripts/logging")
local debug = false

function Santa.CallSantaCommand(commandDetails)
	if MOD.SantaGroup ~= nil then
		game.players[commandDetails.player_index].print("Santa is already on the map and there is only 1 of him!")
		return
	end
	game.players[commandDetails.player_index].print("Santa called")

	Santa.CreateSantaGroup()
end

function Santa.CreateSantaGroup()
	local tickMoveSpeed = 0.4
	local altitudeChangeDistanceTiles = 60
	local flyingHeightTiles = 6
	local landedPos = {
		x = tonumber(settings.global["santa-landed-spot-x"].value),
		y = tonumber(settings.global["santa-landed-spot-y"].value)
	}
	local landingStartPos = {
		x = landedPos.x - altitudeChangeDistanceTiles,
		y = landedPos.y
	}
	local takeOffEndPos = {
		x = landedPos.x + altitudeChangeDistanceTiles,
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
		disappearPos = disappearPos,
		tickMoveSpeed = tickMoveSpeed,
		altitudeChangeDistanceTiles = altitudeChangeDistanceTiles,
		flyingHeightTiles = flyingHeightTiles,
		collisionBox = game.entity_prototypes["biter-santa-landed"].collision_box
    }
    if debug then Logging.Log("Santa Created") end
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
	game.players[commandDetails.player_index].print("Santa dismissed")
	--TODO
end

function Santa.DeleteSantaCommand(commandDetails)
	game.players[commandDetails.player_index].print("Santa deleted")
	if MOD.SantaGroup == nil then return end
	Santa.RemoveSantaEntity()
	MOD.SantaGroup = nil
end

return Santa
