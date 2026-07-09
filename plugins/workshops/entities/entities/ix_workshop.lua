ENT.Type = "anim"
ENT.PrintName = "Workshop"
ENT.Category = "Helix"
ENT.Spawnable = false
ENT.bNoPersist = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "DisplayName")
    self:NetworkVar("String", 1, "Description")
    self:NetworkVar("Float", 0, "EndTime")
    self:NetworkVar("Bool", 0, "IsWorking")
    self:NetworkVar("Bool", 1, "HasItems")
end

if SERVER then
    function ENT:Think()
        if self:GetIsWorking() then
            local endTime = self:GetEndTime()

            if CurTime() >= endTime then
                self:SetIsWorking(false)
                self:SetEndTime(0)
                self:SetHasItems(true)

                if self.workSoundPatch then
                    self.workSoundPatch:Stop()
                    self.workSoundPatch = nil
                end

                hook.Run("WorkshopStateChanged", self)
            end
        end

        self:NextThink(CurTime() + 0.5) 
        return true
    end

    function ENT:OnRemove()
        if self.workSoundPatch then
            self.workSoundPatch:Stop()
            self.workSoundPatch = nil
        end

        hook.Run("WorkshopRemoved", self)
    end

    local function CheckInventoryForItems(inv, items, client)
        if not inv then return false end
        if not items or #items == 0 then return true end

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
        if not items or #items == 0 then return true end

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
            local quantity = outputItem[2] or 1
            local itemTable = ix.item.Get(itemID)

            if not itemTable then continue end

            for i = 1, quantity do
                local result, err = inv:Add(itemTable.uniqueID)
                if not result then
                    success = false
                    lastFailedName = itemTable.name or itemID
                    
                    if spawnPos then
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
        if not IsValid(client) then return end

        local model = workshop:GetModel()
        local definition = model and ix.workshop.stations[model:lower()]

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

        client:SetAction("@wsWorking", time)
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

            if workshop.workSoundPatch then
                workshop.workSoundPatch:Stop()
                workshop.workSoundPatch = nil
            end

            client:SetAction()
        end, 
        time,
        function()
            if workshop.workSoundPatch then
                workshop.workSoundPatch:Stop()
                workshop.workSoundPatch = nil
            end

            client:SetAction()
            for _, outputItem in ipairs(outputItemsTable) do
                local itemTable = ix.item.Get(outputItem[1])
                local name = itemTable and itemTable.name or outputItem[1]
                client:NotifyLocalized("wsFailed", name)
            end
        end)
    end

    local function StartToggleWork(client, time, inputItemsTable, outputItemsTable, workshop)
        if not IsValid(client) or not client:IsPlayer() then return end
        if not workshop then return end

        local char = client:GetCharacter()
        if not char then return end

        local inv = char:GetInventory()
        if not inv then return end

        if not CheckInventoryForItems(inv, inputItemsTable, client) then return end
        if not RemoveItemsFromInventory(inv, inputItemsTable) then return end

        local endTime = CurTime() + time

        local model = workshop:GetModel()
        local definition = model and ix.workshop.stations[model:lower()]
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

        workshop:SetHasItems(false)
        workshop:SetEndTime(endTime)
        workshop:SetIsWorking(true)
        
        hook.Run("WorkshopStateChanged", workshop)
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

        if self:GetIsWorking() then
            client:NotifyLocalized("wsBusy")
            return
        end

        local outputItemsTable = definition.output
        if not outputItemsTable then return end

        if self:GetHasItems() then
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
                self:SetHasItems(false)
                self:SetDescription(definition.description or "")
                
                hook.Run("WorkshopStateChanged", self)
            else
                client:NotifyLocalized("wsInventoryFull", failedItemName or "items")
            end

            return
        end

        if definition.tools then
            for _, toolID in ipairs(definition.tools) do
                if not inv:HasItem(toolID) then
                    local itemTable = ix.item.Get(toolID)
                    local toolName = itemTable and (itemTable.name or toolID) or toolID
                    client:NotifyLocalized("wsNoTool", toolName)
                    return
                end
            end
        end

        local inputItemsTable = definition.input or {}
        if #inputItemsTable > 0 then
            if not CheckInventoryForItems(inv, inputItemsTable, client) then return end
        end

        local time = definition.workTime or ix.config.Get("workshopDefaultWorkTime", 30)
        local wType = definition.type or WorkshopType.HOLD

        if wType == WorkshopType.HOLD then
            StartHoldWork(client, time, inputItemsTable, outputItemsTable, self)
        elseif wType == WorkshopType.TOGGLE then
            StartToggleWork(client, time, inputItemsTable, outputItemsTable, self)
        end
    end
else
    ENT.PopulateEntityInfo = true

    function ENT:OnPopulateEntityInfo(tooltip)
        local model = self:GetModel()
        if not model then return end

        local definition = ix.workshop.stations[model:lower()]
        if not definition then return end

        local nameStr = self:GetDisplayName()
        if nameStr == "" then nameStr = definition.name end

        local descStr = self:GetDescription()
        if descStr == "" then descStr = definition.description end

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText(L(nameStr))
        title:SetBackgroundColor(Color(255, 196, 0, 150))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText(L(descStr))
        description:SizeToContents()

        if self:GetIsWorking() then
            local timeLeft = math.max(0, math.ceil(self:GetEndTime() - CurTime()))
            
            local timerRow = tooltip:AddRow("timer")
            timerRow:SetText(L("wsTimeLeft", timeLeft))
            timerRow:SetBackgroundColor(Color(200, 50, 50, 150))
            timerRow:SizeToContents()
        end

        if self:GetHasItems() then
            local endedRow = tooltip:AddRow("ended")
            endedRow:SetText(L("wsReady"))
            endedRow:SetBackgroundColor(Color(50, 200, 50))
            endedRow:SizeToContents()
        end
    end
end