ENT.Type = "anim"
ENT.PrintName = "Workshop"
ENT.Category = "Helix"
ENT.Spawnable = false
ENT.bNoPersist = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "DisplayName")
    self:NetworkVar("String", 1, "Description")
end

if SERVER then
    function ENT:Initialize()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local definition = ix.workshop.stations[self:GetModel():lower()]

        if (definition) then
            self:SetDisplayName(definition.name)
            self:SetDescription(definition.description)
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
        if not char then return end

        local inv = char:GetInventory()
        if not inv then return end

        local definition = ix.workshop.stations[self:GetModel():lower()]
        if not definition then return end

        -- Getting input and output tables from the definition for easier access
        local inputItemsTable = definition.input
        local outputItemsTable = definition.output

        if not inputItemsTable or not outputItemsTable then return end

        -- Check if the player has all required input items
        for _, inputItem in ipairs(inputItemsTable) do
            if (inv:GetItemCount(inputItem[1], false) < inputItem[2]) then
                client:NotifyLocalized("wsInfo", ix.item.list[inputItem[1]].name)
                return
            end
        end

        local time = definition.workTime or ix.config.Get("workshopDefaultWorkTime", 30)

        client:SetAction("Working...", time)
        client:DoStaredAction(self, function()
            -- Double check if the player still has the required items after the work time
            for _, inputItem in ipairs(inputItemsTable) do
                if (inv:GetItemCount(inputItem[1], false) < inputItem[2]) then
                    client:NotifyLocalized("wsInfo", ix.item.list[inputItem[1]].name)
                    return
                end
            end
            -- Remove input items
            for _, inputItem in ipairs(inputItemsTable) do
                for i = 1, inputItem[2] do
                    local item = inv:HasItem(inputItem[1])
                    if item then                        
                        inv:Remove(item.id)
                    end
                end
            end
            -- Add output items
            for _, outputItem in ipairs(outputItemsTable) do
                for i = 1, outputItem[2] do
                    local item = ix.item.Get(outputItem[1])

                    if (inv:FindEmptySlot(item.width, item.height, false)) then
                        inv:Add(outputItem[1])
                        client:NotifyLocalized("wsYouMade", ix.item.list[outputItem[1]].name)
                    else 
                        local spawnPos = client:GetPos() + Vector(0, 0, 50) + client:GetForward() * 5
                        ix.item.Spawn(outputItem[1], spawnPos, nil, Angle(0, 0, 0), nil)
                        client:NotifyLocalized("wsInventoryFull", ix.item.list[outputItem[1]].name)
                    end
                end
            end

            client:SetAction()
        end, 
        time,
        function()
            client:SetAction()
            for _, outputItem in ipairs(outputItemsTable) do
                client:NotifyLocalized("wsFailed", ix.item.list[outputItem[1]].name)
            end
        end)
    end
else
	ENT.PopulateEntityInfo = true

	function ENT:OnPopulateEntityInfo(tooltip)
		local definition = ix.workshop.stations[self:GetModel():lower()]

		local title = tooltip:AddRow("name")
		title:SetImportant()
		title:SetText(self:GetDisplayName())
		title:SetBackgroundColor(Color(255, 196, 0, 150))
		title:SizeToContents()

		local description = tooltip:AddRow("description")
		description:SetText(definition.description)
		description:SizeToContents()
	end
end