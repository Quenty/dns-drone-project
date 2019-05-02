---
-- @classmod DeliveryTarget
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseTarget = require("BaseTarget")

local DeliveryTarget = setmetatable({}, BaseTarget)
DeliveryTarget.ClassName = "DeliveryTarget"
DeliveryTarget.__index = DeliveryTarget

function DeliveryTarget.new(obj)
	local self = setmetatable(BaseTarget.new(obj), DeliveryTarget)

	return self
end

function DeliveryTarget:HandleTargetReached(drone)
	drone:GetPackageHolder():DropPackage()
end

return DeliveryTarget