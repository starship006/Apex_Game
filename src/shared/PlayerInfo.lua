--holds information on the computer the player has, stats, etc.
--fires necessary info when some of these stats change

local PlayerInfo = {}
PlayerInfo.PlayerInformationDictionary = {}


local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")



function PlayerInfo.SetupNewPlayer(Player)
    local newPlayer = {}
    
    newPlayer.PrimaryWeapon = nil
    newPlayer.StoredWeapons = {} --all the weapons the player holds (as of now, this is what it is. may change)

    newPlayer.Hardware = {}
    newPlayer.Software = {}

    newPlayer.Health = 10    
    newPlayer.Alive = false
    newPlayer.StillInTheGame = true
    newPlayer.ActiveModel = nil

    PlayerInfo.PlayerInformationDictionary[Player.Name] = newPlayer    
end


function PlayerInfo.SetPlayerAlive(player, activeModel)
    PlayerInfo.PlayerInformationDictionary[player.Name].Alive = true
    PlayerInfo.PlayerInformationDictionary[player.Name].ActiveModel = activeModel
    PlayerInfo.PlayerInformationDictionary[player.Name].Health = 10

end

function PlayerInfo.SetPlayerDying(player)
    PlayerInfo.PlayerInformationDictionary[player.Name].Alive = false
    PlayerInfo.PlayerInformationDictionary[player.Name].ActiveModel = nil
end


--'active' meaning computers that are still fighting in a room
function PlayerInfo.ReturnRemaningActivePlayers()
    --print(debug.traceback("Specific moment during ReturnRemainingActivePlayers()"))
    local count = 0
    for playerName, playerInfo in pairs(PlayerInfo.PlayerInformationDictionary)  do
        if playerInfo.Alive == true then
            count += 1
        end
    end
    return count
end

function PlayerInfo.ReturnRemainingInGamePlayers()
    
end

return PlayerInfo