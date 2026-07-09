local PLUGIN = PLUGIN

PLUGIN.name = "Workshops"
PLUGIN.author = "Keller"
PLUGIN.description = "Adds workshops where you can exchange items."
PLUGIN.schema = "Any"

ix.workshop = ix.workshop or {}
ix.workshop.stations = ix.workshop.stations or {}

function ix.workshop.GetSoundPath(soundPath)
    if not soundPath or soundPath == "" then return "" end
    
    if string.StartWith(soundPath, "..") or string.find(soundPath, "plugins/") then
        return soundPath
    end

    local gamemodeFolder = engine.ActiveGamemode()
    return "../gamemodes/" .. gamemodeFolder .. "/plugins/workshops/sounds/" .. soundPath
end

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
            self:SaveWorkshops()
        end
    end

    function PLUGIN:SaveWorkshops()
        local data = {}

        for _, v in ipairs(ents.FindByClass("ix_workshop")) do
            local timeLeft = 0
            if v:GetIsWorking() then
                timeLeft = math.max(0, v:GetEndTime() - CurTime())
            end

            data[#data + 1] = {
                pos = v:GetPos(),
                angles = v:GetAngles(),
                model = v:GetModel(),
                isWorking = v:GetIsWorking(),
                timeLeft = timeLeft,
                hasItems = v:GetHasItems(),
                displayName = v:GetDisplayName(),
                description = v:GetDescription()
            }
        end

        self:SetData(data)
    end

    function PLUGIN:SaveData()
        self:SaveWorkshops()
    end

    function PLUGIN:WorkshopStateChanged(entity)
        self:SaveWorkshops()
    end

    function PLUGIN:WorkshopRemoved(entity)
        timer.Simple(0, function()
            self:SaveWorkshops()
        end)
    end

    function PLUGIN:LoadData()
        local data = self:GetData()

        if data then
            for _, v in ipairs(data) do
                local workshop = ents.Create("ix_workshop")
                workshop:SetPos(v.pos)
                workshop:SetAngles(v.angles)
                workshop:SetModel(v.model)
                workshop:Spawn()

                workshop:SetDisplayName(v.displayName or "")
                workshop:SetDescription(v.description or "")
                workshop:SetHasItems(v.hasItems or false)
                
                if v.isWorking and v.timeLeft and v.timeLeft > 0 then
                    workshop:SetIsWorking(true)
                    workshop:SetEndTime(CurTime() + v.timeLeft)
                    
                    local definition = ix.workshop.stations[v.model:lower()]
                    if definition and definition.workSound then
                        local soundPath = definition.workSound
                        local finalSound = istable(soundPath) and table.Random(soundPath) or soundPath
                        if finalSound and finalSound ~= "" then
                            local resolvedPath = ix.workshop.GetSoundPath(finalSound)
                            workshop.workSoundPatch = CreateSound(workshop, resolvedPath)
                            if workshop.workSoundPatch then
                                workshop.workSoundPatch:Play()
                            end
                        end
                    end
                else
                    workshop:SetIsWorking(false)
                    workshop:SetEndTime(0)
                end
            end
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