ENT.Type = "anim"
ENT.PrintName = "Workshop"
ENT.Category = "Helix"
ENT.Spawnable = false
ENT.bNoPersist = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "DisplayName")
    self:NetworkVar("String", 1, "InputItem")
    self:NetworkVar("String", 2, "OutputItem")
    self:NetworkVar("Int", 3, "WorkTime")
end

if SERVER then
    function ENT:Initialize()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local definition = ix.workshop.stations[self:GetModel():lower()]

        if (definition) then
            self:SetDisplayName(definition.name)
            self:SetInputItem(definition.input)
            self:SetOutputItem(definition.output)
            self:SetWorkTime(definition.workTime)
        end

        local physObj = self:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:EnableMotion(true)
            physObj:Wake()
        end
    end

    function ENT:Use(client)
        if not IsValid(client) or not client:IsPlayer() then return end

        local char = client:GetCharacter()
        local inv = char:GetInventory()

        local inputItem = self:GetInputItem()
        local outputItem = self:GetOutputItem()
        local time = self:GetWorkTime()

        local item = inv:HasItem(inputItem)
        if not item then
            client:Notify("You need to have " .. ix.item.list[inputItem].name .. " to make " .. ix.item.list[outputItem].name .. ".")
            return
        end

        client:SetAction("Working...", time)
        client:DoStaredAction(self, function()
            inv:Remove(item.id)
            inv:Add(outputItem)

            client:SetAction()
            client:Notify("Work completed.")
        end, 
        time,
        function()
            client:SetAction()
            client:Notify("Stopped working.")
        end)
    end
end