local deepwater_tiles = {
	-- pelagos
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

if mods["space-age"] then
	if settings.startup["deepsea-on-fulgora"].value then
		-- fulgora oil ocean
		deepwater_tiles["oil-ocean-deep"] = true
	end

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

-- =========================================================
-- Elevated rails
-- =========================================================

if mods["elevated-rails"] then
	local function ensure_collision_layers(mask_owner)
		if not mask_owner.collision_mask then
			mask_owner.collision_mask = { layers = {} }
		elseif not mask_owner.collision_mask.layers then
			mask_owner.collision_mask = { layers = mask_owner.collision_mask }
		end
		return mask_owner.collision_mask.layers
	end

	if mods["space-age"] then
		do
			local oil_ocean_deep = data.raw.tile["oil-ocean-deep"]
			if oil_ocean_deep then
				local layers = ensure_collision_layers(oil_ocean_deep)
				layers["rail_support"] = nil
			end
		end
	end
	for tile_name, _ in pairs(deepwater_tiles) do
		local tile = data.raw.tile[tile_name]
		if tile then
			local layers = ensure_collision_layers(tile)
			layers["rail_support"] = true
		end
	end

	local masks = data.raw["utility-constants"].default.default_collision_masks

	if masks["rail-support/allow_on_deep_oil_ocean"] then
		masks["rail-support/allow_on_deep_oil_ocean"].layers["rail_support"] = true
	end

	if masks["rail-ramp/allow_on_deep_oil_ocean"] then
		masks["rail-ramp/allow_on_deep_oil_ocean"].layers["rail_support"] = true
	end

	local function hide_technology_and_rewire(old_tech, new_tech)
		local old = data.raw.technology[old_tech]
		local new = data.raw.technology[new_tech]

		if not old or not new then
			return
		end

		for _, tech in pairs(data.raw.technology) do
			if tech.prerequisites then
				for i = #tech.prerequisites, 1, -1 do
					if tech.prerequisites[i] == old_tech then
						table.remove(tech.prerequisites, i)

						local exists = false
						for _, p in pairs(tech.prerequisites) do
							if p == new_tech then
								exists = true
								break
							end
						end

						if not exists then
							table.insert(tech.prerequisites, new_tech)
						end
					end
				end
			end
		end

		old.hidden = true
		old.enabled = false
	end

	hide_technology_and_rewire("rail-support-foundations", "elevated-rail")
end
