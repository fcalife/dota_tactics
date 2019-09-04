--	Pawn attack

LinkLuaModifier("modifier_tactics_pawn_attack", "tactics/abilities/pawn", LUA_MODIFIER_MOTION_NONE)

tactics_pawn_attack = class({})

function tactics_pawn_attack:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_position = caster:GetBoardPosition()
		local target_position = target:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()

		-- Check if the target is valid
		local valid_cast = false
		if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
			if (target_position.y == caster_position.y + 1) and ((target_position.x == caster_position.x - 1) or (target_position.x == caster_position.x + 1)) then
				valid_cast = true
			end
		elseif caster:GetTeam() == DOTA_TEAM_BADGUYS then
			if (target_position.y == caster_position.y - 1) and ((target_position.x == caster_position.x - 1) or (target_position.x == caster_position.x + 1)) then
				valid_cast = true
			end
		end

		-- Check player and unit resources
		valid_cast = valid_cast and TurnManager:HasActionPoints(player_id)
		valid_cast = valid_cast and (not caster:HasCastedThisTurn())

		-- If this cast is valid, perform the ability
		if valid_cast then

			-- Spend resources
			caster:SetHasCastedThisTurn()
			caster:ProcessCastModifiers()
			caster:SpendActionPoint()

			-- Perform the attack
			caster:FaceTowards(target:GetAbsOrigin())
			CombatManager:PerformMoveAttack(caster, target)
			caster:AddNewModifier(caster, self, "modifier_tactics_pawn_attack", {duration = 1.0})

			-- Prevent caster from acting while the animation plays
			Tactics:SetPlayerBusy(player_id)
		end
	end
end

function tactics_pawn_attack:GetTacticsRangeType()
	return "pawn"
end

function tactics_pawn_attack:GetTacticsRange()
	return 1
end

function tactics_pawn_attack:GetTacticsIgnoresObstacles()
	return false
end

function tactics_pawn_attack:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_pawn_attack = class({})

function modifier_tactics_pawn_attack:IsDebuff() return false end
function modifier_tactics_pawn_attack:IsHidden() return true end
function modifier_tactics_pawn_attack:IsPurgable() return false end
function modifier_tactics_pawn_attack:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_pawn_attack:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_pawn_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_pawn_attack:GetOverrideAnimation()
	return ACT_DOTA_ATTACK
end


function modifier_tactics_pawn_attack:OnDestroy()
	if IsServer() then

		-- Resolve end of cast
		local unit = self:GetParent()
		local team = unit:GetTeam()
		local player_id = unit:GetTacticsPlayerID()
		local world_position = unit:GetAbsOrigin()
		if team == DOTA_TEAM_GOODGUYS then
			unit:FaceTowards(world_position + Vector(0, 100, 0))
		elseif team == DOTA_TEAM_BADGUYS then
			unit:FaceTowards(world_position + Vector(0, -100, 0))
		end
		Tactics:ClearPlayerBusy(player_id)
	end
end