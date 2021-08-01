local ServerStorage = game:GetService("ServerStorage")
local Bindables = ServerStorage:WaitForChild("Bindables")
local StartGame = Bindables:WaitForChild("StartGame")


local ServerScriptStorage = game:GetService("ServerScriptService")
local Server = ServerScriptStorage:WaitForChild("Server")
local GameModule = require(Server:WaitForChild("FullGame"))

local Players = game:GetService("Players")

local function onStartGame()
    local NewGame = GameModule.new(Players:GetPlayers())
    NewGame:Setup()
    NewGame:Start()

end

StartGame.Event:Connect(onStartGame)