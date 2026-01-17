--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEPENDENCIES
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)
local Trove = require(Packages.Trove)

-- CLASS DEFINITION
local PlayerStat = {}
PlayerStat.__index = PlayerStat

-- CONSTRUCTOR
function PlayerStat.new(player: Player, data: {}, networkProperty: any)
	local self = setmetatable({}, PlayerStat)

	self._trove = Trove.new() -- Create Trove Instance for this object

	self._player = player -- Reference to the player
	self._data = data or {} -- Storage for player stats

	-- Network + Signal Setup
	self._networkProperty = networkProperty -- Reference to the network property for syncing
	self.Changed = self._trove:Construct(Signal) -- Signal for stat changes (In which we connect to trove so if we destroy the PlayerStat, the signal is cleaned up)

	return self
end

-- METHODS

-- Gets a player stat by key
function PlayerStat:Get(key: string): any
	return self._data[key]
end

-- Sets a player stat and fires the Changed signal if the value is different
function PlayerStat:Set(key: string, value: any)
	if self._data[key] ~= value then
		local oldValue = self._data[key]
		self._data[key] = value
		self.Changed:Fire(key, oldValue, value)

		if self._networkProperty then
			self._networkProperty:SetFor(self.player, self._data)
		end
	end
end

function PlayerStat:Destroy()
	self._trove:Destroy() -- Destroy the Signal and clean object memory

	-- Set the table to nil to help with Luau garbage collection
	table.clear(self)
	setmetatable(self, nil)
end

return PlayerStat
