--this is the 'higher level' controller which will manage all the individual modules that we create.
--should reduce dependencies.
--if possible, call all events HERE: they can get rediredcted from here outwards



local PlayerController = {}
PlayerController.__index = PlayerController



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ComputerAppearanceController = require(Shared:WaitForChild("ComputerAppearanceController"))
local PlayerInfo = require(Shared:WaitForChild("PlayerInfo"))


local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SetupPlayerInRoom : RemoteEvent = Remotes:WaitForChild("SetupPlayerInRoom")

local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")
local CheckRoomSize: BindableEvent = Bindables:WaitForChild("CheckRoomSize")

local PlayerBecomingAlive: RemoteEvent = Remotes:WaitForChild("PlayerBecomingAlive")
local PlayerDied = Remotes:WaitForChild("PlayerDied")

PlayerController.Computers = {}

function PlayerController.new(Player)
    local newPlayerController = setmetatable({}, PlayerController)
    newPlayerController.Player = Player
    PlayerController.Computers[Player.Name] = newPlayerController

    return newPlayerController
end


function PlayerController:CreateComputer()
    ComputerAppearanceController.new(self.Player) --holds the players computer model and will control its appearance
    PlayerInfo.SetupNewPlayer(self.Player) --holds player information
    --temp solution to "killing everyone"
    self.Player.Character.Humanoid:TakeDamage(10000000)
    self.Player.Character:Destroy()

end

function PlayerController:Spawn(position)
    --creates computer model
    local PlayerModel = ComputerAppearanceController.SpawnComputer(self.Player,position)

    --sets player information alive
    PlayerInfo.SetPlayerAlive(self.Player, PlayerModel)

    --send information and events to client player
    local args = {}
    args[1] = position
    SetupPlayerInRoom:FireClient(self.Player,args)    
    PlayerBecomingAlive:FireClient(self.Player, PlayerModel)
end


--when a player "dies" from game loop logic
function PlayerController:HiddenDeath()    
    ComputerAppearanceController.DespawnComputer(self.Player)
    PlayerInfo.SetPlayerDying(self.Player)
end


--when a player actually dies from damage (this should happen within a room)
function PlayerController:Die()    
    ComputerAppearanceController.DespawnComputer(self.Player)
    PlayerInfo.SetPlayerDying(self.Player)
    PlayerDied:FireClient(self.Player)
    CheckRoomSize:Fire()

end

function PlayerController:TakeDamage(damageAmount)
    print(self.Player.Name .. "takes damage: " .. damageAmount)
    PlayerInfo.PlayerInformationDictionary[self.Player.Name].Health -= damageAmount
    if PlayerInfo.PlayerInformationDictionary[self.Player.Name].Health <= 0 then
        self:Die()
    end
end


return PlayerController