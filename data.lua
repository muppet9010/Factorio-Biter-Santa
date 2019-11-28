local Constants = require("constants")

local santaLanded = {
    type = "container",
    name = "biter_santa_landed",
    picture = {
        filename = Constants.GraphicsModName .. "/graphics/entity/biter santa wagon - giant spitter.png",
        height = "266",
        width = "954",
        scale = 0.5,
        shift = {0.1, -0.75},
        priority = "extra-high"
    },
    flags = {"not-rotatable", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-flammable"},
    render_layer = "object",
    collision_box = {{-7, -1.5}, {7, 1.5}},
    collision_mask = {"object-layer", "player-layer"},
    selection_box = {{-7, -1}, {7, 1}},
    selectable_in_game = false,
    map_color = {r = 1, g = 0, b = 0, a = 1},
    inventory_size = 100,
    max_health = 12345
}
if settings.startup["santa-has-inventory"].value == true then
    santaLanded.selectable_in_game = true
end

local santaFlying = table.deepcopy(santaLanded)
santaFlying.type = "simple-entity"
santaFlying.name = "biter_santa_flying"
santaFlying.collision_mask = {}
santaFlying.selectable_in_game = false

local santaFlyingSprite = {
    type = "sprite",
    name = "biter_santa_flying",
    filename = santaLanded.picture.filename,
    height = santaLanded.picture.height,
    width = santaLanded.picture.width,
    scale = santaLanded.picture.scale,
    shift = santaLanded.picture.shift,
    priority = santaLanded.picture.priority
}

local santaShadowSprite = {
    type = "sprite",
    name = "biter_santa_shadow",
    filename = Constants.GraphicsModName .. "/graphics/entity/biter santa wagon - giant spitter-shadow.png",
    height = "266",
    width = "954",
    scale = 0.5,
    shift = {0.1, -0.75},
    priority = "extra-high",
    draw_as_shadow = true,
    flags = {"shadow"}
}
data:extend({santaLanded, santaFlying, santaFlyingSprite, santaShadowSprite})

data:extend(
    {
        {
            type = "trivial-smoke",
            name = "santa_wheel_sparks",
            animation = {
                filename = "__base__/graphics/entity/sparks/sparks-01.png",
                width = 39,
                height = 34,
                frame_count = 12,
                line_length = 19,
                shift = {-0.109375, 0.3125},
                tint = {r = 1.0, g = 0.9, b = 0.0, a = 1.0},
                animation_speed = 0.5,
                flags = {"smoke"}
            },
            duration = 24,
            affected_by_wind = false,
            show_when_smoke_off = true,
            movement_slow_down_factor = 1,
            render_layer = "air-entity-info-icon"
        },
        {
            type = "trivial-smoke",
            name = "santa_biter_air_smoke",
            animation = {
                filename = Constants.GraphicsModName .. "/graphics/entity/small-smoke-white.png",
                width = 39,
                height = 32,
                x = 351,
                frame_count = 10,
                line_length = 19,
                shift = {0.078125, -0.15625},
                scale = 1,
                animation_speed = 0.5,
                flags = {"smoke"}
            },
            duration = 20,
            affected_by_wind = false,
            show_when_smoke_off = true,
            movement_slow_down_factor = 1,
            render_layer = "smoke"
        },
        {
            type = "trivial-smoke",
            name = "santa_biter_vto_flame",
            animation = {
                filename = "__base__/graphics/entity/rocket-silo/10-rocket-under/jet-flame.png",
                width = 88,
                height = 132,
                frame_count = 2,
                line_length = 8,
                animation_speed = 0.5,
                scale = 0.75
            },
            duration = 1,
            affected_by_wind = false,
            show_when_smoke_off = true,
            movement_slow_down_factor = 1,
            render_layer = "smoke"
        },
        {
            type = "trivial-smoke",
            name = "santa_biter_transition_smoke_massive",
            animation = {
                filename = Constants.GraphicsModName .. "/graphics/entity/large-smoke-white.png",
                width = 152,
                height = 120,
                line_length = 5,
                frame_count = 60,
                direction_count = 1,
                shift = {-2, -1},
                priority = "high",
                animation_speed = 0.25,
                flags = {"smoke"},
                scale = 10
            },
            duration = 400,
            fade_in_duration = 180,
            fade_away_duration = 60,
            affected_by_wind = false,
            show_when_smoke_off = true,
            movement_slow_down_factor = 1,
            render_layer = "air-entity-info-icon",
            cyclic = true
        }
    }
)
