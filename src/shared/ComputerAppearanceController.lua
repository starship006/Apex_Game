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


function ComputerAppearanceController.new(Player)
    local FreshComputerModel = StarterCharacter:Clone()

    
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
        error("cannot despawn computer that dosent exist")
    else
        PlayerInfo.PlayerInformationDictionary[Player.Name].ActiveModel:Destroy()
    end
end




return ComputerAppearanceController