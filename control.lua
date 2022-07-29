-- control.lua

-- require("utils")

-- script.on_event(defines.events.on_player_created,
--     function(event)
--         local player = game.get_player(event.player_index)

--         -- local outputData = {
--         --     bounding={3, 5},
--         --     tiles={
--         --         {pos={0, 0}, sides={"none", "none", "any", "red"}},
--         --         {pos={0, 1}, sides={"none", "none", "any", "red" }},
--         --         {pos={1, 0}, sides={"none", "none", "any", "none" }},
--         --         {pos={1, 1}, sides={"any", "none", "any", "none" }}
--         --     }
--         -- }
        
--         -- game.write_file("chunkdata.txt", serpent.block(outputData), false, 1)


--     end
-- )

-- control.lua

local Commands = require("script.commands")

for _, v in pairs(Commands.util:getCommands()) do
    commands.add_command(v, "some help text", Commands.util.command)
end

local prefab_data = require("prefabs.database")
global.prefab_data = prefab_data