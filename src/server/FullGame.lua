--this class will hold the functionality for the game loop.

local FullGame = {}
FullGame.__index = FullGame



--CONSTANTS
local AVERAGE_ROOMS_PER_ROUND_SERIES = 3






local ServerScriptStorage = game:GetService("ServerScriptService")
local Server = ServerScriptStorage:WaitForChild("Server")
local PlayerInfo = require(Server:WaitForChild("PlayerInfo"))

local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")






function FullGame.new(players)
    local newGame = {}
    setmetatable(newGame,FullGame)
    


    newGame.Players = players
    newGame.PlayerInfos = {} --dictionary key:player name, value: associated PlayerInfo object



    return newGame
end

function FullGame:Setup()
    --will generate all assets/information
    --setting up playerinfo objects
    for key, value in ipairs(self.Players) do
        local playerInfo = PlayerInfo.new(value)
        self.PlayerInfos[value.Name] = playerInfo
    end
end









function FullGame:StartBossRoom()



end

function FullGame:StartNormalRoom()
    
end


--handles the loop logic for an entire round series
function FullGame:RoundSeries()
    for i = 1, AVERAGE_ROOMS_PER_ROUND_SERIES do  
        print("starting new round")      
        if i == AVERAGE_ROOMS_PER_ROUND_SERIES then
            self:StartBossRoom()
        else
            self:StartNormalRoom()
        end                  
        --by the end of this, the all rooms should've been completed and associated logic completed
    end
end



function FullGame:Start()
    --kicks off the first initial things for the game


    
    while #self.Players > 1 do
        self:RoundSeries()
    end


    self:GameOver()
end



--one player left, and he has won!
function FullGame:GameOver()
    

end
return FullGame