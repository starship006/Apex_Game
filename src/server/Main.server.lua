local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")
local StartGame = Bindables:WaitForChild("StartGame")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FullGame = require(Shared:WaitForChild("FullGame"))


local Players = game:GetService("Players")


local AUTO_START = false
local function onStartGame()
    local NewGame = FullGame.new(Players:GetPlayers())
    NewGame:Setup()
    NewGame:Start()

end

if AUTO_START then
    wait(3)
    onStartGame()
end

StartGame.Event:Connect(onStartGame)