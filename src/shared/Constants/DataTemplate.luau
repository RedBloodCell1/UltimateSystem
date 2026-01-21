--!strict
-- Defining Data Template
return {
	-- CURRENCY
	Dollars = 0,

	-- GAMEPLAY STATS (We save levels)
	Upgrades = {
		ActiveIncome = 0, -- Dollar spawn cooldown (1 Second to 0 Second)
		JobNumber = 0, -- How many Dollars can appear on the screen
		SelfWorth = 0, -- How much does dollars give you
	},

	-- METADATA (Good Practice)
	LoginCount = 0,
	LastLogin = 0,
}
