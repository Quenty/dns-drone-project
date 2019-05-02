--- Handles holding packages
-- @classmod DronePackageHolder
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Workspace = game:GetService("Workspace")

local BaseObject = require("BaseObject")
local BinderUtil = require("BinderUtil")
local ServerBinders = require("ServerBinders")

local DronePackageHolder = setmetatable({}, BaseObject)
DronePackageHolder.ClassName = "DronePackageHolder"
DronePackageHolder.__index = DronePackageHolder

function DronePackageHolder.new(obj)
	local self = setmetatable(BaseObject.new(obj), DronePackageHolder)

	self._ropeConstraint = self._obj.RopeConstraint

	return self
end

function DronePackageHolder:GetMass()
	local package = self:GetPackage()
	if package then
		return package:GetMass()
	end

	return 0
end

function DronePackageHolder:SetPackage(package)
	local currentPackage = self:GetPackage()
	if currentPackage then
		currentPackage:SetParent(Workspace)
	end

	if package then
		local attachment0 = self._ropeConstraint.Attachment0
		local position = attachment0.WorldPosition - Vector3.new(0, self._ropeConstraint.Length, 0)
		self._ropeConstraint.Attachment1 = package:GetAttachment()
		package:SetParent(self._obj)
		package:SetPosition(position)
	else
		self._ropeConstraint.Attachment1 = nil
	end
end

function DronePackageHolder:DropPackage()
	self:SetPackage(nil)
end

function DronePackageHolder:HasPackage()
	return self:GetPackage() ~= nil
end

function DronePackageHolder:GetPackage()
	local part = self._ropeConstraint.Attachment1
	if part then
		return BinderUtil.findFirstAncestor(ServerBinders.Package, part)
	end

	return nil
end

return DronePackageHolder