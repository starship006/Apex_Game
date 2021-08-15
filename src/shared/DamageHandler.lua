--handles logic for damage type stuff
--right now, parts that take damage need to have a attribute "Health" or "PlayerName" THAT DISPLAYS HOW MUCH HEALTH THEY HAVE
local DamageHandler = {}


--internal services and modules
local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")
local DealDamageToPlayer: BindableEvent = Bindables:WaitForChild("DealDamageToPlayer")


function DamageHandler.SeeIfPartTakesDamage(part)
    print(part)
    if part:GetAttribute("Health") or part.Parent:GetAttribute("PlayerName") then
        return true
    end
    return false
end

function DamageHandler.DealDamageToPart(damage: number, part)
    print("trying to deal damage to this part")
    print(part)
    local health = part:GetAttribute("Health")

    if part.Parent:GetAttribute("PlayerName") then
        --this is a player. different logic is needed
        print("this is a player lol")
        DealDamageToPlayer:Fire(part.Parent:GetAttribute("PlayerName"),damage)
    else
        --this is a part. basic logic
        health = health - damage
        if health < 0 then
            
            part:Destroy()
        else
            part:SetAttribute("Health", health)    
        end
    end
    
end




return DamageHandler