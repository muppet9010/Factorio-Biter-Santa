data:extend({
	{
		name = "santa-landed-spot-x",
		type = "int-setting",
		default_value = 0,
		setting_type = "runtime-global",
		order = "1001"
	},
	{
		name = "santa-landed-spot-y",
		type = "int-setting",
		default_value = 0,
		setting_type = "runtime-global",
		order = "1002"
	},
	{
		name = "santa-spawn-tiles-left",
		type = "int-setting",
		default_value = 200,
		minimum_value = 150,
		setting_type = "runtime-global",
		order = "1003"
	},
	{
		name = "santa-disappear-tiles-right",
		type = "int-setting",
		default_value = 200,
		minimum_value = 150,
		setting_type = "runtime-global",
		order = "1004"
	},
	{
		name = "santa-takeoff-method",
		type = "string-setting",
		default_value = "rolling horizontal takeoff",
		allowed_values = {"rolling horizontal takeoff", "vertical takeoff"},
		setting_type = "runtime-global",
		order = "1005"
	},


	{
		name = "santa-called-message",
		type = "string-setting",
		default_value = "Jingle Jingle Jingle",
		setting_type = "runtime-global",
		order = "2001"
	},
	{
		name = "santa-arrived-message",
		type = "string-setting",
		default_value = "Santa has arrived for all the good and bad little boys and girls!",
		setting_type = "runtime-global",
		order = "2002"
	},
	{
		name = "santa-message-color",
		type = "string-setting",
		allowed_values = {"White", "Green", "Red", "Black"},
		default_value = "Green",
		setting_type = "runtime-global",
		order = "2003"
	}
})
