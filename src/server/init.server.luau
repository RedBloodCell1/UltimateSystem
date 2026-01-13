--!strict
local ServerScriptService = game:GetService("ServerScriptService")

-- This simple bootstrapper finds all services and runs .Start()
local function Boot()
	print("--------------------------------")
	print("  ULTIMATE FRAMEWORK STARTING   ")
	print("--------------------------------")

	-- 1. Define where the services live
	local ServicesFolder: Folder = ServerScriptService.Server.Services

	-- 2. Require and Start them
	for _, module: Instance in ServicesFolder:GetChildren() do
		if module:IsA("ModuleScript") then
			local success, result = pcall(function()
				return require(module)
			end)

			if success then
				local service = result
				if type(service) == "table" and service.Start then
					task.spawn(function()
						service.Start()
					end)
					print(`[Bootstrapper]: Started {module.Name}`)
				end
			else
				warn(`[Bootstrapper]: Failed to load {module.Name}: {result}`)
			end
		end
	end

	print("--------------------------------")
end

Boot()
