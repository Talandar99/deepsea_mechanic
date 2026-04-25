local deepwater_tiles = {
	["pelagos-deepsea"] = true,
}

local blocked_fill_items = {
	"landfill",
	"sandfill",
	"planetaris-sandstone-foundation",
}

local blocked_entities = {
	["planetaris-high-support-electric-pole"] = "electric-pole",
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

if mods["space-age"] then
	if settings.startup["deepsea-on-gleba"].value then
		deepwater_tiles["gleba-deep-lake"] = true
	end
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

if not data.raw["collision-layer"]["deepsea_mechanic"] then
	data:extend({
		{
			type = "collision-layer",
			name = "deepsea_mechanic",
		},
	})
end

local function ensure_layers(proto)
	if not proto.collision_mask then
		proto.collision_mask = { layers = {} }
	elseif not proto.collision_mask.layers then
		proto.collision_mask = { layers = proto.collision_mask }
	end
	return proto.collision_mask.layers
end

for tile_name in pairs(deepwater_tiles) do
	local tile = data.raw.tile[tile_name]
	if tile then
		ensure_layers(tile)["deepsea_mechanic"] = true
	end
end

for entity_name, entity_type in pairs(blocked_entities) do
	local proto = data.raw[entity_type] and data.raw[entity_type][entity_name]
	if proto then
		ensure_layers(proto)["deepsea_mechanic"] = true
	end
end

if mods["elevated-rails"] then
	data.raw["utility-constants"].default.default_collision_masks["rail-support"].layers["deepsea_mechanic"] = true
	data.raw["utility-constants"].default.default_collision_masks["rail-ramp"].layers["deepsea_mechanic"] = true
end
