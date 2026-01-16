--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Controllers = script.Controllers

local loadedControllers = {}

-- PHASE 1: REQUIRE (Load them into memory)
for _, module in Controllers:GetChildren() do
	if module:IsA("ModuleScript") then
		local success, result = pcall(function()
			return require(module)
		end)

		if success then
			loadedControllers[module.Name] = result
			print(`[CLIENT]: Loaded {module.Name}`)
		else
			warn(`[CLIENT]: Failed to load {module.Name}: {result}`)
		end
	end
end

-- PHASE 2: START (Wake them up)
print("--------------------------------")
print("[CLIENT]: Starting Controllers...")

for name, controller in loadedControllers do
	if type(controller.Start) == "function" then
		task.spawn(function()
			local success, err = pcall(function()
				controller.Start()
			end)

			if not success then
				warn(`[CLIENT]: Error starting {name}: {err}`)
			end
		end)
	end
end

print("[CLIENT]: Framework Initialized")
print("--------------------------------")
