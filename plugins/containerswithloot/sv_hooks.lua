local PLUGIN = PLUGIN

include("sv_loot.lua")

local function PopulateContainer(container)
    local inv = container:GetInventory()

    if(inv.hasBeenPopulated) then return  end

    local width, height = inv:GetSize()
    if (inv:GetFilledSlotCount() >= width * height) then return end

    local lootType = container:GetNWString("lootType", "")
    local lootTable = loots[lootType]

    if (not lootTable) then return end

    for _, itemData in ipairs(lootTable) do
        if(inv:GetFilledSlotCount() >= width * height) then break end

        local itemID = itemData[1]
        local chance = itemData[2]

        if (math.random(1, 100) <= chance) then
            inv:Add(itemID, 1)
        end
    end

    inv.hasBeenPopulated = true
end

function PLUGIN:OnContainerOpened(client, container)
    if (not IsValid(client) or not IsValid(container)) then return end

    if (container:GetClass() ~= "ix_container") then return end

    local model = string.lower(container:GetModel() or "")
    local lootType = containers[model]

    if (lootType and container:GetNWString("lootType", "") == "") then
        container:SetNWString("lootType", lootType)
    end

    timer.Simple(0, function()
        if (IsValid(container)) then
            PopulateContainer(container)
        end
    end)
end

function PLUGIN:Tick()
    for _, container in ipairs(ents.FindByClass("ix_container")) do
        if (IsValid(container)) then
            local inv = container:GetInventory()
            if (inv and inv.hasBeenPopulated) then
                local respawnTime = ix.config.Get("containerLootRespawnTime", 300)
                if (not container.lootRespawnTime) then
                    container.lootRespawnTime = CurTime() + respawnTime
                elseif (CurTime() >= container.lootRespawnTime) then
                    inv.hasBeenPopulated = false
                    container.lootRespawnTime = nil
                end
            end
        end
    end
end