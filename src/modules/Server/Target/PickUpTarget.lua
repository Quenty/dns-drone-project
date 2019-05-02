---
-- @classmod PickUpTarget
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseTarget = require("BaseTarget")

local PickUpTarget = setmetatable({}, BaseTarget)
PickUpTarget.ClassName = "PickUpTarget"
PickUpTarget.__index = PickUpTarget

function PickUpTarget.new(obj)
	local self = setmetatable(BaseTarget.new(obj), PickUpTarget)

	return self
end

return PickUpTarget