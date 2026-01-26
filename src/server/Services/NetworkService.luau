--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEPENDENCIES
local Comm = require(ReplicatedStorage.Packages.Comm)

-- NETWKORK SERVICE SETUP
local NetworkService = {}
local GlobalComm = Comm.ServerComm.new(ReplicatedStorage, "NetworkSync") -- Make a folder named "NetworkSync" in ReplicatedStorage

-- PUBLIC API

-- Creates synchronized properties across server and clients
function NetworkService.CreateProperty(name: string, initialValue: any)
	return GlobalComm:CreateProperty(name, initialValue)
end

-- Creates one way signals
function NetworkService.CreateSignal(name: string)
	return GlobalComm:CreateSignal(name)
end

-- Binds a remote function
function NetworkService.CreateFunction(name: string, callback: (player: Player, ...any) -> ...any)
	return GlobalComm:BindFunction(name, callback)
end

-- 4. STARTUP
function NetworkService.Start()
	print("[NetworkService]: LOADED")
end

return NetworkService
