--- Scans environment for drone
-- @classmod DroneScanner
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local BaseObject = require("BaseObject")
local Draw = require("Draw")
local Raycaster = require("Raycaster")
local ServerBinders = require("ServerBinders")

local DEBUG_SCANS = false
local SCAN_UP_FROM = 25
local SCAN_COUNT = 75

local DroneScanner = setmetatable({}, BaseObject)
DroneScanner.ClassName = "DroneScanner"
DroneScanner.__index = DroneScanner

function DroneScanner.new(drone)
	local self = setmetatable(BaseObject.new(), DroneScanner)

	self._drone = drone or error("No drone part")

	self._raycaster = Raycaster.new(function(data)
		-- Ignore drones
		if CollectionService:HasTag(data.Part, "Drone") then
			return true
		end

		return not data.Part.CanCollide
	end)
	self._raycaster:Ignore({Workspace.CurrentCamera, self._drone:GetPart()})

	return self
end

function DroneScanner:GetDronePositions(position)

	-- Use global knowledge for now
	local positions = {}
	for _, drone in pairs(ServerBinders.Drone:GetAll()) do
		if drone ~= self._drone then
			table.insert(positions, drone:GetPosition())
		end
	end

	return positions
end

function DroneScanner:ScanInFront(position, velocity, height)
	local hits = {}
	local scanLength = height + SCAN_UP_FROM

	if (math.abs(velocity.y) + math.abs(velocity.z)) == 0 then
		local ray = Ray.new(position, Vector3.new(0, -scanLength, 0))
		self:_doRayScan(hits, ray)
	else
		local direction = (velocity * Vector3.new(1, 0, 1)).unit
		for i=0, SCAN_COUNT, 1 do
			local pos = position + direction*i + Vector3.new(0, SCAN_UP_FROM, 0)
			local ray = Ray.new(pos, Vector3.new(0, -scanLength, 0))
			self:_doRayScan(hits, ray)
		end
	end

	return hits
end

function DroneScanner:_doRayScan(hits, ray)
	local hitData = self._raycaster:FindPartOnRay(ray)
	if hitData then
		if DEBUG_SCANS then
			Debris:AddItem(Draw.Ray(ray), 0.05)
		end

		table.insert(hits, hitData)
	end
end

return DroneScanner