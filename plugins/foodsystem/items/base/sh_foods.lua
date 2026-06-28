ITEM.name = "Consumable Base"
ITEM.model = Model("models/props_junk/garbage_takeoutcarton001a.mdl")
ITEM.description = "A base for consumables."
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"

ITEM.useSound = "npc/barnacle/barnacle_crunch2.wav"
ITEM.useName = "Consume"
ITEM.useTime = 3

ITEM.RestoreHunger = 0
ITEM.RestoreThirst = 0
ITEM.isDrink = false

ITEM.diseases = nil

-- ITEM.OnConsume = function(item, client, char) ... end

ITEM.functions.Consume = {
    icon = "icon16/user.png",
    name = "Consume",
    OnCanRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end
        if not client:Alive() then return false end

        if IsValid(item.entity) then return false end

        if client.ixConsumeActionEnd and CurTime() < client.ixConsumeActionEnd then
            return false
        end

        return true
    end,
    OnRun = function(item)
        local client = item.player
        local char = client:GetCharacter()
        if not char then return false end

        if client.ixConsumeActionEnd and CurTime() < client.ixConsumeActionEnd then
            client:NotifyLocalized("fsFullMouth")
            return false
        end

        local isDrink = item.isDrink or false
        if not isDrink and isstring(item.useSound) then
            isDrink = string.find(item.useSound:lower(), "drink") ~= nil
        end

        local actionText = isDrink and "@fsDrinking" or "@fsEating"
        local useTime = tonumber(item.useTime) or 0

        local function ConsumeFunction(ply, character)
            if not IsValid(ply) or not ply:Alive() then return end
            if not ply:GetCharacter() or ply:GetCharacter():GetID() ~= character:GetID() then return end

            -- Pobieramy ekwipunek, w którym aktualnie znajduje się przedmiot
            local currentInv = ix.item.inventories[item.invID]
            local hasAccess = false

            -- Sprawdzamy, czy ekwipunek istnieje oraz czy gracz ma do niego dostęp (np. otwarty kontener lub własne EQ)
            if currentInv and currentInv:GetItemByID(item.id) then
                if currentInv:OnCheckAccess(ply) then
                    hasAccess = true
                -- Dodatkowe zabezpieczenie na wypadek specyficznych konfiguracji toreb
                elseif item:GetOwner() == ply then
                    hasAccess = true
                end
            end

            -- Jeśli przedmiot został usunięty, zamknięto kontener lub wyrzucono torbę
            if not hasAccess then
                ply:NotifyLocalized("fsItemLost")
                return
            end

            if item.useSound then
                if istable(item.useSound) then
                    ply:EmitSound(table.Random(item.useSound))
                else
                    ply:EmitSound(item.useSound)
                end
            end

            if item.RestoreHunger and item.RestoreHunger > 0 then
                if character.SetHunger then
                    character:SetHunger(math.Clamp(character:GetHunger() + item.RestoreHunger, 0, 100))
                end
            end

            if item.RestoreThirst and item.RestoreThirst > 0 then
                if character.SetThirst then
                    character:SetThirst(math.Clamp(character:GetThirst() + item.RestoreThirst, 0, 100))
                end
            end

            if item.diseases and istable(item.diseases) then
                for diseaseID, chance in pairs(item.diseases) do
                    if math.random() <= chance then
                        hook.Run("OnPlayerContractDisease", ply, diseaseID, item)
                    end
                end
            end

            if item.OnConsume then
                item:OnConsume(ply, character)
            end

            item:Remove()
        end

        if useTime > 0 then
            client.ixConsumeActionEnd = CurTime() + useTime
            
            client:SetAction(actionText, useTime, function()
                ConsumeFunction(client, char)
            end)

            return false
        else
            ConsumeFunction(client, char)
            return false
        end
    end
}