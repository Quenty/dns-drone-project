--- The actual drone object
-- @classmod Drone
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local DroneScanner = require("DroneScanner")
local BaseObject = require("BaseObject")
local DroneDriveControl = require("DroneDriveControl")
local DroneGoalManager = require("DroneGoalManager")

local Drone = setmetatable({}, BaseObject)
Drone.ClassName = "Drone"
Drone.__index = Drone

function Drone.new(obj)
	local self = setmetatable(BaseObject.new(obj), Drone)

	self._scanner = DroneScanner.new(self._obj)

	self._driveControl = DroneDriveControl.new(self._obj, self._scanner)
	self._maid:GiveTask(self._driveControl)

	self._droneGoalManager = DroneGoalManager.new(self._driveControl)
	self._maid:GiveTask(self._driveControl)

	return self
end

return Drone