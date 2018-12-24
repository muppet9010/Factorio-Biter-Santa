local Utils = {}
--local Logging = require("scripts/logging")

function Utils.KillEverythingInArea(surface, positionedBoundingBox)
    local entitiesFound = surface.find_entities(positionedBoundingBox)
    for k, entity in pairs(entitiesFound) do
        if entity.health ~= nil and entity.destructible then
            entity.damage(10000, "script", "impact")
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

return Utils
