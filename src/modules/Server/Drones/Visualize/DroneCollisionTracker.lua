--- Tracks collisions on drones
-- @classmod DroneCollisionTracker
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseObject = require("BaseObject")
local Signal = require("Signal")
local DroneCollisionTracker = setmetatable({}, BaseObject)
DroneCollisionTracker.ClassName = "DroneCollisionTracker"
DroneCollisionTracker.__index = DroneCollisionTracker

function DroneCollisionTracker.new(dronePart)
	local self = setmetatable(BaseObject.new(), DroneCollisionTracker)

	self._dronePart = dronePart or error("No dronePart")

	self.Exploded = Signal.new()
	self._maid:GiveTask(self.Exploded)

	self._maid:GiveTask(self._dronePart.Touched:Connect(function(...)
		self:_handleTouch(...)
	end))

	self._maid:GiveTask(function()
		self:_visualizeExplosion()
	end)

	return self
end

function DroneCollisionTracker:_handleTouch(part)
	if part:IsDescendantOf(self._dronePart) then
		return
	end

	if not part.CanCollide then
		return
	end
	if (self._dronePart.Velocity - part.Velocity).magnitude > 10 then
		print(self._dronePart.Name, "Died hitting", part:GetFullName(), (self._dronePart.Velocity - part.Velocity).magnitude)
		self.Exploded:Fire()
	end
end

function DroneCollisionTracker:_visualizeExplosion()
	local explosion = Instance.new("Explosion")
	explosion.Name = "DroneExplosion"
	explosion.Position = self._dronePart.Position
	explosion.BlastPressure = 10
	explosion.Parent = self._dronePart
end

return DroneCollisionTracker