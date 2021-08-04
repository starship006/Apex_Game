--class that will holds information and logic for each room active
--each room object is a direct reference to a room object that is being actively used
--by players. it will hold references to the players and everything


local Room = {}
Room.__index = Room




--script setup
Room.Rooms = {{},{},{}}   --[Room Type][Room Size][Index]   --Normal, Boss, Solo
local ServerStorage = game:GetService("ServerStorage")
local Rooms = ServerStorage:WaitForChild("Rooms")
local Bindables = ServerStorage:WaitForChild("Bindables")
local RoomSetupFinished: BindableEvent = Bindables:WaitForChild("RoomSetupFinished")
local RoomGameplayFinished: BindableEvent = Bindables:WaitForChild("RoomGameplayFinished")


--setup of Room.Rooms table
local rooms = Rooms:GetChildren()

for key, room in ipairs(rooms) do

    --allocating memory for each
    if Room.Rooms[room:GetAttribute("RoomType")]==nil then
        Room.Rooms[room:GetAttribute("RoomType")] = {}
    end
    if Room.Rooms[room:GetAttribute("RoomType")][room:GetAttribute("RoomSize")] == nil then
        Room.Rooms[room:GetAttribute("RoomType")][room:GetAttribute("RoomSize")] = {}
    end

    --putting room in table
    table.insert(Room.Rooms[room:GetAttribute("RoomType")][room:GetAttribute("RoomSize")], room)
end

local function OnPlayerRemoving(player)
    print(player.Name .. " is leaving")
end

function Room.new(newplayers:players,roomType:model)
    local newRoom = {}
    setmetatable(newRoom, Room)

    newRoom.Players = newplayers
    newRoom.Room = nil   --this is the room object that the players will actively fight in
    newRoom.TemplateRoomReference = roomType --this is a stored reference room that we will copy
    newRoom.TrackListeningEvents = {}
    newRoom.Winners = {}
    newRoom.Losers = {}

    table.insert(newRoom.TrackListeningEvents, game.Players.PlayerRemoving:Connect(OnPlayerRemoving))
    return newRoom
end


--picks a random room to play from (should not be used by instances. this is static)
function Room:PickRandomRoom(numPlayers: integer, roomType: integer)
    --[[print(Room.Rooms[roomType])
    print(Room.Rooms[roomType][numPlayers])]]--
    print("roomType" .. roomType)
    print("numPlayers" .. numPlayers)
    local NewRoomType = Room.Rooms[roomType][numPlayers][math.random(#Room.Rooms[roomType][numPlayers])]
    if NewRoomType == nil then
        return error("nil newroomtype")
    else        
        return NewRoomType
    end 
end


--generate room, move players, give players necessary items/choices for the room
function Room:SetupRoomAtLocation(roomNumber:integer)
    --generate room, move in workspace
    self.Room = self.TemplateRoomReference:Clone()
    self.Room.Parent = workspace

    for index, player in ipairs(self.Players) do
        
        player:LoadCharacter()     --TODO: load the player at a spawnpoint
        
    end


    wait(5)
    self.Room:SetAttribute("SetupFinished", true)
    RoomSetupFinished:Fire()
end

function Room:IsSetupFinished()
    return self.Room:GetAttribute("SetupFinished")
end

function Room:IsGameplayFinished()
    return self.Room:GetAttribute("GameplayFinished")
end

--send gui to players indicating start, give players their models, etc.
function Room:InitiateStart()
    --WinLogic is the module within each object that we run to collect the logic for everything
    --local WinLogic = require(self.Room:WaitForChild("WinLogic"))
    for index, player in ipairs(self.Players) do
        player.Character.Humanoid.Died:Connect(function(character)       
            print('player died')     
            --HANDLE PLAYER DEATH CODE HERE
            table.insert(self.Losers,player)
            --WIN CONDITION 1: ALL OTHER PLAYERS DIE
            if #self.Losers == #self.Players - 1 then
                print("starting room finish")
                self:InitiateRoomFinish()
            else
                print("room not finished yet")    
            end
        end)      
        print(index)
    end   

    wait(3)

end


--called when the room gameplay is finished
function Room:InitiateRoomFinish()
    self.Room:SetAttribute("GameplayFinished", true)

    --set winners (if you are not a loser, you are a winner)
    for index, player in ipairs(self.Players) do
        if player.Character then         --as you can see, we will need to make sure that the character dosent respawn until
                                                    --hes supposed to start the next round
            table.insert(self.Winners,player)
        end
    end

    
    RoomGameplayFinished:Fire()
end

--responsible for destroying room object, firing necessary events to clients that the round is over
function Room:Cleanup()
    self.Room:Destroy()
    for index, eventObject in ipairs(self.TrackListeningEvents)  do
        eventObject:Disconnect()
    end
end

function Room:GetWinners()
    return self.Winners
end

function Room:GetLosers()
    return self.Losers
end


return Room