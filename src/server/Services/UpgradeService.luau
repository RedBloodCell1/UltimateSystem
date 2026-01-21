--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEPENDENCIES
local DataService = require(script.Parent.DataService)
local TransactionService = require(script.Parent.TransactionService)
local NetworkService = require(script.Parent.NetworkService)
local GameFormula = require(ReplicatedStorage.Shared.Utils.GameFormula)

local UpgradeService = {}

-- INTERNAL FUNCTION
local function ProcessUpgradeRequest(player: Player, upgradeName: string): boolean
	-- GET DATA
	local profile = DataService.GetProfile(player)
	if not profile then
		return false
	end

	local currentUpgrades = profile.Data.Upgrades
	local currentLevel = currentUpgrades[upgradeName]

	-- VALIDATION (Does this upgrade exist?)
	if currentLevel == nil then
		warn(`[UpgradeService]: {player.Name} tried to buy invalid upgrade: {upgradeName}`)
		return false
	end

	-- CHECK MAX LEVEL
	if GameFormula.IsMaxLevel(upgradeName, currentLevel) then
		return false -- Already maxed
	end

	-- GET PRICE
	local cost = GameFormula.GetUpgradeCost(upgradeName, currentLevel)
	if not cost then
		return false
	end

	-- ATTEMPT TRANSACTION (The "Bank" Check)
	-- We pass negative cost because we are spending money
	local success =
		TransactionService.ProcessTransaction(player, -cost, `Bought {upgradeName} || Lvl {currentLevel + 1}`)

	if success then
		-- GRANT UPGRADE
		-- Clone the table to ensure the change is detected safely
		local newUpgrades = table.clone(currentUpgrades)
		newUpgrades[upgradeName] += 1

		-- Use the Master Setter from DataService
		DataService.Set(player, "Upgrades", newUpgrades)

		return true
	else
		return false -- Not enough money
	end
end

-- NETWORK SETUP
-- This allows the client to call UpgradeService.Purchase("ActiveIncome")
NetworkService.CreateFunction("PurchaseUpgrade", function(player, upgradeName)
	return ProcessUpgradeRequest(player, upgradeName)
end)

function UpgradeService.Start()
	print("[UpgradeService]: Shop System Online")
end

return UpgradeService
