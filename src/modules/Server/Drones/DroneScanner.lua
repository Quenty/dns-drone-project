--- Scans environment for drone
-- @classmod DroneScanner
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local BaseObject = require("BaseObject")
local Draw = require("Draw")
local Raycaster = require("Raycaster")

local DESIRED_HEIGHT = 20
local SCAN_UP_FROM = 25
local SCAN_LENGTH = SCAN_UP_FROM + DESIRED_HEIGHT

local DroneScanner = setmetatable({}, BaseObject)
DroneScanner.ClassName = "DroneScanner"
DroneScanner.__index = DroneScanner

function DroneScanner.new(obj)
	local self = setmetatable(BaseObject.new(), DroneScanner)

	self._obj = obj or error("No drone part")

	self._raycaster = Raycaster.new(function(data)
		return not data.Part.CanCollide
	end)
	self._raycaster:Ignore({Workspace.CurrentCamera, self._obj})

	return self
end

function DroneScanner:ScanInFront(position, velocity)
	local hits = {}
	local direction = velocity.unit * Vector3.new(1, 0, 1)

	for i=0, 50, 1 do
		local pos = position + direction*i + Vector3.new(0, SCAN_UP_FROM, 0)
		local ray = Ray.new(pos, Vector3.new(0, -SCAN_LENGTH, 0))


		local hitData = self._raycaster:FindPartOnRay(ray)
		if hitData then
			Debris:AddItem(Draw.Ray(ray), 0.05)
			table.insert(hits, hitData)
		end
	end

	return hits
end

return DroneScanner