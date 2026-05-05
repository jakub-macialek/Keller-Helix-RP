local PLUGIN = PLUGIN

function PLUGIN:CharacterPreSave(char)
    local client = char:GetPlayer()

    if (char and IsValid(client)) then
        local timeLeft = 0

        if (client.ixHungerTick) then
            timeLeft = math.max(client.ixHungerTick - CurTime(), 0)
        end

        char:SetData("hunger", char:GetHunger())
        char:SetData("hungerTimeLeft", timeLeft)

        if(client.ixThirstTick) then
            timeLeft = math.max(client.ixThirstTick - CurTime(), 0)
        end

        char:SetData("thirst", char:GetThirst())
        char:SetData("thirstTimeLeft", timeLeft)
    end
end

function PLUGIN:CharacterLoaded(char)
    local client = char:GetPlayer()

    if (char and IsValid(client)) then
        local hunger = char:GetData("hunger", 100)
        local thirst = char:GetData("thirst", 100)

        local timeLeft = char:GetData("hungerTimeLeft", ix.config.Get("hungerTime", 120))
        local thirstTimeLeft = char:GetData("thirstTimeLeft", ix.config.Get("hungerTime", 120))

        char:SetHunger(hunger)
        char:SetThirst(thirst)

        client.ixHungerTick = CurTime() + timeLeft
        client.ixThirstTick = CurTime() + thirstTimeLeft
    end
end

local factionIgnore = {
//    [FACTION_OTA] = true,
}

function PLUGIN:PlayerTick(client)
    if ( client:IsValid() and client:GetCharacter() ) then
        if not client.ixHungerTick or client.ixHungerTick <= CurTime() then
            if ( factionIgnore[client:Team()] ) then return false end
            if ( client:GetMoveType() == MOVETYPE_NOCLIP ) then return false end

            local char = client:GetCharacter()

            if ( char:GetHunger() == 0 ) then
                client:TakeDamage(math.random(10, 20))
                client:EmitSound("npc/barnacle/barnacle_digesting" .. math.random(1,2) .. ".wav", 50)
                client:ChatNotify("You are dying of starvation!")
    
                client.ixHungerTick = CurTime() + 60
                return false
            end

            local newHunger = math.Clamp(char:GetHunger() - 1, 0, 100)
            
            char:SetHunger(newHunger)

            client.ixHungerTick = CurTime() + ( ix.config.Get("hungerTime", 120) )
        end
        if not client.ixThirstTick or client.ixThirstTick <= CurTime() then
            if ( factionIgnore[client:Team()] ) then return false end
            if ( client:GetMoveType() == MOVETYPE_NOCLIP ) then return false end

            local char = client:GetCharacter()

            if ( char:GetThirst() == 0 ) then
                client:TakeDamage(math.random(10, 20))
                client:EmitSound("npc/barnacle/barnacle_digesting" .. math.random(1,2) .. ".wav", 50)
                client:ChatNotify("You are dying of dehydration!")
    
                client.ixThirstTick = CurTime() + 60
                return false
            end

            local newThirst = math.Clamp(char:GetThirst() - 1, 0, 100)
            
            char:SetThirst(newThirst)

            client.ixThirstTick = CurTime() + ( ix.config.Get("hungerTime", 120) )
        end
    end
end
