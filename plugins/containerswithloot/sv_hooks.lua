local PLUGIN = PLUGIN

include("sv_loot.lua")

local function ClearContainerInventory(inv)
    if (not inv) then return end
    
    for _, item in pairs(inv:GetItems()) do
        item:Remove()
    end
end

local function PopulateContainer(container)
    local inv = container:GetInventory()
    if (not inv or container.ixLootPopulated) then return end

    local lootType = container:GetNWString("lootType", "")
    local lootTable = PLUGIN.loots[lootType]

    if (not lootTable) then return end

    for _, itemData in ipairs(lootTable) do
        local itemID = itemData[1]
        local chance = itemData[2]

        if (math.random(1, 100) <= chance) then
            inv:Add(itemID) 
        end
    end

    container.ixLootPopulated = true
    container.ixNextLootRespawn = CurTime() + ix.config.Get("containerLootRespawnTime", 300)
end

function PLUGIN:OnContainerOpened(client, container)
    if (not IsValid(client) or not IsValid(container)) then return end
    if (container:GetClass() ~= "ix_container") then return end

    local model = string.lower(container:GetModel() or "")
    local lootType = PLUGIN.containers[model]

    if (lootType and container:GetNWString("lootType", "") == "") then
        container:SetNWString("lootType", lootType)
    end

    if (container.ixNextLootRespawn and CurTime() >= container.ixNextLootRespawn) then
        local inv = container:GetInventory()
        ClearContainerInventory(inv)
        container.ixLootPopulated = false
    end

    timer.Simple(0, function()
        if (IsValid(container)) then
            PopulateContainer(container)
        end
    end)
end