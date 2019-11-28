local SantaActivity = {}
local Santa = require("scripts/santa")
local SantaStates = require("scripts/santa_states")
local Logging = require("utility/logging")
local Constants = require("constants")
local Utils = require("utility/utils")
local Events = require("utility/events")
local debug = false

function SantaActivity.OnLoad()
    Events.RegisterHandler(defines.events.on_tick, "SantaActivity", SantaActivity.OnTick)
end

SantaActivity.OnTick = function()
    local santaGroup = global.SantaGroup
    if santaGroup == nil then
        return
    end
    Logging.Log("SantaActivity.OnTick() state: " .. santaGroup.state, debug)

    if santaGroup.state == SantaStates.pre_spawning then
        SantaActivity.PreSpawning()
    elseif santaGroup.state == SantaStates.spawning then
        SantaActivity.Spawning()
    elseif santaGroup.state == SantaStates.arriving then
        SantaActivity.Arriving()
    elseif santaGroup.state == SantaStates.landing_air or santaGroup.state == SantaStates.landing_air_near_ground then
        SantaActivity.LandingAir()
    elseif santaGroup.state == SantaStates.landing_ground then
        SantaActivity.LandingGround()
    elseif santaGroup.state == SantaStates.landed then
        SantaActivity.Landed()
    elseif santaGroup.state == SantaStates.vto_up or santaGroup.state == SantaStates.vto_up_near_ground then
        SantaActivity.VTOUp()
    elseif santaGroup.state == SantaStates.vto_climb then
        SantaActivity.VTOClimb()
    elseif santaGroup.state == SantaStates.taking_off_ground then
        SantaActivity.TakingOffGround()
    elseif santaGroup.state == SantaStates.taking_off_air or santaGroup.state == SantaStates.taking_off_air_near_ground then
        SantaActivity.TakingOffAir()
    elseif santaGroup.state == SantaStates.departing then
        SantaActivity.Departing()
    elseif santaGroup.state == SantaStates.disappearing then
        SantaActivity.Disappearing()
    end
end

SantaActivity.PreSpawning = function()
    local santaGroup = global.SantaGroup
    Santa.GeneratePhaseInOutSmokeTickIteration(santaGroup.spawnPos)
    if santaGroup.nextStateTick ~= nil and game.tick >= santaGroup.nextStateTick then
        santaGroup.state = SantaStates.spawning
        santaGroup.nextStateTick = nil
        santaGroup.stateIteration = 1
    end
end

SantaActivity.Spawning = function()
    local santaGroup = global.SantaGroup
    local santaEntityPos = {
        x = santaGroup.currentPos.x,
        y = santaGroup.currentPos.y - santaGroup.flyingHeightTiles
    }
    Santa.SpawnSantaEntity(santaEntityPos)
    santaGroup.state = SantaStates.arriving
    local messageText = settings.global["santa-called-message"].value
    if messageText ~= nil and messageText ~= "" then
        game.print(messageText, Constants.Colors[settings.global["santa-message-color"].value])
    end
end

SantaActivity.Arriving = function()
    local santaGroup = global.SantaGroup
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
    Logging.Log(santaGroup.currentPos.x .. " >= " .. santaGroup.landingStartPos.x, debug)
    if Utils.FuzzyCompareDoubles(santaGroup.currentPos.x, ">=", santaGroup.landingStartPos.x) then
        santaGroup.state = SantaStates.landing_air
    end
end

