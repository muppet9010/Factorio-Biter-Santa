local Constants = require("constants")

local santaLanded = {
	type = "simple-entity",
	name = "biter-santa-landed",
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
	collision_box = {{-7, -1}, {7, 1}},
	collision_mask = {"object-layer", "player-layer"},
	selection_box = {{-7, -1}, {7, 1}},
	selectable_in_game = false,
	map_color = {r=1, g=0 ,b=0, a=1}
}
local santaFlying = table.deepcopy(santaLanded)
santaFlying.name = "biter-santa-flying"
santaFlying.render_layer = "air-object"
santaFlying.collision_mask = {}
data:extend({santaLanded, santaFlying})

data:extend({
	{
		type = "trivial-smoke",
		name = "santa-wheel-sparks",
		animation = {
			filename = "__base__/graphics/entity/sparks/sparks-01.png",
			width = 39,
			height = 34,
			frame_count = 12,
			line_length = 19,
			shift = {-0.109375, 0.3125},
			tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
			animation_speed = 0.5
		},
		duration = 24,
		affected_by_wind = false,
		show_when_smoke_off = true,
		render_layer = "air-entity-info-icon"
	},
	{
		type = "trivial-smoke",
		name = "santa-biter-air-smoke",
		animation = {
			filename = Constants.GraphicsModName .. "/graphics/entity/biter-air-smoke.png",
			width = 39,
			height = 32,
			x = 351,
			frame_count = 10,
			line_length = 19,
			shift = {0.078125, -0.15625},
			scale = 1,
			animation_speed = 0.5
		},
		duration = 20,
		affected_by_wind = false,
		show_when_smoke_off = true,
		render_layer = "smoke"
	}
})
