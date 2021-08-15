local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendPlayerOkToFire: RemoteEvent = Remotes:WaitForChild("SendPlayerOkToFire")
local RequestFireWeapon: RemoteEvent = Remotes:WaitForChild("RequestFireWeapon")




local player = game.Players.LocalPlayer
local mouse: Mouse = player:GetMouse()




local allowedToFireFireEvent = false
SendPlayerOkToFire.OnClientEvent:Connect(function()


    
    if not allowedToFireFireEvent then
        mouse.Button1Down:Connect(function()
            local PlayerModel = workspace:WaitForChild(player.Name)
            local FirePosition = PlayerModel.MainPart.FireSpot.WorldPosition
            --print("client: sending fire")
            RequestFireWeapon:FireServer(mouse.Hit.Position, FirePosition)
        end)
        allowedToFireFireEvent = true
    end
    
end)