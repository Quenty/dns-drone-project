---
-- @classmod PickUpTarget
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseTarget = require("BaseTarget")
local ServerTemplates = require("ServerTemplates")
local ServerBinders = require("ServerBinders")

local PickUpTarget = setmetatable({}, BaseTarget)
PickUpTarget.ClassName = "PickUpTarget"
PickUpTarget.__index = PickUpTarget

function PickUpTarget.new(obj)
	local self = setmetatable(BaseTarget.new(obj), PickUpTarget)

	return self
end

function PickUpTarget:HandleTargetReached(drone)
	local part = ServerTemplates:Clone("PackageTemplate")
	part.Parent = drone:GetPart()

	local package = ServerBinders.Package:Bind(part)
	if not package then
		warn("[PickUpTarget] - No package from :Bind")
		return
	end

	drone:GetPackageHolder():SetPackage(package)
end

return PickUpTarget