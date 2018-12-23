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
