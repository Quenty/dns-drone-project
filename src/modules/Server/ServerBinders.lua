--- Holds binders
-- @classmod ClientBinders
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Binder = require("Binder")
local BinderProvider = require("BinderProvider")

return BinderProvider.new(function(self)
	-- Add drones
	self:Add(Binder.new("Drone", require("Drone")))

	-- Add targets
	self:Add(Binder.new("PickUpTarget", require("PickUpTarget")))
	self:Add(Binder.new("DeliveryTarget", require("DeliveryTarget")))

	-- Add packages
	self:Add(Binder.new("Package", require("Package")))
end)