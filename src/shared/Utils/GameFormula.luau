local GameFormula = {}

-- CONFIGURATION
local UPGRADE_CONFIG = {
	ActiveIncome = {
		-- DISPLAY DATA (Static)
		DisplayName = "Spawn Cooldown",
		Description = "Reduce $ spawn time",
		ImageId = "rbxassetid://1234567890",

		-- MATH DATA (Logic)
		BasePrice = 100,
		Exponent = 1.5,
		MaxLevel = 10,
	},
	JobNumber = {
		DisplayName = "Job Vacancy",
		Description = "Increase $ quantity on screen.",
		ImageId = "rbxassetid://1234567890",

		BasePrice = 500,
		Exponent = 2.0,
		MaxLevel = 5,
	},
	SelfWorth = {
		DisplayName = "Self Worth",
		Description = "Increases $ value.",
		ImageId = "rbxassetid://1234567890",

		BasePrice = 50,
		Exponent = 1.2,
		MaxLevel = 50,
	},
}

-- PUBLIC API

-- Get upgrade price for next level
function GameFormula.GetUpgradeCost(upgradeName: string, currentLevel: number): number?
	local config = UPGRADE_CONFIG[upgradeName]
	if not config then
		return nil
	end -- Invalid upgrade name

	if currentLevel >= config.MaxLevel then
		return nil -- Maxed out
	end

	-- Formula: Base * (Exponent ^ Level)
	local cost = config.BasePrice * (config.Exponent ^ currentLevel)
	return math.floor(cost)
end

-- Check if player is maxed
function GameFormula.IsMaxLevel(upgradeName: string, currentLevel: number): boolean
	local config = UPGRADE_CONFIG[upgradeName]
	if not config then
		return true
	end
	return currentLevel >= config.MaxLevel
end

-- Calculate Income (Used by Click/Income Controller)
function GameFormula.GetClickValue(selfWorthLevel: number): number
	return 1 + (selfWorthLevel * 1) -- Each level adds $1
end

function GameFormula.GetClickCooldown(activeIncomeLevel: number): number
	-- Level 0 = 1.0s, Level 10 = 0.1s
	return math.max(0.1, 1.0 - (activeIncomeLevel * 0.09))
end

function GameFormula.GetUpgradeInfo(upgradeName: string)
	return UPGRADE_CONFIG[upgradeName]
end

return GameFormula
