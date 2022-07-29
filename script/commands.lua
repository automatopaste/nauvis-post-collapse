-- commands.lua

local Commands = {}
Commands.util = {}

-- editor commands

local active_data = {}
active_data.chunks = {}
active_data.name = ""
active_data.blueprint = ""

function Commands.mark(self)

    local playerCharacter = self.player.character

    local chunkData = {}
    -- chunkData.size = {1, 1}
    chunkData.sides = {self.parameters[1], self.parameters[2], self.parameters[3], self.parameters[4]}
    chunkData.pos = {math.floor(playerCharacter.position.x / 32), math.floor(playerCharacter.position.y / 32)}

    self.player.print("Marking chunk at "..tostring(chunkData.pos[1])..", "..tostring(chunkData.pos[2]))

    table.insert(active_data.chunks, chunkData)

    -- move all coords to be relative to top-left-most chunk
    local minx = 9999
    local miny = 9999
    for _, value in pairs(active_data.chunks) do
        if value.pos[1] < minx then minx = value.pos[1] end
        if value.pos[2] < miny then miny = value.pos[2] end
    end

    for _, value in pairs(active_data.chunks) do
        value.pos[1] = value.pos[1] - minx
        value.pos[2] = value.pos[2] - miny
    end

    self.player.print(serpent.line(active_data))
end

function Commands.set_bp_string(self)
    active_data.blueprint = self.parameters[1]
end

function Commands.output(self)
    local path = "chunk_data_output.txt"

    self.player.print("Outputting chunk data to "..path)

    active_data.name = self.parameters[1]

    game.write_file(path, serpent.line(active_data).."\n", true, self.player.index)
end

function Commands.cleardata(self)
    active_data = {}
    active_data.chunks = {}
    active_data.blueprint = ""

    self.player.print("Cleared active chunk data")
end

-- spawning commands

function Commands.spawn_prefab(self)
    local prefab_name = self.parameters[1]
    local prefabs = global.prefab_data

    local direction = defines.direction.north

    local prototypes = game.entity_prototypes

    for _, v in pairs(prefabs) do
        if v.name == prefab_name then
            local stack = self.player.cursor_stack

            stack.clear()
            stack.import_stack(v.blueprint)

            local min = {x=999, y=999}
            local max = {x=-999, y=-999}
            local entities = stack.get_blueprint_entities()
            for _, v in pairs(entities) do
                local box = prototypes[v.name].collision_box

                local top_left = {x = box.left_top.x + v.position.x, y = box.left_top.y + v.position.y}
                local bottom_right = {x = box.right_bottom.x + v.position.x, y = box.right_bottom.y + v.position.y}

                if top_left.x < min.x then min.x = top_left.x end
                if top_left.y < min.y then min.y = top_left.y end
                if bottom_right.x > max.x then max.x = bottom_right.x end
                if bottom_right.y > max.y then max.y = bottom_right.y end
            end

            local center = {x = math.floor(((max.x - min.x) / 2) + 0.5), y = math.floor(((max.y - min.y) / 2) + 0.5) }
            local position = {x = 0 + center.x, y = 0 + center.y}

            local entities = stack.build_blueprint({
                surface=self.player.surface,
                force=self.player.force,
                position=position,
                force_build=true,
                direction=direction,
                skip_fog_of_war=false,
                by_player=self.player,
                raise_built=false
            })

            for _, v in pairs(entities) do
                v.revive()
            end

            break
        end
    end
end

-- util functions copied from https://github.com/Jelmergu/factorio-console-extended/blob/master/console-extended/Commands.lua

function Commands.util.command(event)
    Commands.player = game.get_player(event.player_index)
    Commands.parameters = Commands.util.explode(event.parameter, " ")
    Commands.parameterCount = 0
    Commands.admin = Commands.player.admin

    for _, _ in pairs(Commands.parameters) do 
        Commands.parameterCount = Commands.parameterCount + 1
    end
    Commands.calledCommand = event.name

    Commands[Commands.calledCommand](Commands)
end

function Commands.util.explode(s, delimiter)
    if type(s) ~= "string" then return {} end
    
    local result = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

function Commands.util.getCommands()
    local returnTable = {}
    for k, _ in pairs(Commands) do
        if type(_) == "function" then
            table.insert(returnTable, k)
        end
    end
    return returnTable
end

return Commands