--- Main injection point for client
-- @script ClientMain
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))


-- Init
require("ClientBinders"):Init()

-- AfterInit
require("ClientBinders"):AfterInit()