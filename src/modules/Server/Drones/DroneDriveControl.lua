--- Controls drones
-- @classmod DroneDriveControl
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local DroneTiltManager = require("DroneTiltManager")
local BaseObject = require("BaseObject")
local Signal = require("Signal")
local Math = require("Math")
local Draw = require("Draw")

local MAX_SPEED = 25
local MAX_ACCEL = 100
local DEACCEL_DIST = 25

local DESIRED_HEIGHT = 16
local HEIGHT_MAX_SPEED = 50
local HEIGHT_MAX_ACCEL = 100
local HEIGHT_DEACCEL_DIST = 25

local DESIRED_SEPARATION = 15
local SEPAR_MAX_SPEED = 50
local SEPER_MAX_ACCEL = 100

local DroneDriveControl = setmetatable({}, BaseObject)
DroneDriveControl.ClassName = "DroneDriveControl"
DroneDriveControl.__index = DroneDriveControl

function DroneDriveControl.new(obj, drone, droneScanner)
	local self = setmetatable(BaseObject.new(obj), DroneDriveControl)

	self._drone = drone or error("No drone")
	self._droneScanner = droneScanner or error("No droneScanner")

	self._vectorForce = self._obj.VectorForce
	self._maid:GiveTask(self._vectorForce)

	self._alignOrientation = self._obj.AlignOrientation
	self._maid:GiveTask(self._alignOrientation)

	self._tiltManager = DroneTiltManager.new(self._obj, self._vectorForce, self._alignOrientation)
	self._maid:GiveTask(self._tiltManager)

	self.ReachedTarget = Signal.new()
	self._maid:GiveTask(self.ReachedTarget)

	self._maid:GiveTask(RunService.Heartbeat:Connect(function()
		self:_applyBehaviors()
		self._tiltManager:Update()
	end))

	return self
end

function DroneDriveControl:SetTargetAttachment(targetAttachment)
	assert((typeof(targetAttachment) == "Instance") or (targetAttachment == nil))
	self._targetAttachment = targetAttachment
end

function DroneDriveControl:_applyBehaviors()
	local mass = self._drone:GetMass()
	local target = self:_getTargetPosition()
	local position = self:_getPosition()
	local velocity = self:_getVelocity()

	-- Discover
	local frontHits = self._droneScanner:ScanInFront(position, velocity, DESIRED_HEIGHT)
	local nearbyDronePositions = self._droneScanner:GetDronePositions()

	-- Calculate acceleration based upon different goals
	local steerAccel = self:_getSteerAcceleration(position, velocity, target, MAX_SPEED, MAX_ACCEL, DEACCEL_DIST)
	local floatAccel = self:_getFloatAcceleration()
	local heightAccel = self:_getHeightAcceleration(position, velocity, frontHits)
	local separateAccel = self:_getSeparateAcceleration(position, velocity, nearbyDronePositions, SEPAR_MAX_SPEED, SEPER_MAX_ACCEL)

	self:_applyForce((steerAccel + floatAccel + heightAccel + separateAccel)*mass)

	-- Detect state
	self:_detectTargetReached(position, velocity, target)
end

--- Attempts to steer towards a target
function DroneDriveControl:_getSteerAcceleration(position, velocity, target, maxSpeed, maxAccel, deaccelDist)
	local desiredVelocity
	if target then
		local offset = target-position
		local dist = offset.magnitude
		local direction = offset.unit

		if dist > deaccelDist then
			desiredVelocity = direction * maxSpeed
		else
			local speed = Math.map(dist, 0, deaccelDist, 0, maxSpeed)
			desiredVelocity = direction * speed
		end
	else
		desiredVelocity = Vector3.new()
	end

	local steer = desiredVelocity - velocity
	if steer.magnitude > maxAccel then
		steer = steer.unit*maxAccel
	end
	return steer
end

--- Attempts to keep drone from running into the ground, and going over obstacles
function DroneDriveControl:_getHeightAcceleration(position, velocity, hits)
	local highestHit = nil
	for _, item in pairs(hits) do
		if (not highestHit) or (item.Position.y > highestHit.y) then
			highestHit = item.Position
		end
	end

	local desiredHeight
	if highestHit then
		desiredHeight = highestHit.y + DESIRED_HEIGHT
	else
		-- Slowly drop
		return Vector3.new(0, -5, 0)
	end

	local target = position + Vector3.new(0, desiredHeight, 0)
	local vertVel = velocity*Vector3.new(0, 1, 0)

	-- Debris:AddItem(Draw.Point(target))

	return self:_getSteerAcceleration(position, vertVel, target, HEIGHT_MAX_SPEED, HEIGHT_MAX_ACCEL, HEIGHT_DEACCEL_DIST)
		* Vector3.new(0, 1, 0)
end

function DroneDriveControl:_getSeparateAcceleration(position, velocity, nearbyDronePositions, maxSpeed, maxAccel)
	if #nearbyDronePositions == 0 then
		return Vector3.new()
	end

	local count = 0
	local sum = Vector3.new()
	for _, pos in pairs(nearbyDronePositions) do
		local offset = position - pos
		local dist = offset.magnitude
		if dist > 0 and dist <= DESIRED_SEPARATION then
			sum = sum + offset/(dist*dist) -- inverse square law
			count = count + 1
		end
	end

	if count <= 0 then
		return Vector3.new()
	end

	local desired = sum.unit * maxSpeed

	local steer = desired - velocity
	if steer.magnitude > maxAccel then
		steer = steer.unit * maxAccel
	end

	return steer
end

function DroneDriveControl:_getFloatAcceleration(mass)
	return Vector3.new(0, Workspace.Gravity, 0)
end

function DroneDriveControl:_detectTargetReached(position, velocity, target)
	if not target then
		return
	end

	if ((target - position) * Vector3.new(1, 0, 1)).magnitude > 9 then
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

function DroneDriveControl:_getPosition()
	return self._obj.Position
end

function DroneDriveControl:_getVelocity()
	return self._obj.Velocity
end

return DroneDriveControl