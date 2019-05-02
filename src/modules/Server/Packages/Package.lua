--- Represents a package to be delivered
-- @classmod Package
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseObject = require("BaseObject")

local Package = setmetatable({}, BaseObject)
Package.ClassName = "Package"
Package.__index = Package

function Package.new(obj)
	local self = setmetatable(BaseObject.new(obj), Package)

	self._attachment = self._obj.Attachment
	self._obj.Anchored = false

	return self
end

function Package:GetAttachment()
	return self._obj.Attachment
end

function Package:SetPosition(position)
	-- Technically should be based off of attachment position but whatever
	self._obj.Position = position
end

return Package