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

return Utils
