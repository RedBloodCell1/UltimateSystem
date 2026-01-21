--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEPENDENCIES
local NetworkController = require(script.Parent.NetworkController)

local HUDController = {}

-- PRIVATE VARIABLES
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD = playerGui:WaitForChild("MainHUD")
local dollarLabel = mainHUD:WaitForChild("DollarLabel") :: TextLabel

-- HELPERS

-- PUBLIC API
function HUDController.Start()
	-- Get the Network Property we created in NetworkService
	local playerDataProperty = NetworkController.GetProperty("PlayerData")

	-- Observe for player data changes
	playerDataProperty:Observe(function(data)
		if not data then
			return
		end

		-- Update the text with the new dollar amount
		dollarLabel.Text = `$ {tostring(data.Dollars)}`

		print(`[HUD]: Updated display to {data.Dollars}`)
	end)
end

return HUDController
