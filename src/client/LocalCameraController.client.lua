--this controller is responsible for moving the camera whenever a new room is loading, as well as moving the camera to other
--locations after death


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SetupPlayerInRoom : RemoteEvent = Remotes:WaitForChild("SetupPlayerInRoom")

local camera = workspace.CurrentCamera
wait()    --for some reason roblox is broken and throws and error if you assign a cameratype too early. so just waiting a thread
camera.CameraType = Enum.CameraType.Scriptable

local player = game.Players.LocalPlayer

local CAMERA_OFFSET = Vector3.new(-1,60,0)



--whenever a new room is starting, move the camera to there
local function onSetupPlayerInRoom(args)
    local roomPosition = args[1]

    --camera needs to be offset from the room position + looking at the room position
    camera.CFrame = CFrame.new(roomPosition + CAMERA_OFFSET, roomPosition)


end

SetupPlayerInRoom.OnClientEvent:Connect(onSetupPlayerInRoom)