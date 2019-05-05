--- Sphere in which radio comms are jammed
-- @classmod JammingZone
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseObject = require("BaseObject")

local JammingZone = setmetatable({}, BaseObject)
JammingZone.ClassName = "JammingZone"
JammingZone.__index = JammingZone

function JammingZone.new(obj)
	local self = setmetatable(BaseObject.new(obj), JammingZone)

	return self
end

function JammingZone:GetRadius()
	return self._obj.Size.X/2
end

function JammingZone:InZone(point)
	local dist = (point - self:GetPosition()).magnitude
	return dist <= self:GetRadius()
end

function JammingZone:GetPosition()
	return self._obj.Position
end

return JammingZone