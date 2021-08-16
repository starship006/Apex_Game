--handles the movement of the computer


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayerBecomingAlive: RemoteEvent = Remotes:WaitForChild("PlayerBecomingAlive")
local PlayerDied: RemoteEvent = Remotes:WaitForChild("PlayerDied")

local PlayerModel = nil
local LocalGravity = 0
--local direction = Vector3.new(0,-LocalGravity,0)
local multiplier = 40

local ContextActionService = game:GetService("ContextActionService")

local FORWARD_ACTION = "Forward"
local BACKWARD_ACTION = "Backward"
local LEFT_ACTION = "Left"
local RIGHT_ACTION = "Right"

local RunService = game:GetService("RunService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()


local UserInputService = game:GetService("UserInputService")

local MouseLookEventConnection = nil

local function SimpleMovement(actionName, inputState, inputObject)
    --[[local reverse
    if inputState == Enum.UserInputState.Begin then
        reverse = 1
    else
        reverse = -1    
    end
      --right now x is upwards, z is leftright
    if actionName == FORWARD_ACTION then
        direction += Vector3.new(1* reverse,0,0) 
    elseif actionName == BACKWARD_ACTION then
        direction += Vector3.new(-1* reverse,0,0) 
    elseif actionName == LEFT_ACTION then
        direction += Vector3.new(0,0,-1* reverse) 
    elseif actionName == RIGHT_ACTION then
        direction += Vector3.new(0,0,1* reverse) 
    end]]--

    local direction = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction += Vector3.new(1,0,0) 
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction += Vector3.new(0,0,1) 
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction += Vector3.new(0,0,-1) 
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction += Vector3.new(-1,0,0) 
    end





    PlayerModel.BasePart.BodyVelocity.Velocity = direction * multiplier
end


local function MakeComputerFaceMouse()
    local Position = PlayerModel.BasePart.Position
    local LookPosition = Vector3.new(mouse.Hit.X, Position.Y, mouse.Hit.Z)

    PlayerModel.BasePart.CFrame = CFrame.new(Position,LookPosition)
end 

PlayerBecomingAlive.OnClientEvent:Connect(function(activeModel)
    ContextActionService:BindAction(FORWARD_ACTION,SimpleMovement,false,Enum.KeyCode.W)
    ContextActionService:BindAction(LEFT_ACTION,SimpleMovement,false,Enum.KeyCode.A)
    ContextActionService:BindAction(RIGHT_ACTION,SimpleMovement,false,Enum.KeyCode.D)
    ContextActionService:BindAction(BACKWARD_ACTION,SimpleMovement,false,Enum.KeyCode.S)


    --set up the new character movement
    PlayerModel = activeModel
    PlayerModel.BasePart.BodyVelocity.Velocity = Vector3.new(0,0,0)
    
    MouseLookEventConnection = RunService.Heartbeat:Connect(MakeComputerFaceMouse)
end)

PlayerDied.OnClientEvent:Connect(function()
    ContextActionService:UnbindAllActions()
    MouseLookEventConnection:Disconnect()
    PlayerModel = nil    
end)


local sent = false
function onAcceptPlayerWeaponRequest()
    if not sent then
        game.ReplicatedStorage.Remotes.ReturnOfferWeaponChoices:FireServer(1)
        sent = true
    end
end
ContextActionService:BindAction("AcceptPlayerWeaponRequest",onAcceptPlayerWeaponRequest, false, Enum.KeyCode.H)