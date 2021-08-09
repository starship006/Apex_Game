--handles the movement of the computer


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayerBecomingAlive: RemoteEvent = Remotes:WaitForChild("PlayerBecomingAlive")
local PlayerDied: RemoteEvent = Remotes:WaitForChild("PlayerDied")

local PlayerModel = nil
local direction = Vector3.new(0,0,0)
local multiplier = 40

local ContextActionService = game:GetService("ContextActionService")

local FORWARD_ACTION = "Forward"
local BACKWARD_ACTION = "Backward"
local LEFT_ACTION = "Left"
local RIGHT_ACTION = "Right"


local function SimpleMovement(actionName, inputState, inputObject)
    local reverse
    if inputState == Enum.UserInputState.Begin then
        reverse = 1
    else
        reverse = -1    
    end
      --right now x is upwards, z is leftright
    if actionName == FORWARD_ACTION then
        direction += Vector3.new(1,0,0) * reverse
    elseif actionName == BACKWARD_ACTION then
        direction += Vector3.new(-1,0,0) * reverse
    elseif actionName == LEFT_ACTION then
        direction += Vector3.new(0,0,-1) * reverse
    elseif actionName == RIGHT_ACTION then
        direction += Vector3.new(0,0,1) * reverse
    end

    PlayerModel.BasePart.BodyVelocity.Velocity = direction * multiplier
end

PlayerBecomingAlive.OnClientEvent:Connect(function(activeModel)
    ContextActionService:BindAction(FORWARD_ACTION,SimpleMovement,false,Enum.KeyCode.W)
    ContextActionService:BindAction(LEFT_ACTION,SimpleMovement,false,Enum.KeyCode.A)
    ContextActionService:BindAction(RIGHT_ACTION,SimpleMovement,false,Enum.KeyCode.D)
    ContextActionService:BindAction(BACKWARD_ACTION,SimpleMovement,false,Enum.KeyCode.S)


    --set up the new character movement
    PlayerModel = activeModel
    PlayerModel.BasePart.BodyVelocity.Velocity = direction * 0
    

end)


