--singleton responsible for holding onto all weapons, weapon logic, etc. Responsible for distributing weapons to clients and 
--setting up proper server events to make the weapon function

local WeaponController = {}

WeaponController.Weapons = {}  --not setup in this code. dont know if ill use this

--internal modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponsFolder= ReplicatedStorage:WaitForChild("Weapons"):GetChildren()

local Shared = ReplicatedStorage:WaitForChild("Shared")
local FastCastListener = require(Shared:WaitForChild("FastCastListener"))

--local PlayerInfo = require(Shared:WaitForChild("PlayerInfo"))
--local PlayerController = require(Shared:WaitForChild("PlayerController"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendOfferWeaponChoices: RemoteEvent = Remotes:WaitForChild("SendOfferWeaponChoices")
local ReturnOfferWeaponChoices: RemoteEvent = Remotes:WaitForChild("ReturnOfferWeaponChoices")
local SendPlayerOkToFire: RemoteEvent = Remotes:WaitForChild("SendPlayerOkToFire")

local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")
local GivePlayerWeapon :BindableEvent = Bindables:WaitForChild("GivePlayerWeapon")

WeaponController.__CurrentRequestTowardsPlayers = {}

--get weapons setup
--internal folders


WeaponController.WeaponModels = {}  --[WeaponName][Model]
WeaponController.IndexWeapons = {}  --[Index][Model]
for index, weaponModel in pairs(WeaponsFolder) do
    WeaponController.WeaponModels[weaponModel.Name] = weaponModel
    WeaponController.IndexWeapons[index] = weaponModel.Name
end





function WeaponController.OfferWeaponsToPlayer(Player: Player, Choices: table)
    if WeaponController.__CurrentRequestTowardsPlayers[Player] == nil then
        WeaponController.__CurrentRequestTowardsPlayers[Player] = {}


        for i, weaponChoice in ipairs(Choices) do
            WeaponController.__CurrentRequestTowardsPlayers[Player][i] = weaponChoice
        end
    else
        warn("there was something inside of weapon controller to start")    
        WeaponController.__CurrentRequestTowardsPlayers[Player] = {}


        for i, weaponChoice in ipairs(Choices) do
            WeaponController.__CurrentRequestTowardsPlayers[Player][i] = weaponChoice
        end
    end

    SendOfferWeaponChoices:FireClient(Player,Choices)
    print("SENDOFFERWEAPONCHOICES EVENT SENT... AWAITING REQUEST")
end    


function WeaponController.OnReturnOfferWeaponChoices(Player: Player, choice: integer)
    --choice sould reference the WeaponController.__CurrentRequestTowardsPlayers

    if WeaponController.__CurrentRequestTowardsPlayers[Player] == nil then
        error("there is no request currently being sent to the player. no bueno")
    else
        --player did in fact recieve a request
        if WeaponController.__CurrentRequestTowardsPlayers[Player][choice] then        

            GivePlayerWeapon:Fire(Player, WeaponController.__CurrentRequestTowardsPlayers[Player][choice])
            WeaponController.__CurrentRequestTowardsPlayers[Player] = nil --close out any other possibility of the client requesting something
        else
           error("the choice did not align with anything present in the table. what") 
        end    
    end
end


--equip the weapon of string
function WeaponController.EquipWeapon(PlayerName, weaponChoice: string)
    local Weapon = WeaponController.WeaponModels[weaponChoice]
    local Bullet = Weapon:WaitForChild("Bullet")
    local FireDelay = Bullet:GetAttribute("FireDelay")

    FastCastListener.SetPlayerWeaponInformation(PlayerName, FireDelay, Bullet)

end

function WeaponController.ReturnRandomWeaponName()
    return WeaponController.IndexWeapons[2]
end

ReturnOfferWeaponChoices.OnServerEvent:Connect(WeaponController.OnReturnOfferWeaponChoices)








--establish the ok to fire
function WeaponController.CreateWeaponLogic(Player: Player)
    --right now we are assuming that each weapon is using fastcast. we will expand later

    --FastCastListener work?
    SendPlayerOkToFire:FireClient(Player)



end


--closing the ok to fire
function WeaponController.CloseWeaponLogic(Player: Player)
    


    

end


return WeaponController

