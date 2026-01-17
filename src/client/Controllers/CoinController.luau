local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetworkController = require(script.Parent.NetworkController)

local CoinController = {}

function CoinController.Start()
	-- Grab the synchronized property for coins
	local playerData = NetworkController.GetProperty("PlayerData")

	playerData:Observe(function(data)
		print("[CLIENT] Received Data Update:")
		print(data)
		print("Current Coins:", data.Coins)
	end)
end

return CoinController
