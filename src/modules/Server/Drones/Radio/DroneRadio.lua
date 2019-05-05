---
-- @classmod DroneRadio
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local BaseObject = require("BaseObject")
local Signal = require("Signal")

local DroneRadio = setmetatable({}, BaseObject)
DroneRadio.ClassName = "DroneRadio"
DroneRadio.__index = DroneRadio

function DroneRadio.new(obj)
	local self = setmetatable(BaseObject.new(obj), DroneRadio)

	self.DataRecieved = Signal.new() -- :Fire(packet)
	self._maid:GiveTask(self.DataRecieved)

	self._queue = {}

	return self
end

function DroneRadio:GetSendRange()
	return 60
end

function DroneRadio:GetPosition()
	return self._obj.Position
end

function DroneRadio:ReadBroadcastedData()
	local data = self._queue
	self._queue = {}
	return data
end

function DroneRadio:RecieveDataStream(dataStream)
	assert(dataStream)
	for _, data in pairs(dataStream) do
		self.DataRecieved:Fire(data)
	end
end

function DroneRadio:BroadcastData(data)
	table.insert(self._queue, data)
end

return DroneRadio