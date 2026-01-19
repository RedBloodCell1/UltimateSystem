--!strict
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- REQUIRE
local GameFormula = require(ReplicatedStorage.Shared.Utils.GameFormula)
local NetworkController = require(script.Parent.NetworkController)

local ClickController = {}

-- SETUP VARIABLES
local button: TextButton = nil
local isWaiting = false -- Debounce

-- THE RANDOMIZER FUNCTION
local function RepositionButton()
	if not button then
		return
	end

	-- We use scale (0.0 to 0.8) so the button stays inside the part (Because the part is 0.2 on scale)
	local randomX = math.random(0, 80) / 100
	local randomY = math.random(0, 80) / 100

	button.Position = UDim2.fromScale(randomX, randomY)
end

-- THE MAIN LOGIC
function ClickController.HandleClick()
	if isWaiting then
		return
	end

	local playerProperty = NetworkController.GetProperty("PlayerData")
	local data = playerProperty:Get()

	-- Check if data is loaded or not, Default to level 0
	local clickLevel = 0
	if data and data.Upgrades then
		clickLevel = data.Upgrades.ClickSpeedLevel
	end

	isWaiting = true

	-- Hide the button immediately after click
	button.Visible = false

	-- Fire the server!
	local clickRequest = NetworkController.GetFunction("ClickRequest")
	if clickRequest then
		clickRequest() -- Tells the server to give us money
	end

	local cooldownTime = GameFormula.GetClickCooldown(clickLevel)
	print("COOLDOWN TIME " .. cooldownTime)
	task.wait(cooldownTime)

	-- Randomize button position
	RepositionButton()

	-- Show the button again
	button.Visible = true
	isWaiting = false
end

-- 5. INITIALIZATION
function ClickController.Start()
	-- Get the physical button in the world
	local clickPart = Workspace:WaitForChild("ClickPart")
	local gui = clickPart:WaitForChild("ClickGui")
	button = gui:WaitForChild("DollarButton")

	-- Initial setup: Move to a random spot and make sure it's visible
	RepositionButton()

	-- Connect the event
	button.Activated:Connect(ClickController.HandleClick)

	print("[ClickController]: Start Working")
end

return ClickController
