-- Turn managing functions

if TurnManager == nil then
	_G.TurnManager = class({})
end

-- Core dota tactics functions
function TurnManager:Init()
	print(" --- Initializing turn manager...")

	self.current_turn_team = DOTA_TEAM_GOODGUYS
	self.current_turn_time_remaining = 90

	self.current_action_points = {}
	self.current_action_points[Tactics:GetRadiantPlayerID()] = 2
	self.current_action_points[Tactics:GetDirePlayerID()] = 0

	self.current_mana = {}
	self.current_mana[Tactics:GetRadiantPlayerID()] = 1
	self.current_mana[Tactics:GetDirePlayerID()] = 0

	self:StartTurnCountdown()

	print("Finished turn manager initialization")
end

-- Basic functions
function TurnManager:IsPlayerTurn(player_id)
	if self:GetCurrentTurnTeam() == PlayerResource:GetTeam(player_id) then
		return true
	else
		return false
	end
end

function TurnManager:GetCurrentTurnTeam()
	return self.current_turn_team
end

function TurnManager:SetCurrentTurnTeam(team)
	self.current_turn_team = team
end

function TurnManager:EndTurn()
	print("--- Ending turn!")
	for _, unit in pairs(Tactics:GetAllUnits()) do
		unit:ClearHasMovedThisTurn()
		unit:ClearHasCastedThisTurn()

		for i = 0, 8 do
			local item = unit:GetItemInSlot(i)
			if item then
				item:SetActivated(true)
			end
		end
	end

	if self:GetCurrentTurnTeam() == DOTA_TEAM_GOODGUYS then
		self:SetActionPoints(Tactics:GetRadiantPlayerID(), 0)
		self:SetActionPoints(Tactics:GetDirePlayerID(), 3)
		self:SetCurrentTurnTeam(DOTA_TEAM_BADGUYS)
		self:IncrementMana(Tactics:GetDirePlayerID())
		if IsInToolsMode() then
			Timers:CreateTimer(1, function()
				self:EndTurn()
			end)
		end
	else
		self:SetActionPoints(Tactics:GetDirePlayerID(), 0)
		self:SetActionPoints(Tactics:GetRadiantPlayerID(), 3)
		self:SetCurrentTurnTeam(DOTA_TEAM_GOODGUYS)
		self:IncrementMana(Tactics:GetRadiantPlayerID())
	end

	self:ResetTimer()
	self:UpdateNetTableValues()
	self:StartTurnCountdown()
	CombatManager:PerformTurnEffects()
end

function TurnManager:ResetTimer()
	self.current_turn_time_remaining = 90
end

function TurnManager:EndGameWithWinner(winner_team)
	Tactics:SetPlayerBusy(Tactics:GetRadiantPlayerID())
	Tactics:SetPlayerBusy(Tactics:GetDirePlayerID())
	GameRules:SetGameWinner(winner_team)
end

function TurnManager:PlayerRequestedEndTurn(keys)
	if IsServer() then
		if PlayerResource:GetTeam(keys.player_id) == TurnManager.current_turn_team then
			TurnManager:EndTurn()
		end
	end
end

function TurnManager:UpdateNetTableValues()
	local radiant_id = Tactics:GetRadiantPlayerID()
	local dire_id = Tactics:GetDirePlayerID()
	CustomNetTables:SetTableValue("turn_manager", "turn_time", {time = self.current_turn_time_remaining})
	CustomNetTables:SetTableValue("turn_manager", "action_points", {radiant = self.current_action_points[radiant_id], dire = self.current_action_points[dire_id]})
	CustomNetTables:SetTableValue("turn_manager", "mana", {radiant = self.current_mana[radiant_id], dire = self.current_mana[dire_id]})
end


-- Time
function TurnManager:DecrementTurnTime()
	self.current_turn_time_remaining = self.current_turn_time_remaining - 1
	self:UpdateNetTableValues()
end

function TurnManager:GetTurnTime()
	return self.current_turn_time_remaining
end

function TurnManager:StartTurnCountdown()
	local timer_verifier = self.current_turn_time_remaining
	Timers:CreateTimer(1, function()
		if self.current_turn_time_remaining == timer_verifier then
			self:DecrementTurnTime()
			timer_verifier = timer_verifier - 1
			if self.current_turn_time_remaining > 0 then
				return 1
			else
				self:EndTurn()
			end
		end
	end)
end


-- Action points
function TurnManager:GetActionPoints(player_id)
	return self.current_action_points[player_id]
end

function TurnManager:SetActionPoints(player_id, points)
	self.current_action_points[player_id] = points
	self:UpdateNetTableValues()
end

function TurnManager:HasActionPoints(player_id)
	if self.current_action_points[player_id] > 0 then
		return true
	else
		return false
	end
end

-- Returns true if a point can be spent, and spends it
function TurnManager:SpendActionPoint(player_id)
	if self.current_action_points[player_id] > 0 then
		self.current_action_points[player_id] = self.current_action_points[player_id] - 1
		self:UpdateNetTableValues()
		return true
	else
		return false
	end
end


-- Mana
function TurnManager:GetMana(player_id)
	return self.current_mana[player_id]
end

function TurnManager:IncrementMana(player_id)
	self.current_mana[player_id] = math.min(self.current_mana[player_id] + 1, 10)
	self:UpdateNetTableValues()
end

function TurnManager:SpendMana(player_id, cost)
	self.current_mana[player_id] = self.current_mana[player_id] - cost
	self:UpdateNetTableValues()
end