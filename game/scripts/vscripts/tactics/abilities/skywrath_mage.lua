--	Skywrath Mage Arcane Bolt

LinkLuaModifier("modifier_tactics_arcane_bolt", "tactics/abilities/skywrath_mage", LUA_MODIFIER_MOTION_NONE)

tactics_arcane_bolt = class({})

function tactics_arcane_bolt:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_position = caster:GetBoardPosition()
		local target_position = target:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Check if the target is valid
		local valid_cast = false
		local valid_squares = Tactics:CalculateSquareArea(caster_position.x, caster_position.y, self:GetTacticsRange())
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

			-- Perform the ability
			caster:FaceTowards(target:GetAbsOrigin())
			caster:AddNewModifier(caster, self, "modifier_tactics_arcane_bolt", {duration = 1.0})
			Timers:CreateTimer(0.1, function()
				caster:EmitSound("Hero_SkywrathMage.ArcaneBolt.Cast")
				local projectile= {
					Target = target,
					Source = caster,
					Ability = self,
					EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf",
					bDodgeable = false,
					bProvidesVision = false,
					bVisibleToEnemies = true,
					bReplaceExisting = false,
					iMoveSpeed = 600,
					iVisionRadius = 0,
					iVisionTeamNumber = caster:GetTeamNumber()
				}
				ProjectileManager:CreateTrackingProjectile(projectile)
			end)
		end
	end
end

function tactics_arcane_bolt:OnProjectileHit(target, location)
	target:EmitSound("Hero_SkywrathMage.ArcaneBolt.Impact")
	CombatManager:DealDamage(self:GetCaster(), target, 200, DAMAGE_TYPE_MAGICAL)
end

function tactics_arcane_bolt:GetTacticsRangeType()
	return "square"
end

function tactics_arcane_bolt:GetTacticsRange()
	return 3
end

function tactics_arcane_bolt:GetTacticsIgnoresObstacles()
	return true
end

function tactics_arcane_bolt:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_arcane_bolt = class({})

function modifier_tactics_arcane_bolt:IsDebuff() return false end
function modifier_tactics_arcane_bolt:IsHidden() return true end
function modifier_tactics_arcane_bolt:IsPurgable() return false end
function modifier_tactics_arcane_bolt:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_arcane_bolt:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_arcane_bolt:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_arcane_bolt:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end


function modifier_tactics_arcane_bolt:OnDestroy()
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