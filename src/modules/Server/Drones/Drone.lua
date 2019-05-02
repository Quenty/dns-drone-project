---
-- @classmod Drone
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Workspace = game:GetService("Workspace")

local BaseObject = require("BaseObject")
local DroneDriveControl = require("DroneDriveControl")

local Drone = setmetatable({}, BaseObject)
Drone.ClassName = "Drone"
Drone.__index = Drone

function Drone.new(obj)
	local self = setmetatable(BaseObject.new(obj), Drone)

	self._driveControl = DroneDriveControl.new(self._obj)
	self._maid:GiveTask(self._driveControl)

	self._driveControl:SetTargetAttachment(Workspace.MainTarget.Attachment)

	return self
end

return Drone