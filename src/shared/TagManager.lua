--responsible for giving scripts to tags as they come into the game
--NOT IN USE RIGHT NOW, BUT MAY BE IN USE LATER


local CollectionService = game:GetService("CollectionService")

local tag = nil

local LocalCameraController = nil

-- Save the connections so they can be disconnected when the tag is removed (not used right now)
local connections = {}

local function onInstanceAdded(object)

end

local function onInstanceRemoved(object)

end

CollectionService:GetInstanceAddedSignal(tag):Connect(onInstanceAdded)

for __, object in pairs(CollectionService:GetTagged(tag)) do
    onInstanceAdded(object)
end