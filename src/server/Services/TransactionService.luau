--!strict
local ServerScriptService = game:GetService("ServerScriptService")

-- DEPENDENCIES
local DataService = require(ServerScriptService.Server.Services.DataService)

local TransactionService = {}

-- PUBLIC API

-- MANAGE MONEY
-- usage: TransactionService.Award(player, 100, "Money Clicked")
function TransactionService.Award(player: Player, amount: number, reason: string): boolean
	-- Getting player profile
	local profile = DataService.GetProfile(player)
	if not profile then
		return false
	end

	-- Math
	profile.Data.Dollars += amount
	DataService.UpdateStat(player, "Dollars", profile.Data.Dollars)
	DataService.UpdateProperty(player)

	print(`[Economy]: Give {amount} to {player.Name} | Reason: {reason} | New Bal: {profile.Data.Dollars}`)
	return true
end

-- GET BALANCE
function TransactionService.GetBalance(player: Player): number
	local profile = DataService.GetProfile(player)
	return profile and profile.Data.Dollars or 0
end

function TransactionService.Start()
	print("[TransactionService]: Economy System Online")
end

return TransactionService
