-- editor.lua

local active_data = {}
active_data.chunks = {}

function GetActiveData() return active_data end

function MarkChunk(chunkData)
    table.insert(active_data.chunks, chunkData)
end

function SetBlueprintString(blueprintString)
    active_data.blueprint = blueprintString
end

function OutputChunkData()
    game.write_file("chunkdata.txt", serpent.dump(active_data).."\n", true, 1)
end