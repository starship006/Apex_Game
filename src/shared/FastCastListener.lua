--script that is designed to listen to shots fired from clients
local FastCastListener = {}





--temp variables
local velocity = 100



--internal modules/dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestFireWeapon = Remotes:WaitForChild("RequestFireWeapon")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ComputerAppearanceController = require(Shared:WaitForChild("ComputerAppearanceController"))
local DamageHandler = require(Shared:WaitForChild("DamageHandler"))


local Modules = ReplicatedStorage:WaitForChild("Modules")
local FastCastRedux = require(Modules:WaitForChild("FastCastRedux"))
local PartCacheModule = require(Modules:WaitForChild("PartCache"))

--internal folders
FastCastListener.CanPlayerFire = {} --[name][bool], will need to be forced as false when player is dead
FastCastListener.FireDelay = {} --[name][num]
FastCastListener.PlayerBullet = {} --[name][model]

FastCastListener.CastBehaviors = {} --[name][caster]
FastCastListener.Casters = {} --[name][caster]




--called in the room object

function FastCastListener.RoundOver()
    for playerName, boolean in pairs(FastCastListener.CanPlayerFire) do
        FastCastListener.CanPlayerFire[playerName] = false
    end
end

--called in the room object
function FastCastListener.RoundStarting()
    print("round start code for fastcastlistener running")
    for playerName, boolean in pairs(FastCastListener.CanPlayerFire) do
        FastCastListener.CanPlayerFire[playerName] = true
    end
end


--this should only be called ONCE optimally. this is just to make tables not freak out with nil calls and stuff
function FastCastListener.SetupPlayer(playerName)
    FastCastListener.CanPlayerFire[playerName] = false
    FastCastListener.FireDelay[playerName] = 0.01
    FastCastListener.Casters[playerName] = nil
    
end

function FastCastListener.SetPlayerWeaponInformation(playerName, fireDelay, bullet)

    --folder stuff
    FastCastListener.FireDelay[playerName] = fireDelay
    FastCastListener.PlayerBullet[playerName] = bullet:Clone()  

    --remove cast events if they are there
    if FastCastListener.Casters[playerName] then
        --[[
        local Caster = FastCastListener.Casters[playerName]
        Caster.RayHit:Disconnect()
        Caster.RayPierced:Disconnect()
        Caster.LengthChanged:Disconnect()
        Caster.CastTerminating:Disconnect()]]--
        FastCastListener.Casters[playerName] = nil --this might be the easiest way to destroy stuff
    end

    --create cast object
    local Caster = FastCastRedux.new()

    local CastParams = RaycastParams.new()
    CastParams.IgnoreWater = true
    CastParams.FilterType = Enum.RaycastFilterType.Blacklist
    CastParams.FilterDescendantsInstances = {workspace.Baseplate}

    local CosmeticBulletsFolder = Instance.new("Folder")
    CosmeticBulletsFolder.Name = playerName .." CosmeticBulletsFolder"
    CosmeticBulletsFolder.Parent = workspace

    local CosmeticBulletProvider = PartCacheModule.new(FastCastListener.PlayerBullet[playerName], 20, CosmeticBulletsFolder)

    local CastBehavior = FastCastRedux.newBehavior()
    CastBehavior.RaycastParams = CastParams
    CastBehavior.MaxDistance = 200
    CastBehavior.HighFidelityBehavior = FastCastRedux.HighFidelityBehavior.Default -- maybe this will need to change

    CastBehavior.CosmeticBulletProvider = CosmeticBulletProvider

    CastBehavior.CosmeticBulletContainer = CosmeticBulletsFolder
    CastBehavior.Acceleration = Vector3.new(0,0,0)
    CastBehavior.AutoIgnoreContainer = false -- maybe this will need to change

    Caster.RayHit:Connect(FastCastListener.__OnRayHit)
    Caster.RayPierced:Connect(FastCastListener.__OnRayPierced)
    Caster.LengthChanged:Connect(FastCastListener.__OnRayUpdated)
    Caster.CastTerminating:Connect(FastCastListener.__OnRayTerminated)

    
    FastCastListener.CastBehaviors[playerName] = CastBehavior
    FastCastListener.Casters[playerName] = Caster

    print("setup fastcastlistener information with the following fastcastlistener info:")
    print(FastCastListener)
end




