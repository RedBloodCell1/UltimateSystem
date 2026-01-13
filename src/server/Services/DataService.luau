--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. DEPENDENCIES
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Template = require(ReplicatedStorage.Shared.Constants.DataTemplate)

-- 2. CONSTANTS
local DATA_STORE_KEY = "Test-v1"

-- 3. SERVICE SETUP
local DataService = {}
DataService._profiles = {} -- [Player] = Profile

-- 4. INITIALIZE STORE
local Store = ProfileStore.New(DATA_STORE_KEY, Template)

-- 5. PRIVATE FUNCTIONS
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
			DataService._profiles[player] = nil
			player:Kick("Session lock released. Please rejoin.")
		end)

		-- C. Final Safety Check
		if player.Parent == Players then
			DataService._profiles[player] = profile
			print(`[DataService]: Profile loaded for {player.Name}`)
		else
			profile:EndSession()
		end
	else
		-- Data failed to load (Roblox is down, or another server locked it)
		player:Kick("Unable to load data. Please rejoin.")
	end
end

local function PlayerRemoving(player: Player)
	local profile = DataService._profiles[player]
	if profile ~= nil then
		profile:EndSession()
		DataService._profiles[player] = nil
		print(`[DataService]: Profile saved for {player.Name}`)
	end
end

-- 6. PUBLIC API
function DataService.GetProfile(player: Player)
	return DataService._profiles[player]
end

-- 7. BOOTSTRAP
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
