--- Drone goal management goal setting
-- @classmod DroneGoalManager
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseObject = require("BaseObject")
local ServerBinders = require("ServerBinders")

local DroneGoalManager = setmetatable({}, BaseObject)
DroneGoalManager.ClassName = "DroneGoalManager"
DroneGoalManager.__index = DroneGoalManager

function DroneGoalManager.new(drone, driveControl)
	local self = setmetatable(BaseObject.new(), DroneGoalManager)

	self._drone = drone or error("No drone")
	self._packageHolder = self._drone:GetPackageHolder() or error("No packageHolder")
	self._driveControl = driveControl or error("No driveControl")

	self._alive = true
	self._maid:GiveTask(function()
		self._alive = false
	end)

	spawn(function()
		while self._alive do
			local target = self:_getNewTarget()
			if target then
				self:_driveToTarget(target)
				target:HandleTargetReached(self._drone)
			else
				warn("[DroneGoalManager] - No targets available")
			end

			if self._alive then
				self._drone:SetBrickColor(BrickColor.new("Bright green"))
			end
			wait(1)
			if self._alive then
				self._drone:SetBrickColor(nil)
			end
		end
	end)

	return self
end

function DroneGoalManager:_driveToTarget(target)
	self._driveControl:SetTargetAttachment(target:GetAttachment())
	self._driveControl.ReachedTarget:Wait()
	self._driveControl:SetTargetAttachment(nil)
end

function DroneGoalManager:_getNewTarget()
	local targets

	-- Use global knowledge for now
	if not self._packageHolder:HasPackage() then
		targets = ServerBinders.PickUpTarget:GetAll()
	else
		targets = ServerBinders.DeliveryTarget:GetAll()
	end

	if #targets == 0 then
		return nil
	elseif #targets == 1 then
		return targets[1]
	end

	return targets[math.random(1, #targets)]
end

return DroneGoalManager