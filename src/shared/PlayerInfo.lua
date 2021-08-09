--holds information on the computer the player has, stats, etc.
--fires necessary info when some of these stats change

local PlayerInfo = {}
PlayerInfo.PlayerInformationDictionary = {}


local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local PlayerBecomingAlive: RemoteEvent = Remotes:WaitForChild("PlayerBecomingAlive")
local PlayerDied = Remotes:WaitForChild("PlayerDied")



function PlayerInfo.SetupNewPlayer(Player)
    local newPlayer = {}
    
    newPlayer.PrimaryWeapon = nil
    newPlayer.StoredWeapons = {}

    newPlayer.Hardware = {}
    newPlayer.Software = {}

    newPlayer.Health = 10    
    newPlayer.Alive = false
    newPlayer.StillInTheGame = true

    PlayerInfo.PlayerInformationDictionary[Player.Name] = newPlayer    
end


function PlayerInfo.SetPlayerAlive(player)
    PlayerInfo.PlayerInformationDictionary[player.Name].Alive = true
    PlayerBecomingAlive:FireClient(player)
end

function PlayerInfo.SetPlayerDying(player)
    PlayerInfo.PlayerInformationDictionary[player.Name].Alive = false
    PlayerDied:FireClient(player)
end



return PlayerInfo