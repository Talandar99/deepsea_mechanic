local deepwater_tiles = {
	-- gleba
	["pelagos-deepsea"] = true,
}

local blocked_fill_items = {
	"landfill",
	"sandfill",
	"rail-foundation",
	"planetaris-sandstone-foundation",
	"planetaris-high-support-electric-pole",
}
if mods["depths_of_nauvis"] then
	if settings.startup["depthsofnauvis-deep-sea-mechanic"].value then
		deepwater_tiles["deepwater"] = true
	end
else
	if settings.startup["deepsea-on-nauvis"].value then
		deepwater_tiles["deepwater"] = true
	end
end
if settings.startup["deepsea-on-gleba"].value then
	deepwater_tiles["gleba-deep-lake"] = true
end
local function remove_tile_conditions(item_name, blocked_tiles)
	local item = data.raw.item[item_name]
	if not (item and item.place_as_tile and item.place_as_tile.tile_condition) then
		return
	end

	local conditions = item.place_as_tile.tile_condition
	for i = #conditions, 1, -1 do
		if blocked_tiles[conditions[i]] then
			table.remove(conditions, i)
		end
	end
end

for _, item_name in pairs(blocked_fill_items) do
	remove_tile_conditions(item_name, deepwater_tiles)
end
