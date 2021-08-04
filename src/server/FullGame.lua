--this class will hold the functionality for the game loop.

local FullGame = {}
FullGame.__index = FullGame



--CONSTANTS
local AVERAGE_ROOMS_PER_ROUND_SERIES = 3





--SERVIES AND MODULES
local ServerScriptStorage = game:GetService("ServerScriptService")
local Server = ServerScriptStorage:WaitForChild("Server")
local PlayerInfo = require(Server:WaitForChild("PlayerInfo"))
local Room = require(Server:WaitForChild("Room"))

local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")
local RoomSetupFinished: BindableEvent = Bindables:WaitForChild("RoomSetupFinished")
local RoomGameplayFinished: BindableEvent = Bindables:WaitForChild("RoomGameplayFinished")






function FullGame.new(players)
    local newGame = {}
    setmetatable(newGame,FullGame)
    


    newGame.Players = players
    newGame.PlayerInfos = {} --dictionary key:player name, player: associated PlayerInfo object
    newGame.CurrentActiveRooms = {}  --array of active rooms



    return newGame
end

function FullGame:Setup()
    --will generate all assets/information
    --setting up playerinfo objects
    game.Players.CharacterAutoLoads = false

    for key, player in ipairs(self.Players) do
        
        --playerInfo stuff
        local playerInfo = PlayerInfo.new(player)
        self.PlayerInfos[player.Name] = playerInfo
    end
end











function FullGame:StartRoom(RoomType)
    --right now we are just stuffing everyone in a room
    local RoomToUse = Room:PickRandomRoom(#self.Players,RoomType)   


    --creating all the rooms
    local NewRoom: Room = Room.new(self.Players,RoomToUse)
    table.insert(self.CurrentActiveRooms,NewRoom)

    --throw rooms to tables for future reference
    --this is in spawn to allow for the following code to wait
    
    for index, RoomObject in ipairs(self.CurrentActiveRooms) do
        RoomObject:SetupRoomAtLocation(index)       
    end
    
    
    
    


    --wait until all rooms setup (is this even necessary? i dont know man)
    --[[while true do
        RoomSetupFinished.Event:Wait()

        --checking to see if all the rooms are setup
        local ThereIsARoomNotFinishedSettingUp = false
        for index, RoomObject in ipairs(self.CurrentActiveRooms) do
            if not RoomObject:IsSetupFinished() then
                ThereIsARoomNotFinishedSettingUp = true
            end       
    
        end
        if not ThereIsARoomNotFinishedSettingUp then
            break
        end

        --if so, then the loop repeats, continually waiting on everything to be setup
    end]]--
    print("all rooms setup, starting gameplay")

    --start play
    spawn(function()
        for index, RoomObject in ipairs(self.CurrentActiveRooms) do
            RoomObject:InitiateStart() 
    
        end
    end)


    --wait until all rooms are finished with gameplay
    while true do
       RoomGameplayFinished.Event:Wait() 
        --checking to see if all the rooms are finished
        local ThereIsARoomNotFinishedPlaying = false
        for index, RoomObject in ipairs(self.CurrentActiveRooms) do
            if not RoomObject:IsGameplayFinished() then
                ThereIsARoomNotFinishedPlaying = true
            end       
    
        end
        if not ThereIsARoomNotFinishedPlaying then
             break
        end
    end
    print("all rooms finished with gampelay, cleaning up")

    --any post-round cleanup code for all the rooms can go here 
    local winners = {}
    local losers = {}
    for index, RoomObject in ipairs(self.CurrentActiveRooms) do

        for index2, winner in ipairs(RoomObject:GetWinners()) do
            table.insert(winners,winner)
        end
        
        for index2, loser in ipairs(RoomObject:GetLosers()) do
            table.insert(winners,loser)
        end
        
        RoomObject:Cleanup()
    end
    print(winners)
    table.clear(self.CurrentActiveRooms)
end


--handles the loop logic for an entire round series
function FullGame:RoundSeries()
    for i = 1, AVERAGE_ROOMS_PER_ROUND_SERIES do  
        print("starting new round")      
        if i == AVERAGE_ROOMS_PER_ROUND_SERIES then
            --boss room
            self:StartRoom(2)

        else
            --normal room
            self:StartRoom(1)
        end                  
        --by the end of this, the all rooms should've been completed and associated logic completed
    end
end



function FullGame:Start()
    --kicks off the first initial things for the game


    --start a round series if there are enough ppl
    while #self.Players > 0 do
        self:RoundSeries()
    end


    self:GameOver()
end



--one player left, and he has won!
function FullGame:GameOver()
    

end
return FullGame