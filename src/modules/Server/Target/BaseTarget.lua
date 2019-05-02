--- Base target object
-- @classmod BaseTarget
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseObject = require("BaseObject")

local BaseTarget = setmetatable({}, BaseObject)
BaseTarget.ClassName = "BaseTarget"
BaseTarget.__index = BaseTarget

require("IsAMixin"):Add(BaseTarget)

function BaseTarget.new(obj)
	local self = setmetatable(BaseObject.new(obj), BaseTarget)

	self._attachment = self._obj.Attachment

	return self
end

function BaseTarget:GetAttachment()
	return self._attachment
end

return BaseTarget