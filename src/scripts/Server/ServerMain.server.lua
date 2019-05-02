--- Main injection point for server
-- @script ServerMain
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

-- Init
require("ServerBinders"):Init()

-- AfterInit
require("ServerBinders"):AfterInit()