--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEPENDENCIES
local DataService = require(ServerScriptService.Server.Services.DataService)

local TransactionService = {}

-- PUBLIC API

-- ADDING MONEY
-- usage: TransactionService.Award(player, 100, "Money Clicked")
function TransactionService.Award(player: Player, amount: number, reason: string): boolean
	-- Sanity Check
	if amount <= 0 then
		warn(`[TransactionService] can't reward <= 0 dollars`)
		return false
	end

	-- Getting player profile
	local profile = DataService.GetProfile(player)
	if not profile then
		return false
	end

	-- Math
	profile.Data.Dollars += amount
	DataService.UpdateStat(player, "Dollars", profile.Data.Dollars)

	print(`[Economy]: +${amount} to {player.Name} | Reason: {reason} | New Bal: {profile.Data.Dollars}`)
	return true
end

-- SPENDING MONEY
-- usage: TransactionService.Purchase(player, 50, "Active Income")
function TransactionService.Purchase(player: Player, cost: number, itemId: string): boolean
	if cost < 0 then
		return false
	end

	local profile = DataService.GetProfile(player)
	if not profile then
		return false
	end

	-- Validation
	if profile.Data.Dollars >= cost then
		-- Transaction
		profile.Data.Dollars -= cost
		DataService.UpdateStat(player, "Dollars", profile.Data.Dollars)

		print(`[Economy]: {player.Name} spent ${cost} on {itemId}`)
		return true -- Success
	else
		return false -- Insufficient Funds
	end
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
