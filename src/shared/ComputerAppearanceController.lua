--this handles the computers of players
--it should be able to add parts to the computer, customize the computer
--this just handles the movement and appearance of the computer

local ComputerAppearanceController = {}

--call on these things
ComputerAppearanceController.ComputerModels = {}



--internal service calls
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Models = ReplicatedStorage:WaitForChild("Models")
local StarterCharacter = Models:WaitForChild("StarterCharacter")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlayerInfo = require(Shared:WaitForChild("PlayerInfo"))

local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")


--internal folders
local WeaponsFolder= ReplicatedStorage:WaitForChild("Weapons"):GetChildren()


ComputerAppearanceController.WeaponModels = {}
for index, weaponModel in pairs(WeaponsFolder) do
    ComputerAppearanceController.WeaponModels[weaponModel.Name] = weaponModel
end




function ComputerAppearanceController.new(Player)
    local FreshComputerModel = StarterCharacter:Clone()

    FreshComputerModel.Name = Player.Name
    FreshComputerModel:SetAttribute("PlayerName", Player.Name)
    FreshComputerModel:WaitForChild("Glowy").BrickColor = BrickColor.random()
    ComputerAppearanceController.ComputerModels[Player.Name] = FreshComputerModel

end

function ComputerAppearanceController.SpawnComputer(Player,position)
    if PlayerInfo.PlayerInformationDictionary[Player.Name].ActiveModel then
        PlayerInfo.PlayerInformationDictionary[Player.Name].ActiveModel.Parent = nil
        PlayerInfo.PlayerInformationDictionary[Player.Name].Active = false
        print("what bruh")
    end

    local playerModel = ComputerAppearanceController.ComputerModels[Player.Name]:Clone()
    playerModel.Parent = workspace
    for i,v in pairs(playerModel:GetDescendants()) do
        if v:IsA("BasePart") then
            v:SetNetworkOwner(Player)
        end
    end
    
    playerModel:SetPrimaryPartCFrame(CFrame.new(position))
    return playerModel
end

function ComputerAppearanceController.DespawnComputer(Player)
    if not PlayerInfo.PlayerInformationDictionary[Player.Name].ActiveModel then
        print(debug.traceback)
        error("cannot despawn computer that dosent exist")
    else
        PlayerInfo.PlayerInformationDictionary[Player.Name].ActiveModel:Destroy()
    end
end



--this is super fragile and messed up. when i scale up, this needs to be rewritten

function ComputerAppearanceController.AddWeaponToModel(PlayerName,WeaponModelName)
    local targetWeaponModel = ComputerAppearanceController.WeaponModels[WeaponModelName]
    local hitbox = targetWeaponModel:WaitForChild("Hitbox")
    local weaponModelHeightOffset: number = hitbox.Size.Y

    local toAddToPlayerModel = targetWeaponModel.MainPart
    if not toAddToPlayerModel then
        print("PART NOT FOUND, ERROR!!!!!!")
    end

    toAddToPlayerModel = toAddToPlayerModel:Clone()

    local PlayerModel = ComputerAppearanceController.ComputerModels[PlayerName]
    toAddToPlayerModel.CFrame = PlayerModel.BasePart.CFrame + Vector3.new(0,weaponModelHeightOffset,0)

    local Weld: WeldConstraint = PlayerModel:WaitForChild("Glowy"):WaitForChild("AttachToWeapon")
    Weld.Part1 = toAddToPlayerModel
    toAddToPlayerModel.Parent = PlayerModel
end


function ComputerAppearanceController.RemoveWeaponFromModel(PlayerName)
    local PlayerModel = ComputerAppearanceController.ComputerModels[PlayerName]
    local Weapon = PlayerModel:WaitForChild("MainPart")
    if not Weapon then
        print("couldnt find a weapon to remove, interesting")
    else
        Weapon:Destroy()
        PlayerModel.Glowy.AttachToWeapon.Part1 = nil   --clearing the weld
    end
end

function ComputerAppearanceController.GetComputerFirePoint(PlayerName)
    local ActiveModel = PlayerInfo.PlayerInformationDictionary[PlayerName].ActiveModel

    if ActiveModel then
        local FirePoint: Attachment = ActiveModel:WaitForChild("MainPart"):WaitForChild("FireSpot")
        return FirePoint.WorldPosition
    else
        print("no active model!")            
    end
end

return ComputerAppearanceController