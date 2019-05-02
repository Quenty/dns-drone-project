--- Provides templates for the server
-- @module ServerTemplateProvider
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local ServerStorage = game:GetService("ServerStorage")

local TemplateProvider = require("TemplateProvider")

return TemplateProvider.new(function()
	return ServerStorage.ServerTemplates
end)