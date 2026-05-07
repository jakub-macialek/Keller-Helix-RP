local PLUGIN = PLUGIN

local loots = {
    ["trash"] = {
        {"fish", 50},
        {"water", 50},
    }
}

local containers = {
    ["models/props_junk/trashbin01a.mdl"] = "trash"
}

local function PopulateContainer(container)
    local inv = container:GetInventory()
    print("POPCON Container inventory:", inv)

    print("Checking if container is already populated...")
--    if(inv:GetData("populated", false)) then
--        print("Container is already populated, skipping loot population.")
--        return 
--    end

    local width, height = inv:GetSize()
    if (inv:GetFilledSlotCount() >= width * height) then return end

    print("Container is not populated, populating with loot...")

    local lootType = container:GetNWString("lootType", "")
    local lootTable = loots[lootType]

    if (not lootTable) then return end
    print("Loot type:", lootType, "Loot table:", lootTable)

    for _, itemData in ipairs(lootTable) do
        if(inv:GetFilledSlotCount() >= width * height) then 
            print("Container inventory is full, stopping loot population.")
            break 
        end

        local itemID = itemData[1]
        local chance = itemData[2]

        if (math.random(1, 100) <= chance) then
            inv:Add(itemID, 1)
        end
    end

--  inv:SetData("populated", true)
end

function PLUGIN:OnContainerOpened(client, container)
    print("Container opened:", client, container)
    if (not IsValid(client) or not IsValid(container)) then return end

    print("Container class:", container:GetClass())
    if (container:GetClass() ~= "ix_container") then return end

    print("Container model:", container:GetModel())

    local model = string.lower(container:GetModel() or "")
    local lootType = containers[model]

    if (lootType and container:GetNWString("lootType", "") == "") then
        container:SetNWString("lootType", lootType)
    end

    print("Loot type:", container:GetNWString("lootType", ""))
    timer.Simple(0, function()
        if (IsValid(container)) then
            print("Populating container with loot...")
            PopulateContainer(container)
        end
    end)
end

function PLUGIN:OnContainerClosed(client, container)
end