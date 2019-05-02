--- The actual drone object
-- @classmod Drone
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseObject = require("BaseObject")
local DroneCollisionTracker = require("DroneCollisionTracker")
local DroneDriveControl = require("DroneDriveControl")
local DroneGoalManager = require("DroneGoalManager")
local DronePackageHolder = require("DronePackageHolder")
local DroneScanner = require("DroneScanner")
local ServerBinders = require("ServerBinders")

local Drone = setmetatable({}, BaseObject)
Drone.ClassName = "Drone"
Drone.__index = Drone

function Drone.new(obj)
	local self = setmetatable(BaseObject.new(obj), Drone)

	self._originalColor = self._obj.BrickColor
	self._scanner = DroneScanner.new(self)

	self._driveControl = DroneDriveControl.new(self._obj, self._scanner)
	self._maid:GiveTask(self._driveControl)

	self._packageHolder = DronePackageHolder.new(self._obj)
	self._maid:GiveTask(self._packageHolder)

	self._droneGoalManager = DroneGoalManager.new(self, self._driveControl)
	self._maid:GiveTask(self._droneGoalManager)

	self._collisionTracker = DroneCollisionTracker.new(self._obj)
	self._maid:GiveTask(self._collisionTracker)

	self._collisionTracker.Exploded:Connect(function()
		self:SetBrickColor(BrickColor.new("Bright red"))
		ServerBinders.Drone:Unbind(self._obj)
	end)

	self._obj.Anchored = false

	return self
end

function Drone:GetPackageHolder()
	return self._packageHolder
end

function Drone:GetPart()
	return self._obj
end

function Drone:SetBrickColor(color)
	if color then
		self._obj.BrickColor = color
	else
		self._obj.BrickColor = self._originalColor
	end
end

function Drone:GetPosition()
	return self._obj.Position
end

return Drone