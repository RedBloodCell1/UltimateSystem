local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local VisualFX = {}

-- CONFIGURATION
local FLOAT_DURATION = 1.0
local FLOAT_HEIGHT = 2.0

-- Spawn floating text at a location
function VisualFX.FloatText(target: Instance, text: string, color: Color3, offset: Vector3?)
	-- Create the BillboardGui (Container)
	local bill = Instance.new("BillboardGui")
	bill.Name = "FloatingText"

	if target:IsA("BasePart") then
		bill.Adornee = target
	end

	bill.Size = UDim2.fromScale(4, 1)
	bill.StudsOffset = offset or Vector3.new(0, 0, 0)
	bill.AlwaysOnTop = true

	-- Create the Label
	local label = Instance.new("TextLabel")
	label.Parent = bill
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne

	-- Create the stroke for the label
	local stroke = Instance.new("UIStroke")
	stroke.Parent = label
	stroke.Thickness = 2

	bill.Parent = target -- We parent to the part so that it moves with the part if the part moved

	local tweenInfo = TweenInfo.new(FLOAT_DURATION, Enum.EasingStyle.Quad)

	local goal = {
		StudsOffset = Vector3.new(0, FLOAT_HEIGHT, 0), -- Move Up
	}

	local fadeTween = TweenService:Create(label, tweenInfo, { TextTransparency = 1 })
	local strokeTween = TweenService:Create(stroke, tweenInfo, { Transparency = 1 })
	local moveTween = TweenService:Create(bill, tweenInfo, goal)

	fadeTween:Play()
	strokeTween:Play()
	moveTween:Play()

	-- CLEANUP
	Debris:AddItem(bill, FLOAT_DURATION)
end

-- Simple Sound Helper
function VisualFX.PlaySound(sound: Sound)
	if not sound.IsLoaded then
		sound.Loaded:Wait()
	end
	sound:Play()
end

return VisualFX
