--- Scans environment for drone
-- @classmod DroneScanner
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local BaseObject = require("BaseObject")
local Draw = require("Draw")
local Raycaster = require("Raycaster")
local Table = require("Table")

local DEBUG_SCANS = false
local SCAN_UP_FROM = 50

local SCAN_BEHIND = 2
local MIN_SCAN_COUNT = 10
local MAX_SCAN_COUNT = 75

-- Comms
local MAX_PACKET_AGE_SECONDS = 1
local MAX_FORWARD_TIME = 0.5
local MAX_FORWARD_COUNT = 3

local DroneScanner = setmetatable({}, BaseObject)
DroneScanner.ClassName = "DroneScanner"
DroneScanner.__index = DroneScanner

function DroneScanner.new(drone)
	local self = setmetatable(BaseObject.new(), DroneScanner)

	self._drone = drone or error("No drone part")
	self._radio = self._drone:GetRadio()

	self._knownDroneData = {} -- [guid] = packet

	self._maid:GiveTask(self._radio.DataRecieved:Connect(function(...)
		self:_handleDataRecieved(...)
	end))

	self._raycaster = Raycaster.new(function(data)
		-- Ignore drones
		if CollectionService:HasTag(data.Part, "Drone") then
			return true
		end
		if CollectionService:HasTag(data.Part, "Package") then
			return true
		end

		return not data.Part.CanCollide
	end)
	self._raycaster:Ignore({Workspace.CurrentCamera, self._drone:GetPart()})

	self._alive = true
	self._maid:GiveTask(function()
		self._alive = false
	end)
	spawn(function()
		while self._alive do
			self:_broadcastLocation()

			-- Avoid flooding network
			wait(0.05 + math.random() * 0.1)
		end
	end)

	return self
end

function DroneScanner:GetDronePositions()
	local positions = {}
	for _, packet in pairs(self._knownDroneData) do
		if (tick() - packet.TimeStamp) <= MAX_PACKET_AGE_SECONDS then
			local delta = tick() - packet.TimeStamp
			local position = packet.Position + delta*packet.Velocity
			table.insert(positions, position)
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
		local flatVelocity = (velocity * Vector3.new(1, 0, 1))
		local direction = flatVelocity.unit

		local desiredScans = math.ceil(flatVelocity.magnitude*3)
		local scanCount = math.clamp(desiredScans, MIN_SCAN_COUNT, MAX_SCAN_COUNT)

		for i=-SCAN_BEHIND, scanCount, 1 do
			local pos = position + direction*i + Vector3.new(0, SCAN_UP_FROM, 0)
			local ray = Ray.new(pos, Vector3.new(0, -scanLength, 0))
			self:_doRayScan(hits, ray)
		end
	end

	return hits
end

function DroneScanner:_handleDataRecieved(packet)
	assert(packet)

	if packet.Type == "LocationPacket" then
		if packet.DroneGUID ~= self._drone:GetGUID() then
			local currentPacket = self._knownDroneData[packet.DroneGUID]
			self._knownDroneData[packet.DroneGUID] = packet

			-- Forward!
			if (tick() - packet.TimeStamp) <= MAX_FORWARD_TIME
				and packet.ForwardCount < MAX_FORWARD_COUNT
				and (currentPacket and currentPacket.PacketGUID ~= packet.PacketGUID) then

				local newPacket = Table.Copy(packet)
				newPacket.ForwardCount = newPacket.ForwardCount + 1
				self._radio:BroadcastData(newPacket)
			end
		end
	end
end

function DroneScanner:_broadcastLocation()
	local packet = {
		Type = "LocationPacket";
		PacketGUID = HttpService:GenerateGUID(false);
		DroneGUID = self._drone:GetGUID();
		Position = self._drone:GetPosition();
		Velocity = self._drone:GetVelocity();
		ForwardCount = 0;
		TimeStamp = tick();
	}

	self._radio:BroadcastData(packet)
end

function DroneScanner:_doRayScan(hits, ray)
	local hitData = self._raycaster:FindPartOnRay(ray)

	if DEBUG_SCANS then
		Debris:AddItem(Draw.Ray(ray), 0.05)
	end

	if hitData then
		table.insert(hits, hitData)

		if DEBUG_SCANS then
			Debris:AddItem(Draw.Point(hitData.Position), 0.05)
		end
	end
end

return DroneScanner