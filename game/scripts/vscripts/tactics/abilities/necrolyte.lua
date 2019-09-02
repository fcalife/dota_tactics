--	Necro Health Pulse

LinkLuaModifier("modifier_tactics_health_pulse", "tactics/abilities/necrolyte", LUA_MODIFIER_MOTION_NONE)

tactics_health_pulse = class({})

function tactics_health_pulse:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local caster_position = caster:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 2 - caster:GetManaCostReduction())

		-- Check player and unit resources
		local valid_cast = true
		valid_cast = valid_cast and TurnManager:HasActionPoints(player_id)
		valid_cast = valid_cast and (not caster:HasCastedThisTurn())
		valid_cast = valid_cast and (TurnManager:GetMana(player_id) >= mana_cost)

		-- If this cast is valid, perform the ability
		if valid_cast then

			-- Spend resources
			caster:SetHasCastedThisTurn()
			caster:ProcessCastModifiers()
			TurnManager:SpendActionPoint(player_id)
			TurnManager:SpendMana(player_id, mana_cost)
			Tactics:SetPlayerBusy(player_id)

			-- Perform the spell
			caster:AddNewModifier(caster, self, "modifier_tactics_health_pulse", {duration = 0.77})
			caster:EmitSound("Hero_Necrolyte.DeathPulse")
			local caster_team = caster:GetTeam()

			local heal_projectile= {
				Target = caster,
				Source = caster,
				Ability = self,
				EffectName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_friend.vpcf",
				bDodgeable = false,
				bProvidesVision = false,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				iMoveSpeed = 350,
				iVisionRadius = 0,
				iVisionTeamNumber = caster:GetTeamNumber()
			}

			local target_positions = Tactics:CalculateSquareArea(caster_position.x, caster_position.y, 1)
			for _, target_position in pairs(target_positions) do
				if Tactics:GetGridUnitTeam(target_position.x, target_position.y) == caster_team then
					local target = Tactics:GetGridUnit(target_position.x, target_position.y)
					heal_projectile.Target = target
					ProjectileManager:CreateTrackingProjectile(heal_projectile)
				end
			end
		end
	end
end

function tactics_health_pulse:OnProjectileHit(target, location)
	CombatManager:ApplyHealing(self:GetCaster(), target, 150)
end

function tactics_health_pulse:GetTacticsRangeType()
	return "queen"
end

function tactics_health_pulse:GetTacticsRange()
	return 1
end

function tactics_health_pulse:GetTacticsIgnoresObstacles()
	return true
end

function tactics_health_pulse:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_health_pulse = class({})

function modifier_tactics_health_pulse:IsDebuff() return false end
function modifier_tactics_health_pulse:IsHidden() return true end
function modifier_tactics_health_pulse:IsPurgable() return false end
function modifier_tactics_health_pulse:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_health_pulse:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_health_pulse:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_health_pulse:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end


function modifier_tactics_health_pulse:OnDestroy()
	if IsServer() then
		local unit = self:GetParent()
		local player_id = unit:GetTacticsPlayerID()
		Tactics:ClearPlayerBusy(player_id)
	end
end