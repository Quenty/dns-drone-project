--- Handles holding packages
-- @classmod DronePackageHolder
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseObject = require("BaseObject")

local DronePackageHolder = setmetatable({}, BaseObject)
DronePackageHolder.ClassName = "DronePackageHolder"
DronePackageHolder.__index = DronePackageHolder

function DronePackageHolder.new(obj)
	local self = setmetatable(BaseObject.new(obj), DronePackageHolder)

	self._ropeConstraint = self._obj.RopeConstraint

	return self
end

function DronePackageHolder:SetPackage(package)
	if package then
		local attachment0 = self._ropeConstraint.Attachment0
		local position = attachment0.WorldPosition - Vector3.new(0, self._ropeConstraint.Length, 0)
		self._ropeConstraint.Attachment1 = package:GetAttachment()
		package:SetPosition(position)
	else
		self._ropeConstraint.Attachment1 = nil
	end
end

function DronePackageHolder:DropPackage()
	self:SetPackage(nil)
end

function DronePackageHolder:HasPackage()
	return self._ropeConstraint.Attachment1
end

return DronePackageHolder