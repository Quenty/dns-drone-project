--- Main injection point for server
-- @script ServerMain
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

-- Init
require("ServerBinders"):Init()

-- AfterInit
require("ServerBinders"):AfterInit()

local commNetworkManager = require("CommNetworkManager").new()

-- Enable comm network simulation
spawn(function()
	while true do
		commNetworkManager:SimulateNetwork()
		wait(0.025)
	end
end)