SantaActivity.LandingAir = function()
    local santaGroup = global.SantaGroup
    if not Santa.IsSantaEntityValid() then
        return Santa.NotValidEntityOccured()
    end
    local distanceToStopped = santaGroup.landedPos.x - santaGroup.currentPos.x
    local speed = santaGroup.descentPattern[santaGroup.stateIteration].speed
    local height = santaGroup.descentPattern[santaGroup.stateIteration].height
    santaGroup.stateIteration = santaGroup.stateIteration + 1

    Logging.Log("distanceToStopped: " .. distanceToStopped .. " - height: " .. height .. " - speed: " .. speed, debug)
    santaGroup.currentPos = {
        x = santaGroup.currentPos.x + speed,
        y = santaGroup.currentPos.y
    }
    local santaEntityPos = {
        x = santaGroup.currentPos.x,
        y = santaGroup.currentPos.y - height
    }
    Santa.MoveSantaEntity(santaEntityPos, height)
    if santaGroup.state == SantaStates.landing_air and height <= santaGroup.groundEntitySpriteHeight then
        santaGroup.state = SantaStates.landing_air_near_ground
        Santa.SpawnSantaEntity(santaEntityPos, height)
    end
    if height <= santaGroup.groundDamageHeight then
        Utils.KillAllKillableObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
    end
    if santaGroup.stateIteration > #santaGroup.descentPattern then
        santaGroup.state = SantaStates.landing_ground
        santaGroup.stateIteration = 1
    end
end

SantaActivity.LandingGround = function()
    local santaGroup = global.SantaGroup
    if not Santa.IsSantaEntityValid() then
        return Santa.NotValidEntityOccured()
    end
    local distanceToStopped = santaGroup.landedPos.x - santaGroup.currentPos.x
    local speed = santaGroup.groundSlowdownPattern[santaGroup.stateIteration]
    santaGroup.stateIteration = santaGroup.stateIteration + 1
    Logging.Log("distanceToStopped: " .. distanceToStopped .. " - speed: " .. speed, debug)
    santaGroup.currentPos = {
        x = santaGroup.currentPos.x + speed,
        y = santaGroup.currentPos.y
    }
    local santaEntityPos = santaGroup.currentPos
    Santa.MoveSantaEntity(santaEntityPos)
    Utils.KillAllKillableObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
    if speed > 0.05 then
        Santa.CreateWheelSparks(santaEntityPos)
    end
    if santaGroup.stateIteration > #santaGroup.groundSlowdownPattern then
        santaGroup.state = SantaStates.landed
        santaGroup.stateIteration = 1
        Santa.SpawnSantaEntity(santaGroup.landedPos)
        local messageText = settings.global["santa-arrived-message"].value
        if messageText ~= nil and messageText ~= "" then
            game.print(messageText, Constants.Colors[settings.global["santa-message-color"].value])
        end
    end
end

SantaActivity.Landed = function()
    local santaGroup = global.SantaGroup
    if not Santa.IsSantaEntityValid() then
        return Santa.NotValidEntityOccured()
    end
    santaGroup.phaseInSmokeIteration = 1
end

SantaActivity.VTOUp = function()
    local santaGroup = global.SantaGroup
    if not Santa.IsSantaEntityValid() then
        return Santa.NotValidEntityOccured()
    end
    local height = santaGroup.vtoUpPattern[santaGroup.stateIteration]
    santaGroup.stateIteration = santaGroup.stateIteration + 1
    Logging.Log("height: " .. height, debug)
    local santaEntityPos = {
        x = santaGroup.currentPos.x,
        y = santaGroup.currentPos.y - height
    }
    Santa.MoveSantaEntity(santaEntityPos, height)
    Santa.CreateVTOFlames(santaEntityPos)
    if santaGroup.state == SantaStates.vto_up_near_ground and height >= santaGroup.groundEntitySpriteHeight then
        santaGroup.state = SantaStates.vto_up
        Santa.SpawnSantaEntity(santaEntityPos, height)
    end
    if height <= santaGroup.groundDamageHeight then
        Utils.KillAllKillableObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
    end
    if santaGroup.stateIteration > #santaGroup.vtoUpPattern then
        santaGroup.state = SantaStates.vto_climb
        Santa.SpawnSantaEntity(santaEntityPos, height)
        santaGroup.stateIteration = 1
    end
end

