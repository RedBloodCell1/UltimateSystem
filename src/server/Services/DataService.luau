--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEPENDENCIES
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Template = require(ReplicatedStorage.Shared.Constants.DataTemplate)
local PlayerStat = require(ReplicatedStorage.Shared.Systems.PlayerStat)
local NetworkService = require(ServerScriptService.Server.Services.NetworkService)

-- CONSTANTS
local DATA_STORE_KEY = "Test-v3" -- DATA_STORE_KEY can be changed to separate environments

-- SERVICE SETUP
local DataService = {}
DataService._profiles = {} -- [Player] = Profile
DataService._objects = {} -- [Player] = PlayerStat Object

-- INITIALIZE PROFILE STORE
local Store = ProfileStore.New(DATA_STORE_KEY, Template)

-- SETTING UP NETWORK PROPERTIES
local PlayerDataProperty = NetworkService.CreateProperty("PlayerData", {})

-- PRIVATE FUNCTIONS
local function PlayerAdded(player: Player)
	-- Start the session
	local profile = Store:StartSessionAsync(`Player_{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		-- The player is safely in the game and data is loaded.

		-- A. Maintenance
		profile:AddUserId(player.UserId) -- GDPR Compliance
		profile:Reconcile() -- Fills in missing values from Template

		-- B. Session Locking
		profile.OnSessionEnd:Connect(function()
			if DataService._objects[player] then
				DataService._objects[player]:Destroy()
				DataService._objects[player] = nil
			end

			DataService._profiles[player] = nil
			player:Kick("Session lock released. Please rejoin.")
		end)

		-- C. Final Safety Check
		if player.Parent == Players then
			DataService._profiles[player] = profile -- Store reference to player profile

			local stats = PlayerStat.new(player, profile.Data, PlayerDataProperty) -- Create PlayerStat object
			DataService._objects[player] = stats -- Store reference to PlayerStat object

			print(`[DataService]: Session started for {player.Name}`)

			PlayerDataProperty:SetFor(player, profile.Data) -- Initialize network property
		else
			profile:EndSession()
		end
	else
		-- Data failed to load (Roblox is down, or another server locked it)
		player:Kick("Unable to load data. Please rejoin.")
	end
end

local function PlayerRemoving(player: Player)
	if DataService._objects[player] then
		DataService._objects[player]:Destroy()
		DataService._objects[player] = nil
	end

	local profile = DataService._profiles[player]
	if profile ~= nil then
		profile:EndSession()
		DataService._profiles[player] = nil
		print(`[DataService]: Profile saved for {player.Name}`)
	end
end

-- PUBLIC API
-- Get player profile
function DataService.GetProfile(player: Player)
	return DataService._profiles[player]
end

-- Update player object stat
function DataService.UpdateStat(player: Player, key: string, value: any)
	local statObject = DataService._objects[player]
	if statObject then
		statObject:Set(key, value)
	end
end

-- BOOTSTRAP
function DataService.Start()
	print("Starting DataService...")

	-- Loop through existing players (in case of lag/late load)
	for _, player in Players:GetPlayers() do
		task.spawn(PlayerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerRemoving)
end

return DataService
