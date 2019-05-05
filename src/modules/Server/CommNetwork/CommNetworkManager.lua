--- Handles comm networks for the server
-- @classmod CommNetworkManager
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Debris = game:GetService("Debris")

local ServerBinders = require("ServerBinders")
local Draw = require("Draw")

local DEBUG_RADIO_SCANS = true

local CommNetworkManager = {}
CommNetworkManager.ClassName = "CommNetworkManager"
CommNetworkManager.__index = CommNetworkManager

function CommNetworkManager.new()
	local self = setmetatable({}, CommNetworkManager)

	return self
end

function CommNetworkManager:SimulateNetwork()
	local radios = self:_getRadios()

	-- N^2
	for _, radio in pairs(radios) do
		self:_handleComms(radio, radios)
	end
end

function CommNetworkManager:_handleComms(radio, radios)
	local toSend = radio:ReadBroadcastedData()
	if #toSend <= 0 then
		return
	end

	local pos = radio:GetPosition()
	for _, otherRadio in pairs(radios) do
		if radio ~= otherRadio then
			local pos2 = otherRadio:GetPosition()
			local dist = (pos - pos2).magnitude

			if dist <= radio:GetSendRange() then

				otherRadio:RecieveDataStream(toSend)

				if DEBUG_RADIO_SCANS then
					local ray = Ray.new(pos, pos2 - pos)
					Debris:AddItem(Draw.Ray(ray), 0.05)
				end
			end
		end
	end
end

function CommNetworkManager:_getJammingZones()
	return ServerBinders.JammingZone:GetAll()
end

function CommNetworkManager:_getRadios()
	local zones = self:_getJammingZones()

	local radios = {}
	for _, item in pairs(ServerBinders.Drone:GetAll()) do
		local jammed = false
		local radio = item:GetRadio()
		local radioPosition = radio:GetPosition()

		for _, zone in pairs(zones) do
			if zone:InZone(radioPosition) then
				jammed = true
				break
			end
		end

		if not jammed then
			table.insert(radios, radio)
		end
	end
	return radios
end

return CommNetworkManager