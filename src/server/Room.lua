--class that will holds information and logic for each room active
--each room object is a direct reference to a room object that is being actively used
--by players. it will hold references to the players and everything

local Room = {}
Room.__index = Room



Room.Rooms = {}   --[Room Type][Room Size][Index]   --Normal, Boss, Solo
local ServerStorage = game:GetService("ServerStorage")
local Rooms = ServerStorage:WaitForChild("Rooms")
--setup of Room.Rooms table
local rooms = Rooms:GetChildren()

for key, room in ipairs(rooms) do
    table.insert(Room.Rooms[room:GetAttribute("RoomType")][room:GetAttribute("RoomSize")], room)
end


function Room.new(players,roomType)
    local newRoom = {}
    setmetatable(newRoom, Room)

    newRoom.Players = players
    newRoom.Room = nil   --this is the room object that will be copied over and over again (assigned in PickRoom)
    newRoom:PickRoom(roomType)



    return newRoom
end


--picks a random room to play from
function Room:PickRoom(roomType)
    self.Room = Room.Rooms[roomType][#self.Players][math.random(#Room.Rooms[roomType][#self.Players])]
end


return Room