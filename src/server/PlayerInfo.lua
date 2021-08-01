--holds information on the computer the player has, stats, etc.


local PlayerInfo = {}
PlayerInfo.__index = PlayerInfo
function PlayerInfo.new(Player)
    local newPlayer = {}
    setmetatable(newPlayer, PlayerInfo)
    
    



    return newPlayer
end





return PlayerInfo