SantaActivity.VTOClimb = function()
    local santaGroup = global.SantaGroup
    if not Santa.IsSantaEntityValid() then
        return Santa.NotValidEntityOccured()
    end
    local speed = santaGroup.vtoClimbPattern[santaGroup.stateIteration].speed
    local height = santaGroup.vtoClimbPattern[santaGroup.stateIteration].height
    santaGroup.stateIteration = santaGroup.stateIteration + 1

    Logging.Log("height: " .. height .. " - speed: " .. speed, debug)
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

SantaActivity.TakingOffGround = function()
    local santaGroup = global.SantaGroup
    if not Santa.IsSantaEntityValid() then
        return Santa.NotValidEntityOccured()
    end
    local speed = santaGroup.groundSlowdownPattern[santaGroup.stateIteration]
    santaGroup.stateIteration = santaGroup.stateIteration - 1
    Logging.Log("speed: " .. speed, debug)
    santaGroup.currentPos = {
        x = santaGroup.currentPos.x + speed,
        y = santaGroup.currentPos.y
    }
    local santaEntityPos = santaGroup.currentPos
    Santa.MoveSantaEntity(santaEntityPos)
    Utils.KillAllKillableObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
    if santaGroup.stateIteration == 0 then
        santaGroup.state = SantaStates.taking_off_air_near_ground
        santaGroup.stateIteration = #santaGroup.descentPattern
    end
end

SantaActivity.TakingOffAir = function()
    local santaGroup = global.SantaGroup
    if not Santa.IsSantaEntityValid() then
        return Santa.NotValidEntityOccured()
    end
    local speed = santaGroup.descentPattern[santaGroup.stateIteration].speed
    local height = santaGroup.descentPattern[santaGroup.stateIteration].height
    santaGroup.stateIteration = santaGroup.stateIteration - 1
    Logging.Log("height: " .. height .. " - speed: " .. speed, debug)
    santaGroup.currentPos = {
        x = santaGroup.currentPos.x + speed,
        y = santaGroup.currentPos.y
    }
    local santaEntityPos = {
        x = santaGroup.currentPos.x,
        y = santaGroup.currentPos.y - height
    }
    Santa.MoveSantaEntity(santaEntityPos, height)
    if santaGroup.state == SantaStates.taking_off_air_near_ground and height >= santaGroup.groundEntitySpriteHeight then
        santaGroup.state = SantaStates.taking_off_air
        Santa.SpawnSantaEntity(santaEntityPos, height)
    end
    if height <= santaGroup.groundDamageHeight then
        Utils.KillAllKillableObjectsInArea(santaGroup.surface, Utils.ApplyBoundingBoxToPosition(santaGroup.currentPos, santaGroup.collisionBox), santaGroup.santaEntity, true)
    end
    if santaGroup.phaseInSmokeIteration <= 60 and Utils.FuzzyCompareDoubles(santaGroup.currentPos.x, ">=", santaGroup.phaseOutSmokeTriggerXPos) then
        Santa.GeneratePhaseInOutSmokeTickIteration(santaGroup.disappearPos)
    end
    if santaGroup.stateIteration == 0 then
        santaGroup.state = SantaStates.departing
        santaGroup.stateIteration = 1
    end
end

SantaActivity.Departing = function()
    local santaGroup = global.SantaGroup
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
    if santaGroup.phaseInSmokeIteration <= 60 and Utils.FuzzyCompareDoubles(santaGroup.currentPos.x, ">=", santaGroup.phaseOutSmokeTriggerXPos) then
        Santa.GeneratePhaseInOutSmokeTickIteration(santaGroup.disappearPos)
    end
    Logging.Log(santaGroup.currentPos.x .. " >= " .. santaGroup.disappearPos.x, debug)
    if Utils.FuzzyCompareDoubles(santaGroup.currentPos.x, ">=", santaGroup.disappearPos.x) then
        santaGroup.state = SantaStates.disappearing
        santaGroup.stateIteration = 1
    end
end

SantaActivity.Disappearing = function()
    if not Santa.IsSantaEntityValid() then
        return Santa.NotValidEntityOccured()
    end
    Santa.DeleteSanta()
end

return SantaActivity
