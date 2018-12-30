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

local santaShadow = {
	type = "simple-entity",
	name = "biter-santa-shadow",
	picture = {
		filename = Constants.GraphicsModName .. "/graphics/entity/biter santa wagon - giant spitter-shadow.png",
		height = "266",
		width = "954",
		scale = 0.5,
		shift = {0.1, -0.75},
		priority = "extra-high",
		draw_as_shadow = true,
		flags = {"shadow"}
	},
	flags = {"not-rotatable", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-flammable", "not-on-map"},
	render_layer = "smoke",
	selectable_in_game = false,
	collision_mask = {}
}
data:extend({santaLanded, santaFlying, santaShadow})

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
		name = "santa-biter-air-smoke",
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
		name = "santa-biter-vto-flame",
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
		name = "santa-biter-transition-smoke-massive",
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
		cyclic = true,
	}
})
