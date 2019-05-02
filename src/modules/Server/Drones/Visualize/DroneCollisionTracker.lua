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

	self.Exploded = Signal.new()
	self._maid:GiveTask(self.Exploded)

	self._dronePart = dronePart or error("No dronePart")
	self._maid:GiveTask(self._dronePart.Touched:Connect(function(part)
		if part.CanCollide then
			if self._dronePart.Velocity.magnitude > 10 then
				self.Exploded:Fire()
			end
		end
	end))

	self._maid:GiveTask(function()
		self:_visualizeExplosion()
	end)

	return self
end

function DroneCollisionTracker:_visualizeExplosion()
	local explosion = Instance.new("Explosion")
	explosion.Name = "DroneExplosion"
	explosion.Position = self._dronePart.Position
	explosion.BlastPressure = 10
	explosion.Parent = self._dronePart
end

return DroneCollisionTracker