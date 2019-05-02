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

local MAX_ACCELERATION = 10000
local DEACCELERATION_DISTANCE = 50
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
		self:_updateSteerForce()
		self:_detectTargetReached()
	end))

	return self
end

function DroneDriveControl:SetTargetAttachment(targetAttachment)
	assert(typeof(targetAttachment) == "Instance")
	self._targetAttachment = targetAttachment
end

function DroneDriveControl:_updateSteerForce()
	local target = self:_getTargetPosition()
	if not target then
		self:_setSteerForce(Vector3.new())
		return
	end

	local position = self:_getPosition()
	local velocity = self:_getVelocity()
	local maxForce = self:_getMaxForce()
	local desired = target-position
	local dist = desired.magnitude
	print(velocity.magnitude)

	if dist > DEACCELERATION_DISTANCE then
		desired = desired.unit * MAX_SPEED
	else
		local speed = Math.map(dist, 0, DEACCELERATION_DISTANCE, 0, MAX_SPEED)
		desired = desired.unit * speed
	end

	local steer = desired - velocity
	if steer.magnitude > maxForce then
		steer = steer.unit*maxForce
	end
	self:_setSteerForce(steer)
end

function DroneDriveControl:_detectTargetReached()
	local target = self:_getTargetPosition()
	if not target then
		return
	end

	local position = self:_getPosition()
	if (target - position).magnitude > 5 then
		return
	end

	local velocity = self:_getVelocity()
	if velocity.magnitude > 5 then
		return
	end

	self.ReachedTarget:Fire()
end


function DroneDriveControl:_setSteerForce(force)
	local mass = self:_getMass()
	local floatForce = Vector3.new(0, Workspace.Gravity * mass, 0)

	self._vectorForce.Force = force + floatForce
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

function DroneDriveControl:_getMaxForce()
	return self:_getMass() * MAX_ACCELERATION
end

return DroneDriveControl