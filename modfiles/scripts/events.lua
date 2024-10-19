script.on_init(function()
    -- Disable annoying stuff for development
    local freeplay = remote.interfaces["freeplay"]
    if DEV_ACTIVE and freeplay then
        if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    end

    storage.zones = {}
    storage.zone_running_index = 1
    handlers.reload_settings()
end)

script.on_load(function()
    -- Recreate the necessary metatables
    for _, zone in pairs(storage.zones) do
        setmetatable(zone, Zone)
        setmetatable(zone.redraw_schedule, Schedule)
        for _, entity in pairs(zone.entity_map) do setmetatable(entity, Entity) end
    end
end)

script.on_configuration_changed(function(data)
    handlers.reload_settings()

    if data.mod_changes["assemblyanalyst"] then
        for zone_index, zone in pairs(storage.zones) do
            zone:destroy_render_objects()
            storage.zones[zone_index] = nil
        end
    end

    for _, zone in pairs(storage.zones) do
        zone:refresh_status_mapping()
    end

    gui.rebuild_all()
end)


script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting_type == "runtime-global" then
        handlers.reload_settings()
        gui.rebuild_all()
    end
end)


script.on_event(defines.events.on_player_selected_area, function(event)
    if event.item == "aa-zone-selector" then
        local player = game.get_player(event.player_index)
        handlers.area_selected(player, event.area, event.entities)
    end
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
    if event.item == "aa-zone-selector" then
        local player = game.get_player(event.player_index)
        handlers.area_alt_selected(player, event.area)
    end
end)


script.on_event(defines.events.on_surface_deleted, function(_)
    for zone_index, zone in pairs(storage.zones) do
        if not zone.surface.valid then storage.zones[zone_index] = nil end
    end
end)


script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    local player = game.get_player(event.player_index)

    local open_info_window = player.cursor_stack.valid_for_read
      and player.cursor_stack.name == "aa-zone-selector"

    if open_info_window then gui.show_info_window(player)
    else gui.hide_info_window(player) end
end)


local entity_built_filter = {
    {filter="crafting-machine"},
    {filter="type", type="lab"},
    {filter="type", type="mining-drill"},
    {filter="type", type="inserter"}
}

script.on_event(defines.events.on_built_entity, handlers.entity_built, entity_built_filter)
script.on_event(defines.events.on_robot_built_entity, handlers.entity_built, entity_built_filter)
script.on_event(defines.events.script_raised_built, handlers.entity_built, entity_built_filter)


script.on_event(defines.events.on_tick, handlers.on_tick)


commands.add_command("aa-clear-zones", {"command-help.aa_clear_zones"}, function()
    for zone_index, zone in pairs(storage.zones) do
        zone:destroy_render_objects()
        storage.zones[zone_index] = nil
    end
    gui.rebuild_all()
end)