function FastCastListener.__Fire(playerName, firePoint, bulletDirection)
    --can add in here variable bullet velocity depending on the speed of the computer. 
    local modifiedBulletSpeed = (bulletDirection * velocity)  --TODO: ADD BULLET DIRECTIONS


    local simBullet = FastCastListener.Casters[playerName]:Fire(firePoint,bulletDirection,modifiedBulletSpeed, FastCastListener.CastBehaviors[playerName])
    simBullet.UserData.PlayerName = playerName
    --will need to add in how much danage will be done here

end



RequestFireWeapon.OnServerEvent:Connect(function(clientThatFired, mousePoint, firePoint)
    --print("server: recieved fire request")
    if FastCastListener.CanPlayerFire[clientThatFired.Name] then
        FastCastListener.CanPlayerFire[clientThatFired.Name] = false
        --print("firing!!!!!")
        --local FirePoint = ComputerAppearanceController.GetComputerFirePoint(clientThatFired.Name)
        mousePoint = Vector3.new(mousePoint.X,firePoint.Y, mousePoint.Z)
        local mouseDirection = (mousePoint - firePoint).Unit
        FastCastListener.__Fire(clientThatFired.Name,firePoint,mouseDirection)
        spawn(function()
            wait(FastCastListener.FireDelay[clientThatFired.Name])
            FastCastListener.CanPlayerFire[clientThatFired.Name] = true
        end)
    end

    return 
end)




--event handling code
function FastCastListener.__CanRayPierce(cast, rayResult, segmentVelocity)
    local hits = cast.UserData.Hits
	if hits == nil then
		-- If the hit data isn't registered, set it to 1 (because this is our first hit)
		cast.UserData.Hits = 1
	else
		-- If the hit data is registered, add 1.
		cast.UserData.Hits += 1
	end
	
	-- And if the hit count is over 3, don't allow piercing and instead stop the ray.
	if cast.UserData.Hits > 3 then
		return false  --no, dont reflect
	end

    --add code here for dealing damage to whatever can take damage

    local PartHit = rayResult.Instance
    if DamageHandler.SeeIfPartTakesDamage(PartHit) then
        DamageHandler.DealDamageToPart(5,PartHit)
        return false
    end

    return true --yes, reflect

end



function FastCastListener.__OnRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
    local hitPart = raycastResult.Instance
	local hitPoint = raycastResult.Position
	local normal = raycastResult.Normal

    --once again, add the damage logic here
    --print("PartHit!!!")
    local PartHit = raycastResult.Instance
    if DamageHandler.SeeIfPartTakesDamage(PartHit) then
        --print("part does take damage!")
        DamageHandler.DealDamageToPart(5,PartHit)
        return false
    end
    --also MakeParticleFX() could be called here
end

local function Reflect(surfaceNormal, bulletNormal)
	return bulletNormal - (2 * bulletNormal:Dot(surfaceNormal) * surfaceNormal)
end

function FastCastListener.__OnRayPierced(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
    local position = raycastResult.Position
    local normal = raycastResult.Normal

    local newNormal = Reflect(normal, segmentVelocity.Unit)
    cast:SetVelocity(newNormal * segmentVelocity.Magnitude)
    cast:SetPosition(position)

    --if we do velocity modifiying stuff, look here at what to do
end

function FastCastListener.__OnRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
    -- Whenever the caster steps forward by one unit, this function is called.
	-- The bullet argument is the same object passed into the fire function.
	if cosmeticBulletObject == nil then
        print("YOOOOOOOOOOOOOOOOOOOOOOOOOOO HOLD ON CHECK THIS OUT BRUH WHATS THIS")
        return 
    end
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end


function FastCastListener.__OnRayTerminated(cast)
    local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
	if cosmeticBullet ~= nil then
		-- This code here *was* using an if statement on CastBehavior.CosmeticBulletProvider so that the example gun works out of the box.
		-- In your implementation, you should only handle what you're doing (if you use a PartCache, ALWAYS use ReturnPart. If not, ALWAYS use Destroy.
		FastCastListener.CastBehaviors[cast.UserData.PlayerName].CosmeticBulletProvider:ReturnPart(cosmeticBullet)
	else
        print("YOOOOOOOOOOOOOOOOOOOOOOOOOOO HOLD ON CHECK THIS OUT BRUH WHATS THIS")
    end
end
return FastCastListener