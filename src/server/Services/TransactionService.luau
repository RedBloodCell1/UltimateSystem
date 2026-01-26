--!strict
local ServerScriptService = game:GetService("ServerScriptService")

-- DEPENDENCIES
local DataService = require(ServerScriptService.Server.Services.DataService)

local TransactionService = {}

-- PUBLIC API

-- PROCESS TRANSACTION
function TransactionService.ProcessTransaction(player: Player, amount: number, reason: string): boolean
	-- Getting player profile
	local profile = DataService.GetProfile(player)
	if not profile then
		return false
	end

	local currentDollars = profile.Data.Dollars
	local newDollars = currentDollars + amount

	if newDollars < 0 then
		print(`[Economy]: Transaction Failed for {player.Name} (Not enough money)`)
		return false
	end

	DataService.Set(player, "Dollars", newDollars)

	print(`[Economy]: {amount > 0 and "+" or ""}{amount} | {player.Name} | Reason: {reason}`)
	return true
end

-- GET BALANCE
function TransactionService.GetBalance(player: Player): number
	local profile = DataService.GetProfile(player)
	return profile and profile.Data.Dollars or 0
end

function TransactionService.Start()
	print("[TransactionService]: LOADED")
end

return TransactionService
