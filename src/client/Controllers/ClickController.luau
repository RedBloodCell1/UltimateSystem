--!strict
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- REQUIRE
local VisualFX = require(StarterPlayer.StarterPlayerScripts.Client.Utils.VisualFX)
local GameFormula = require(ReplicatedStorage.Shared.Utils.GameFormula)
local NetworkController = require(script.Parent.NetworkController)

local ClickController = {}

-- SETUP VARIABLES
local CLICK_PART_NAME = "ClickPart"
local CLICK_TEXT_COLOR = Color3.fromRGB(85, 255, 127)

local button: TextButton = nil
local clickPart: Part = nil
local clickSound = nil

local isWaiting: boolean = false -- Debounce

local cachedData: any = nil

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

	VisualFX.PlaySound(clickSound) -- Play Sound

	local clickLevel = cachedData.Upgrades.ActiveIncome
	local powerLevel = cachedData.Upgrades.SelfWorth

	local amount = GameFormula.GetClickValue(powerLevel)

	print(cachedData.Dollars)

	local partSize = clickPart.Size
	local buttonPos = button.Position

	local offsetX = (buttonPos.X.Scale - 0.5) * partSize.X
	local offsetY = (0.5 - buttonPos.Y.Scale) * partSize.Y

	local myOffset = Vector3.new(offsetX, offsetY, 0.5)
	VisualFX.FloatText(clickPart, "+" .. tostring(amount), CLICK_TEXT_COLOR, myOffset)

	isWaiting = true
	button.Visible = false -- Hide the button immediately after click

	-- Fire the server!
	local clickRequest = NetworkController.GetFunction("ClickRequest")
	if clickRequest then
		clickRequest() -- Tells the server to give us money
	end

	local cooldownTime = GameFormula.GetClickCooldown(clickLevel)
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
	clickPart = Workspace:WaitForChild(CLICK_PART_NAME)
	local gui = clickPart:WaitForChild("ClickGui")
	button = gui:WaitForChild("DollarButton") :: TextButton
	clickSound = clickPart:FindFirstChild("ClickSound") :: Sound

	local playerProperty = NetworkController.GetProperty("PlayerData")

	playerProperty:Observe(function(newData)
		cachedData = newData
	end)

	RepositionButton() -- Move button to a random spot on the part
	button.Activated:Connect(ClickController.HandleClick) -- Connect the event

	print("[ClickController]: System Started")
end

return ClickController
