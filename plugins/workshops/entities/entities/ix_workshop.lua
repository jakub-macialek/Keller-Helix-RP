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
    local function CheckInventoryForItems(inv, items, client)
        if not inv then return false end

        local missingItems = {}
        
        for _, itemInfo in ipairs(items) do
            local itemID = itemInfo[1]
            local requiredQty = itemInfo[2]

            local itemTable = ix.item.Get(itemID)
            if not itemTable then continue end

            local currentCount = inv:GetItemCount(itemID, false) or 0
            if currentCount < requiredQty then
                table.insert(missingItems, itemTable.name or itemID)
            end
        end

        if #missingItems > 0 then
            if IsValid(client) then
                for _, itemName in ipairs(missingItems) do
                    client:NotifyLocalized("wsMissingItem", itemName)
                end
            end
            return false
        end

        return true 
    end

    local function RemoveItemsFromInventory(inv, items)
        if not inv then return false end

        for _, item in ipairs(items) do
            local itemID = item[1]
            local quantity = item[2]

            for i = 1, quantity do
                local itemInstance = inv:HasItem(itemID)
                if itemInstance then
                    inv:Remove(itemInstance.id)
                else
                    break
                end
            end
        end

        return true
    end

    local function AddItemsToInventory(inv, items, client)
        if not inv then return false end

        local spawnPos = IsValid(client) and (client:GetPos() + Vector(0, 0, 10) + client:GetForward() * 20) or nil
        local success = true
        local lastFailedName = ""

        for _, outputItem in ipairs(items) do
            local itemID = outputItem[1]
            local quantity = outputItem[2]
            local itemTable = ix.item.Get(itemID)

            if not itemTable then continue end

            local result, err = inv:Add(itemTable.uniqueID, quantity)
            if not result then
                success = false
                lastFailedName = itemTable.name or itemID
                
                if spawnPos then
                    for i = 1, quantity do
                        ix.item.Spawn(itemTable.uniqueID, spawnPos, nil, Angle(0, 0, 0), nil)
                    end
                end
            end
        end

        return success, lastFailedName
    end

    function ENT:Initialize()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local model = self:GetModel()
        if model then
            local definition = ix.workshop.stations[model:lower()]
            if definition then
                self:SetDisplayName(definition.name)
                self:SetDescription(definition.description)
            end
        end

        local physObj = self:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(true)
            physObj:Wake()
        end
    end

    local function StartHoldWork(client, time, inputItemsTable, outputItemsTable, workshop)
        client:SetAction("Working...", time)
        client:DoStaredAction(workshop, function()
            local char = client:GetCharacter()
            if not char then return end

            local inv = char:GetInventory()
            if not inv then return end

            if not CheckInventoryForItems(inv, inputItemsTable, client) then return end
            if not RemoveItemsFromInventory(inv, inputItemsTable) then return end

            local outputNames = {}
            for _, v in ipairs(outputItemsTable) do
                local itemTable = ix.item.Get(v[1])
                if itemTable then
                    table.insert(outputNames, itemTable.name or v[1])
                end
            end
            local outputString = table.concat(outputNames, ", ")

            local result, failedItemName = AddItemsToInventory(inv, outputItemsTable, client)
            if result then
                client:NotifyLocalized("wsYouMade", outputString)
            else
                client:NotifyLocalized("wsInventoryFull", failedItemName or "items")
            end

            client:SetAction()
        end, 
        time,
        function()
            client:SetAction()
            for _, outputItem in ipairs(outputItemsTable) do
                local itemTable = ix.item.Get(outputItem[1])
                local name = itemTable and itemTable.name or outputItem[1]
                client:NotifyLocalized("wsFailed", name)
            end
        end)
    end

    function ENT:Use(client)
        if not IsValid(client) or not client:IsPlayer() then return end

        local char = client:GetCharacter()
        if not char then return end

        local inv = char:GetInventory()
        if not inv then return end

        local model = self:GetModel()
        if not model then return end

        local definition = ix.workshop.stations[model:lower()]
        if not definition then return end

        local inputItemsTable = definition.input
        if not inputItemsTable then return end

        if not CheckInventoryForItems(inv, inputItemsTable, client) then return end

        local time = definition.workTime or ix.config.Get("workshopDefaultWorkTime", 30)
        local outputItemsTable = definition.output
        if not outputItemsTable then return end

        StartHoldWork(client, time, inputItemsTable, outputItemsTable, self)
    end
else
    ENT.PopulateEntityInfo = true

    function ENT:OnPopulateEntityInfo(tooltip)
        local model = self:GetModel()
        if not model then return end

        local definition = ix.workshop.stations[model:lower()]
        if not definition then return end

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText(self:GetDisplayName() or definition.name)
        title:SetBackgroundColor(Color(255, 196, 0, 150))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText(definition.description)
        description:SizeToContents()
    end
end
