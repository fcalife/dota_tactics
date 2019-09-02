LinkLuaModifier("modifier_tactics_hidden_hero", "tactics/modifier/universal_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_obstacle", "tactics/modifier/universal_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_unit", "tactics/modifier/universal_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_moving", "tactics/modifier/universal_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_attacking", "tactics/modifier/universal_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_already_moved_this_turn", "tactics/modifier/universal_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_already_casted_this_turn", "tactics/modifier/universal_modifiers", LUA_MODIFIER_MOTION_NONE)

modifier_tactics_hidden_hero = class({})

function modifier_tactics_hidden_hero:IsDebuff() return true end
function modifier_tactics_hidden_hero:IsHidden() return true end
function modifier_tactics_hidden_hero:IsPurgable() return false end
function modifier_tactics_hidden_hero:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_hidden_hero:OnCreated(keys)
	if IsServer() then
		self:GetParent():AddNoDraw()
	end
end

function modifier_tactics_hidden_hero:CheckState()
	local states = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}
	return states
end



modifier_tactics_obstacle = class({})

function modifier_tactics_obstacle:IsDebuff() return false end
function modifier_tactics_obstacle:IsHidden() return true end
function modifier_tactics_obstacle:IsPurgable() return false end
function modifier_tactics_obstacle:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_obstacle:CheckState()
	local states = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
	return states
end



modifier_tactics_moving = class({})

function modifier_tactics_moving:IsDebuff() return true end
function modifier_tactics_moving:IsHidden() return true end
function modifier_tactics_moving:IsPurgable() return false end
function modifier_tactics_moving:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_moving:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_moving:OnCreated(keys)
	if IsServer() then
		if keys.attack_target then
			self.target = keys.attack_target
			self:GetParent():PlayAttackMoveLine()
		else
			self:GetParent():PlayMovementLine()
		end
	end
end

function modifier_tactics_moving:OnDestroy()
	if IsServer() then

		local unit = self:GetParent()

		-- If there is a target to attack, do so
		if self.target then
			unit:AddNewModifier(unit, nil, "modifier_tactics_attacking", {duration = 1.0, attack_target = self.target})

		-- Else, resolve end of movement
		else
			local team = unit:GetTeam()
			local player_id = unit:GetTacticsPlayerID()
			local world_position = unit:GetAbsOrigin()
			if team == DOTA_TEAM_GOODGUYS then
				unit:FaceTowards(world_position + Vector(0, 100, 0))
			elseif team == DOTA_TEAM_BADGUYS then
				unit:FaceTowards(world_position + Vector(0, -100, 0))
			end

			local grid_position = Tactics:GetGridCoordinatesFromWorld(world_position.x, world_position.y)
			unit:SetBoardPosition(grid_position.x, grid_position.y)
			Tactics:SetGridContent(grid_position.x, grid_position.y, unit)
			Tactics:ClearLeftMousePressed(player_id)
			Tactics:ClearRightMousePressed(player_id)
			Tactics:ClearPlayerBusy(player_id)
		end
	end
end



modifier_tactics_attacking = class({})

function modifier_tactics_attacking:IsDebuff() return true end
function modifier_tactics_attacking:IsHidden() return true end
function modifier_tactics_attacking:IsPurgable() return false end
function modifier_tactics_attacking:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_attacking:OnCreated(keys)
	if IsServer() then
		CombatManager:PerformMoveAttack(self:GetParent(), EntIndexToHScript(keys.attack_target))
	end
end

function modifier_tactics_attacking:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_attacking:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_attacking:GetOverrideAnimation()
	return ACT_DOTA_ATTACK
end


function modifier_tactics_attacking:OnDestroy()
	if IsServer() then

		-- Resolve end of movement
		local unit = self:GetParent()
		local team = unit:GetTeam()
		local player_id = unit:GetTacticsPlayerID()
		local world_position = unit:GetAbsOrigin()
		if team == DOTA_TEAM_GOODGUYS then
			unit:FaceTowards(world_position + Vector(0, 100, 0))
		elseif team == DOTA_TEAM_BADGUYS then
			unit:FaceTowards(world_position + Vector(0, -100, 0))
		end

		local grid_position = Tactics:GetGridCoordinatesFromWorld(world_position.x, world_position.y)
		unit:SetBoardPosition(grid_position.x, grid_position.y)
		Tactics:SetGridContent(grid_position.x, grid_position.y, unit)
		Tactics:ClearLeftMousePressed(player_id)
		Tactics:ClearRightMousePressed(player_id)
		Tactics:ClearPlayerBusy(player_id)
	end
end



modifier_tactics_already_moved_this_turn = class({})

function modifier_tactics_already_moved_this_turn:IsDebuff() return true end
function modifier_tactics_already_moved_this_turn:IsHidden() return true end
function modifier_tactics_already_moved_this_turn:IsPurgable() return false end
function modifier_tactics_already_moved_this_turn:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end



modifier_tactics_already_casted_this_turn = class({})

function modifier_tactics_already_casted_this_turn:IsDebuff() return true end
function modifier_tactics_already_casted_this_turn:IsHidden() return true end
function modifier_tactics_already_casted_this_turn:IsPurgable() return false end
function modifier_tactics_already_casted_this_turn:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end



modifier_tactics_unit = class({})

function modifier_tactics_unit:IsDebuff() return true end
function modifier_tactics_unit:IsHidden() return true end
function modifier_tactics_unit:IsPurgable() return false end
function modifier_tactics_unit:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_unit:OnCreated(keys)
	if IsServer() then
		local unit_name = self:GetParent():GetUnitName()
		if unit_name == "npc_tactics_king_radiant" then
			self.is_king = true
			self.winner_on_death = DOTA_TEAM_BADGUYS
		elseif unit_name == "npc_tactics_king_dire" then
			self.is_king = true
			self.winner_on_death = DOTA_TEAM_GOODGUYS
		end
	end
end

function modifier_tactics_unit:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_tactics_unit:OnDeath(keys)
	if IsServer() then
		if keys.unit == self:GetParent() then
			local position = keys.unit:GetBoardPosition()
			Tactics:SetEmpty(position.x, position.y)

			-- Trigger victory if this was a king
			if self.is_king then
				TurnManager:EndGameWithWinner(self.winner_on_death)
			end
		end
	end
end