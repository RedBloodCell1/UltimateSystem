--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEPENDENCIES
local Comm = require(ReplicatedStorage.Packages.Comm)

-- NETWKORK SERVICE SETUP
local NetworkController = {}
local GlobalComm = Comm.ClientComm.new(ReplicatedStorage, true, "NetworkSync")
