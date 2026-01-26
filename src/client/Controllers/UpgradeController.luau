--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- DEPENDENCIES
local NetworkController = require(script.Parent.NetworkController)
local GameFormula = require(ReplicatedStorage.Shared.Utils.GameFormula)

local UpgradeController = {}

function UpgradeController.Start()
	-- Upgrade Board References
	local upgradeBoard = workspace:WaitForChild("UpgradeBoard")
	local surfaceGui = upgradeBoard:WaitForChild("SurfaceGui")
	local list = surfaceGui:WaitForChild("UpgradeMenu"):WaitForChild("UpgradeList")

	-- Network Handles
	local playerProperty = NetworkController.GetProperty("PlayerData")
	local purchaseFunction = NetworkController.GetFunction("PurchaseUpgrade")

	-- Initialize Upgrade Board Interface
	for _, frame in list:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		-- Identify the frame
		local upgradeID = frame:GetAttribute("UpgradeID")
		if not upgradeID then
			warn(`[UpgradeController] Frame {frame.Name} has no 'UpgradeID' attribute!`)
			continue
		end

		-- Load Static Data
		local config = GameFormula.GetUpgradeInfo(upgradeID)
		if not config then
			warn(`[UpgradeController] No config found in GameFormula for: {upgradeID}`)
			continue
		end

		-- Static UI
		local nameLabel = frame:WaitForChild("UpgradeName") :: TextLabel
		local descLabel = frame:WaitForChild("UpgradeDescription") :: TextLabel
		local imageLabel = frame:FindFirstChild("UpgradeImage") :: ImageLabel
		local buyBtn = frame:WaitForChild("BuyButton") :: TextButton

		-- Dynamic UI
		local effectLabel = frame:WaitForChild("UpgradeEffect") :: TextLabel
		local levelLabel = frame:WaitForChild("UpgradeLevel") :: TextLabel
		local priceLabel = frame:WaitForChild("UpgradeCost") :: TextLabel

		-- Apply Static Text
		nameLabel.Text = config.DisplayName
		descLabel.Text = config.Description
		if imageLabel then
			imageLabel.Image = config.ImageId or ""
		end

		-- Observe Dynamic Data
		playerProperty:Observe(function(newData)
			if not newData or not newData.Upgrades then
				return
			end

			local currentLevel = newData.Upgrades[upgradeID]
			local cost = GameFormula.GetUpgradeCost(upgradeID, currentLevel)

			-- Update Text
			levelLabel.Text = `Level: {currentLevel} / {config.MaxLevel}`
			-- effectLabel.Text =

			if cost then
				priceLabel.Text = `Cost: ${cost}`
				buyBtn.Text = "Buy"
				buyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Green (Available)
			else
				priceLabel.Text = "MAXED OUT"
				buyBtn.Text = "MAX"
				buyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Grey (Maxed)
			end
		end)

		-- Button Interaction (Buying)
		buyBtn.Activated:Connect(function()
			-- Visual Feedback (Click Shake)
			local originalPos = buyBtn.Position
			local shake = TweenService:Create(
				buyBtn,
				TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
				{
					Position = originalPos + UDim2.new(0.02, 0, 0, 0),
				}
			)
			shake:Play()

			-- Network Request
			local success = purchaseFunction(upgradeID)

			if not success then
				print("Purchase Failed: Check Money or Max Level")
			end
		end)
	end

	print("[UpgradeController]: LOADED")
end

return UpgradeController
