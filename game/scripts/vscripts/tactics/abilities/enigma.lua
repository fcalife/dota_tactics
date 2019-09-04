--	Enigma's summon eidolon

LinkLuaModifier("modifier_tactics_summon_eidolon", "tactics/abilities/enigma", LUA_MODIFIER_MOTION_NONE)

tactics_summon_eidolon = class({})

function tactics_summon_eidolon:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 2 - caster:GetManaCostReduction())

		-- Check player and unit resources
		local valid_cast = false

		local valid_positions = Tactics:CalculateQueenArea(caster_position.x, caster_position.y, self:GetTacticsRange())
		for _, valid_position in pairs(valid_positions) do
			if (valid_position.x == target_position.x) and (valid_position.y == target_position.y) and (Tactics:IsEmpty(target_position.x, target_position.y)) then
				valid_cast = true
				break
			end
		end

		valid_cast = valid_cast and TurnManager:HasActionPoints(player_id)
		valid_cast = valid_cast and (not caster:HasCastedThisTurn())
		valid_cast = valid_cast and (TurnManager:GetMana(player_id) >= mana_cost)

		-- If this cast is valid, perform the ability
		if valid_cast then

			-- Spend resources
			caster:SetHasCastedThisTurn()
			caster:ProcessCastModifiers()
			caster:SpendActionPoint()
			TurnManager:SpendMana(player_id, mana_cost)

			-- Perform the spell
			Tactics:SetPlayerBusy(player_id)
			caster:FaceTowards(target)
			caster:AddNewModifier(caster, self, "modifier_tactics_summon_eidolon", {duration = 1.0})

			Timers:CreateTimer(0.3, function()
				caster:EmitSound("Hero_Enigma.Demonic_Conversion")
				local eidolon = Tactics:SpawnUnit(target_position.x, target_position.y, "npc_tactics_eidolon", caster:GetTeam())
				eidolon:SetHealth(math.ceil(caster:GetHealth() * 0.01) * 50)
			end)
		end
	end
end

function tactics_summon_eidolon:GetTacticsRangeType()
	return "queen"
end

function tactics_summon_eidolon:GetTacticsRange()
	return 1
end

function tactics_summon_eidolon:GetTacticsIgnoresObstacles()
	return false
end

function tactics_summon_eidolon:GetTacticsCanTargetUnits()
	return false
end



modifier_tactics_summon_eidolon = class({})

function modifier_tactics_summon_eidolon:IsDebuff() return false end
function modifier_tactics_summon_eidolon:IsHidden() return true end
function modifier_tactics_summon_eidolon:IsPurgable() return false end
function modifier_tactics_summon_eidolon:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_summon_eidolon:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_summon_eidolon:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_summon_eidolon:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end


function modifier_tactics_summon_eidolon:OnDestroy()
	if IsServer() then

		-- Resolve end of cast
		local caster = self:GetParent()
		local team = caster:GetTeam()
		local world_position = caster:GetAbsOrigin()
		local player_id = caster:GetTacticsPlayerID()

		-- Resume facing the enemy
		if team == DOTA_TEAM_GOODGUYS then
			caster:FaceTowards(world_position + Vector(0, 100, 0))
		elseif team == DOTA_TEAM_BADGUYS then
			caster:FaceTowards(world_position + Vector(0, -100, 0))
		end
		Tactics:ClearPlayerBusy(player_id)
	end
end