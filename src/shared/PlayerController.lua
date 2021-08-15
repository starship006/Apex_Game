--this is the 'higher level' controller which will manage all the individual modules that we create.
--should reduce dependencies.
--if possible, call all events HERE: they can get rediredcted from here outwards



local PlayerController = {}
PlayerController.__index = PlayerController



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ComputerAppearanceController = require(Shared:WaitForChild("ComputerAppearanceController"))
local PlayerInfo = require(Shared:WaitForChild("PlayerInfo"))
local WeaponController = require(Shared:WaitForChild("WeaponController"))
local FastCastListener = require(Shared:WaitForChild("FastCastListener"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SetupPlayerInRoom : RemoteEvent = Remotes:WaitForChild("SetupPlayerInRoom")

local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")
local CheckRoomSize: BindableEvent = Bindables:WaitForChild("CheckRoomSize")
local GivePlayerWeapon :BindableEvent = Bindables:WaitForChild("GivePlayerWeapon")

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
    FastCastListener.SetupPlayer(self.Player.Name)
end

function PlayerController:Spawn(position)

    --creates computer model
    local PlayerModel = ComputerAppearanceController.SpawnComputer(self.Player,position)

    --sets player information alive
    PlayerInfo.SetPlayerAlive(self.Player, PlayerModel)

    
    --allow weapon to be fired
    WeaponController.CreateWeaponLogic(self.Player)  --this currently does nothing

    --send information and events to client player
    local args = {}
    args[1] = position
    SetupPlayerInRoom:FireClient(self.Player,args)    
    PlayerBecomingAlive:FireClient(self.Player, PlayerModel)
end


--when a player "dies" from game loop logic
function PlayerController:HiddenDeath()    
    ComputerAppearanceController.DespawnComputer(self.Player)
    WeaponController.CloseWeaponLogic(self.Player)
    PlayerInfo.SetPlayerDying(self.Player)
end


--when a player actually dies from damage (this should happen within a room)
function PlayerController:Die()    
    ComputerAppearanceController.DespawnComputer(self.Player)
    WeaponController.CloseWeaponLogic(self.Player)
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

function PlayerController:GiveWeapon(weaponName)
    table.insert(PlayerInfo.PlayerInformationDictionary[self.Player.Name].StoredWeapons, weaponName)  
    print("bingooooo is given")
    print(PlayerInfo.PlayerInformationDictionary[self.Player.Name].StoredWeapons)

    --(maybe dont leave this in prouction code)
    if not PlayerInfo.PlayerInformationDictionary[self.Player.Name].PrimaryWeapon then
        --equip the weapon
        self:EquipWeapon(weaponName)
    end
end


local function onGivePlayerWeapon(Player, Weapon)
    PlayerController.Computers[Player.Name]:GiveWeapon(Weapon)
end

GivePlayerWeapon.Event:Connect(onGivePlayerWeapon)

function PlayerController:EquipWeapon(weaponName)
    if weaponName == PlayerInfo.PlayerInformationDictionary[self.Player.Name].PrimaryWeapon then
        --the weapon is already equipped, no biggy
        print("weapon already equipped, we chill")
        return
    elseif weaponName == nil then
        error("What")
        return
    elseif PlayerInfo.PlayerInformationDictionary[self.Player.Name].PrimaryWeapon then
        self:DequipPrimaryWeapon()           
    end
    ComputerAppearanceController.AddWeaponToModel(self.Player.Name,weaponName)
    WeaponController.EquipWeapon(self.Player.Name,weaponName)
    PlayerInfo.PlayerInformationDictionary[self.Player.Name].PrimaryWeapon = weaponName
end

function PlayerController:DequipPrimaryWeapon()
    local PrimaryWeaponName = PlayerInfo.PlayerInformationDictionary[self.Player.Name].PrimaryWeapon
    PlayerInfo.PlayerInformationDictionary[self.Player.Name].PrimaryWeapon = nil
    ComputerAppearanceController.RemoveWeaponFromModel(self.Player.Name)
    --table.insert(PlayerInfo.PlayerInformationDictionary[self.Player.Name].StoredWeapons, PrimaryWeaponName)
end


function PlayerController:OfferWeaponsToPlayer(Choices: table)
    WeaponController.OfferWeaponsToPlayer(self.Player,Choices)
end

return PlayerController