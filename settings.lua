if mods["space-age"] then
	data:extend({
		{
			type = "bool-setting",
			name = "deepsea-on-gleba",
			setting_type = "startup",
			default_value = false,
			order = "deepsea-mechanic-a",
		},
		{
			type = "bool-setting",
			name = "deepsea-on-fulgora",
			setting_type = "startup",
			default_value = false,
			order = "deepsea-mechanic-b",
		},
	})
end
if not mods["depths_of_nauvis"] then
	data:extend({
		{
			type = "bool-setting",
			name = "deepsea-on-nauvis",
			setting_type = "startup",
			default_value = false,
			order = "deepsea-mechanic-c",
		},
	})
end
