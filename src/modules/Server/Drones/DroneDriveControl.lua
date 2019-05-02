--- Controls drones
-- @classmod DroneDriveControl
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local BaseObject = require("BaseObject")
local Signal = require("Signal")
local Math = require("Math")
local Draw = require("Draw")

local MAX_ACCELERATION = 100
local DEACCELERATION_DISTANCE = 25
local MAX_SPEED = 50

local DroneDriveControl = setmetatable({}, BaseObject)
DroneDriveControl.ClassName = "DroneDriveControl"
DroneDriveControl.__index = DroneDriveControl

function DroneDriveControl.new(obj)
	local self = setmetatable(BaseObject.new(obj), DroneDriveControl)

	self._vectorForce = self._obj.VectorForce
	self._target = nil

	self.ReachedTarget = Signal.new()
	self._maid:GiveTask(self.ReachedTarget)

	self._maid:GiveTask(RunService.Heartbeat:Connect(function()
		self:_applyBehaviors()
	end))

	return self
end

function DroneDriveControl:SetTargetAttachment(targetAttachment)
	assert(typeof(targetAttachment) == "Instance")
	self._targetAttachment = targetAttachment
end

function DroneDriveControl:_applyBehaviors()
	local mass = self:_getMass()
	local target = self:_getTargetPosition()
	local position = self:_getPosition()
	local velocity = self:_getVelocity()

	-- Calculate force
	local steerForce = self:_getSteerAcceleration(position, velocity, target)*mass
	local floatForce = self:_getFloatForce(mass)

	self:_applyForce(steerForce + floatForce)

	-- Detect state
	self:_detectTargetReached(position, velocity, target)
end

function DroneDriveControl:_getSteerAcceleration(position, velocity, target)
	if not target then
		return Vector3.new()
	end

	local offset = target-position
	local dist = offset.magnitude
	local direction = offset.unit

	local desiredVelocity
	if dist > DEACCELERATION_DISTANCE then
		desiredVelocity = direction * MAX_SPEED
	else
		local speed = Math.map(dist, 0, DEACCELERATION_DISTANCE, 0, MAX_SPEED)
		desiredVelocity = direction * speed
	end

	local steer = desiredVelocity - velocity
	if steer.magnitude > MAX_ACCELERATION then
		steer = steer.unit*MAX_ACCELERATION
	end
	return steer
end

function DroneDriveControl:_getFloatForce(mass)
	local floatForce = Vector3.new(0, Workspace.Gravity * mass, 0)
	return floatForce
end

function DroneDriveControl:_detectTargetReached(position, velocity, target)
	if not target then
		return
	end

	if (target - position).magnitude > 5 then
		return
	end

	if velocity.magnitude > 5 then
		return
	end

	self.ReachedTarget:Fire()
end

function DroneDriveControl:_applyForce(force)
	self._vectorForce.Force = force
end

function DroneDriveControl:_getTargetPosition()
	if not self._targetAttachment then
		return nil
	end

	return self._targetAttachment.WorldPosition
end

function DroneDriveControl:_getMass()
	return self._obj:GetMass()
end

function DroneDriveControl:_getPosition()
	return self._obj.Position
end

function DroneDriveControl:_getVelocity()
	return self._obj.Velocity
end

return DroneDriveControl