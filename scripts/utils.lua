local Utils = {}
--local Logging = require("scripts/logging")

function Utils.KillEverythingInArea(surface, positionedBoundingBox, killerEntity)
    local entitiesFound = surface.find_entities(positionedBoundingBox)
    for k, entity in pairs(entitiesFound) do
        if entity.health ~= nil and entity.destructible then
            entity.die("neutral", killerEntity)
        end
    end
end

function Utils.ApplyBoundingBoxToPosition(centrePos, boundingBox)
    return {
        left_top = {
            x = centrePos.x + boundingBox.left_top.x,
            y = centrePos.y + boundingBox.left_top.y
        },
        right_bottom = {
            x = centrePos.x + boundingBox.right_bottom.x,
            y = centrePos.y + boundingBox.right_bottom.y
        }
    }
end

function Utils.LogisticEquation(index, height, steepness)
    return height / (1 + math.exp(steepness * (index - 0)))
end

function Utils.ExponentialDecayEquation(index, multiplyer, scale)
    return multiplyer * math.exp(-index * scale)
end

function Utils.RoundNumberToDecimalPlaces(num, numDecimalPlaces)
	local result
	if numDecimalPlaces and numDecimalPlaces > 0 then
		local mult = 10 ^ numDecimalPlaces
		result =  math.floor(num * mult + 0.5) / mult
	else
		result = math.floor(num + 0.5)
	end
	if result == "nan" then
		result = 0
	end
	return result
end

--This doesn't guarentee correct on some of the edge cases, but is as close as possible assuming that 1/256 is the variance for the same number (Bilka, Dev on Discord)
function Utils.FuzzyCompareDoubles(num1, logic, num2)
    local numDif = num1 - num2
    local variance = 1/256
    if logic == "=" then
        if numDif < variance and numDif > -variance then return true
        else return false end
    elseif logic == "!=" then
        if numDif < variance and numDif > -variance then return false
        else return true end
    elseif logic == ">" then
        if numDif > variance then return true
        else return false end
    elseif logic == ">=" then
        if numDif > -variance then return true
        else return false end
    elseif logic == "<" then
        if numDif < -variance then return true
        else return false end
    elseif logic == "<=" then
        if numDif < variance then return true
        else return false end
    end
end

return Utils
