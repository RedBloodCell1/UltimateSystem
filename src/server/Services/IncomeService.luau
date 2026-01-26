--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local RunService = game:GetService("RunService")

-- DEPENDENCIES
local GameFormula = require(ReplicatedStorage.Shared.Utils.GameFormula)
local DataService = require(script.Parent.DataService)
local NetworkService = require(script.Parent.NetworkService)
local TransactionService = require(script.Parent.TransactionService)

local IncomeService = {}

-- VARIABLES
local lastClickTimes = {}

-- local PASSIVE_INCOME_INTERVAL = 1.0
-- local lastPassiveCycle = 0

-- HELPER FUNCTIONS
local function GetClickCooldown(player: Player): number
	local profile = DataService.GetProfile(player)
	if not profile then
		return 1.0
	end
	return GameFormula.GetClickCooldown(profile.Data.Upgrades.ActiveIncome)
end

local function GetClickValue(player: Player): number
	local profile = DataService.GetProfile(player)
	if not profile then
		return 1
	end
	return GameFormula.GetClickValue(profile.Data.Upgrades.SelfWorth)
end

local function GetPassiveValue(player: Player): number
	return 0
end

-- THE MAIN CLICK LOGIC
function IncomeService.ProcessClick(player: Player): boolean
	local currentTime = os.clock()
	local lastClick = lastClickTimes[player] or 0
	local cooldown = GetClickCooldown(player)

	-- VALIDATION
	if currentTime - lastClick < cooldown then
		return false
	end

	-- UPDATE
	lastClickTimes[player] = currentTime

	-- REWARD
	local amount = GetClickValue(player)
	return TransactionService.ProcessTransaction(player, amount, "Button Clicked")
end

-- NETWORK SETUP
NetworkService.CreateFunction("ClickRequest", function(player)
	return IncomeService.ProcessClick(player)
end)

--[[
-- Start Passive Loop
function IncomeService.StartPassiveLoop()
	-- Use RunService.Heartbeat to run a loop.

	RunService.Heartbeat:Connect(function(deltaTime)
		local now = os.clock()
		if now - lastPassiveCycle >= PASSIVE_INCOME_INTERVAL then
			lastPassiveCycle = now

			for _, player in Players:GetPlayers() do
				local income = GetPassiveValue(player)
				if income > 0 then
					TransactionService.ProcessTransaction(player, income, "Passive Income")
				end
			end
		end
	end)
end
]]

-- INITIALIZATION
function IncomeService.Start()
	print("[IncomeService]: LOADED")

	-- Clean Up
	Players.PlayerRemoving:Connect(function(player)
		lastClickTimes[player] = nil
	end)

	-- Start the passive loop
	-- IncomeService.StartPassiveLoop()
end

return IncomeService
