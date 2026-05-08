local PLUGIN = PLUGIN

PLUGIN.name = "Workshops"
PLUGIN.author = "Keller"
PLUGIN.description = "Adds workshop functionality."
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2026 Keller

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.workshop = ix.workshop or {}
ix.workshop.stations = ix.workshop.stations or {}

function ix.workshop.Register(model, data)
    ix.workshop.stations[model:lower()] = data
end

ix.util.Include("sh_definitions.lua")

if(SERVER) then
    function PLUGIN:PlayerSpawnedProp(client, model, entity)
        model = tostring(model):lower()
        local data = ix.workshop.stations[model]

        if data then
            local workshop = ents.Create("ix_workshop")
            workshop:SetPos(entity:GetPos())
            workshop:SetAngles(entity:GetAngles())
            workshop:SetModel(model)
            workshop:Spawn()

            entity:Remove()
        end
    end
end