--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEPENDENCIES
local Comm = require(ReplicatedStorage.Packages.Comm)

-- NETWKORK SERVICE SETUP
local NetworkController = {}
local GlobalComm = Comm.ClientComm.new(ReplicatedStorage, true, "NetworkSync")

-- PUBLIC API

-- Access synchronized properties across server and clients
function NetworkController.GetProperty(name: string)
	return GlobalComm:GetProperty(name)
end

-- Access one way signals
function NetworkController.GetSignal(name: string)
	return GlobalComm:GetSignal(name)
end

-- Access a remote function
function NetworkController.GetFunction(name: string)
	return GlobalComm:GetFunction(name)
end

-- 4. STARTUP
function NetworkController.Start()
	print("[NetworkController]: Global bridge initialized.")
end

return NetworkController
