local PLUGIN = PLUGIN

PLUGIN.name = "Workshops"
PLUGIN.author = "Keller"
PLUGIN.description = "Adds workshops where you can exchange items."
PLUGIN.schema = "Any"

ix.workshop = ix.workshop or {}
ix.workshop.stations = ix.workshop.stations or {}

function ix.workshop.Register(modelOrData, data)
    if istable(modelOrData) then
        local definition = modelOrData
        local models = definition.models or {}
        
        if definition.model then
            table.insert(models, definition.model)
        end

        for _, model in ipairs(models) do
            ix.workshop.stations[model:lower()] = definition
        end
    elseif isstring(modelOrData) and data then
        ix.workshop.stations[modelOrData:lower()] = data
    end
end

ix.util.Include("sh_definitions.lua")

if (SERVER) then
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

ix.config.Add("workshopDefaultColor", Color(255, 196, 0, 150), "The default color of workshops.", nil, {
    category = "Workshops"
})

ix.config.Add("workshopDefaultWorkTime", 30, "The default time it takes to make items in a workshop.", nil, {
    data = {min = 1, max = 120},
    category = "Workshops"
})