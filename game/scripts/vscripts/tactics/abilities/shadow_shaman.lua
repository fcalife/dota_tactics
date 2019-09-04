--	Shadow Shaman mass serpent ward

LinkLuaModifier("modifier_tactics_serpent_ward", "tactics/abilities/shadow_shaman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_serpent_ward_idle", "tactics/abilities/shadow_shaman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_serpent_ward_attack", "tactics/abilities/shadow_shaman", LUA_MODIFIER_MOTION_NONE)

tactics_serpent_ward = class({})

function tactics_serpent_ward:OnSpellStart()
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
			caster:AddNewModifier(caster, self, "modifier_tactics_serpent_ward", {duration = 1.27})

			Timers:CreateTimer(0.3, function()
				caster:EmitSound("Hero_ShadowShaman.SerpentWard")
				local ward = Tactics:SpawnUnit(target_position.x, target_position.y, "npc_tactics_serpent_ward", caster:GetTeam())
				ward:AddNewModifier(caster, self, "modifier_tactics_serpent_ward_idle", {})
			end)
		end
	end
end

function tactics_serpent_ward:GetTacticsRangeType()
	return "queen"
end

function tactics_serpent_ward:GetTacticsRange()
	return 1
end

function tactics_serpent_ward:GetTacticsIgnoresObstacles()
	return false
end

function tactics_serpent_ward:GetTacticsCanTargetUnits()
	return false
end



modifier_tactics_serpent_ward = class({})

function modifier_tactics_serpent_ward:IsDebuff() return false end
function modifier_tactics_serpent_ward:IsHidden() return true end
function modifier_tactics_serpent_ward:IsPurgable() return false end
function modifier_tactics_serpent_ward:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_serpent_ward:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_serpent_ward:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_serpent_ward:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end


function modifier_tactics_serpent_ward:OnDestroy()
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



modifier_tactics_serpent_ward_idle = class({})

function modifier_tactics_serpent_ward_idle:IsDebuff() return false end
function modifier_tactics_serpent_ward_idle:IsHidden() return true end
function modifier_tactics_serpent_ward_idle:IsPurgable() return false end
function modifier_tactics_serpent_ward_idle:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_serpent_ward_idle:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_serpent_ward_idle:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_serpent_ward_idle:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end



modifier_tactics_serpent_ward_attack = class({})

function modifier_tactics_serpent_ward_attack:IsDebuff() return false end
function modifier_tactics_serpent_ward_attack:IsHidden() return true end
function modifier_tactics_serpent_ward_attack:IsPurgable() return false end
function modifier_tactics_serpent_ward_attack:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_serpent_ward_attack:OnCreated(keys)
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_tactics_serpent_ward_idle")
	end
end

function modifier_tactics_serpent_ward_attack:OnDestroy()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_tactics_serpent_ward_idle", {})
	end
end


function modifier_tactics_serpent_ward_attack:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_serpent_ward_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_serpent_ward_attack:GetOverrideAnimation()
	return ACT_DOTA_ATTACK
end