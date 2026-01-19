local GameFormula = {}

local BASE_CLICK_COOLDOWN = 1.0
local MIN_COOLDOWN = 0.1
local COOLDOWN_REDUCTION = 0.05

-- Active Income: Reduces cooldown (1.0s down to 0)
function GameFormula.GetClickCooldown(level: number): number
	local cooldown = BASE_CLICK_COOLDOWN - (level * COOLDOWN_REDUCTION)
	return math.max(MIN_COOLDOWN, cooldown)
end

-- Self Worth: Each click generates more money
function GameFormula.GetClickValue(level: number): number
	return 1 + level
end

return GameFormula
