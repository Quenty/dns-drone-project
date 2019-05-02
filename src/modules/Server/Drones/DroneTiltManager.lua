--- Animates the drone tilting
-- @classmod DroneTiltManager
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Workspace = game:GetService("Workspace")

local BaseObject = require("BaseObject")

local DroneTiltManager = setmetatable({}, BaseObject)
DroneTiltManager.ClassName = "DroneTiltManager"
DroneTiltManager.__index = DroneTiltManager

function DroneTiltManager.new(obj, vectorForce, alignOrientation)
	local self = setmetatable(BaseObject.new(obj), DroneTiltManager)

	self._vectorForce = vectorForce or error("No vectorForce")
	self._alignOrientation = alignOrientation or error("No alignOrientation")

	self._attachment = Instance.new("Attachment")
	self._attachment.Parent = Workspace.Terrain
	self._alignOrientation.Attachment1 = self._attachment

	return self
end

function DroneTiltManager:Update()
	local force = self._vectorForce.Force
	if force.magnitude == 0 then
		self:_setOrientation(CFrame.new())
		return
	end


	-- Adjust force to ignore a lot of gravity to get comical tilting
	local top = (force * Vector3.new(1, 0.15, 1)).unit
	local back = -self._obj.velocity.unit
	local right = top:Cross(back)

	self:_setOrientation(CFrame.fromMatrix(Vector3.new(), right, top))
end

function DroneTiltManager:_setOrientation(cframe)
	self._attachment.CFrame = cframe
end

return DroneTiltManager