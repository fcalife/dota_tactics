--	Ursa fury swipes

LinkLuaModifier("modifier_tactics_fury_swipes", "tactics/abilities/ursa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_fury_swipes_effect", "tactics/abilities/ursa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_fury_swipes_attack", "tactics/abilities/ursa", LUA_MODIFIER_MOTION_NONE)

tactics_fury_swipes = class({})

function tactics_fury_swipes:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_position = caster:GetBoardPosition()
		local target_position = target:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())
		local damage = 150 + 50 * caster:FindModifierByName("modifier_tactics_fury_swipes"):GetStackCount()

		-- Check if the target is valid
		local valid_cast = false
		local valid_squares = Tactics:CalculateRookArea(caster_position.x, caster_position.y, self:GetTacticsRange())
		for _, grid_square in pairs(valid_squares) do
			if (grid_square.x == target_position.x) and (grid_square.y == target_position.y) then
				valid_cast = true
				break
			end
		end

		-- Check player and unit resources
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
			Tactics:SetPlayerBusy(player_id)

			-- Perform the attack
			caster:EmitSound("Hero_Ursa.Enrage")
			caster:FaceTowards(target:GetAbsOrigin())
			caster:AddNewModifier(caster, self, "modifier_tactics_fury_swipes_attack", {duration = 1.0})
			caster:AddNewModifier(caster, self, "modifier_tactics_fury_swipes_effect", {})
			Timers:CreateTimer(caster:GetAttackPoint(), function()
				caster:EmitSound("Hero_Ursa.Attack")
				CombatManager:DealDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL)
			end)

			-- Grant a stack of Fury Swipes
			caster:FindModifierByName("modifier_tactics_fury_swipes"):IncrementStackCount()
		end
	end
end

function tactics_fury_swipes:GetIntrinsicModifierName() 
	return "modifier_tactics_fury_swipes"
end

function tactics_fury_swipes:GetTacticsRangeType()
	return "rook"
end

function tactics_fury_swipes:GetTacticsRange()
	return 1
end

function tactics_fury_swipes:GetTacticsIgnoresObstacles()
	return false
end

function tactics_fury_swipes:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_fury_swipes_attack = class({})

function modifier_tactics_fury_swipes_attack:IsDebuff() return false end
function modifier_tactics_fury_swipes_attack:IsHidden() return true end
function modifier_tactics_fury_swipes_attack:IsPurgable() return false end
function modifier_tactics_fury_swipes_attack:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_fury_swipes_attack:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_fury_swipes_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_fury_swipes_attack:GetOverrideAnimation()
	return ACT_DOTA_ATTACK
end


function modifier_tactics_fury_swipes_attack:OnDestroy()
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



modifier_tactics_fury_swipes = class({})

function modifier_tactics_fury_swipes:IsDebuff() return false end
function modifier_tactics_fury_swipes:IsHidden() return false end
function modifier_tactics_fury_swipes:IsPurgable() return false end
function modifier_tactics_fury_swipes:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_fury_swipes:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_MODEL_SCALE
	}
	return funcs
end

function modifier_tactics_fury_swipes:GetModifierModelScale()
	return 10 * self:GetStackCount()
end

function modifier_tactics_fury_swipes:OnTooltip()
	return 50 * self:GetStackCount()
end



modifier_tactics_fury_swipes_effect = class({})

function modifier_tactics_fury_swipes_effect:IsDebuff() return false end
function modifier_tactics_fury_swipes_effect:IsHidden() return true end
function modifier_tactics_fury_swipes_effect:IsPurgable() return false end
function modifier_tactics_fury_swipes_effect:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_tactics_fury_swipes_effect:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_tactics_fury_swipes_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end