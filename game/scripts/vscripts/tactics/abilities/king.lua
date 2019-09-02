--	Abaddon aphotic shield

LinkLuaModifier("modifier_tactics_king_healing", "tactics/abilities/king", LUA_MODIFIER_MOTION_NONE)

tactics_king_healing = class({})

function tactics_king_healing:OnSpellStart()
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
			TurnManager:SpendActionPoint(player_id)
			TurnManager:SpendMana(player_id, mana_cost)
			Tactics:SetPlayerBusy(player_id)

			-- Perform the ability
			caster:FaceTowards(target:GetAbsOrigin())
			caster:AddNewModifier(caster, self, "modifier_tactics_king_healing", {duration = 1.1})
			Timers:CreateTimer(1.1, function()
				caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
				local projectile= {
					Target = target,
					Source = caster,
					Ability = self,
					EffectName = "particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf",
					bDodgeable = false,
					bProvidesVision = false,
					bVisibleToEnemies = true,
					bReplaceExisting = false,
					iMoveSpeed = 1800,
					iVisionRadius = 0,
					iVisionTeamNumber = caster:GetTeamNumber()
				}
				ProjectileManager:CreateTrackingProjectile(projectile)
			end)
		end
	end
end

function tactics_king_healing:OnProjectileHit(target, location)
	CombatManager:ApplyHealing(self:GetCaster(), target, 150)
	target:EmitSound("Hero_Omniknight.Purification")
	local heal_pfx = ParticleManager:CreateParticle("particles/king_heal_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(heal_pfx, 0, location)
	ParticleManager:SetParticleControl(heal_pfx, 1, Vector(300, 300, 300))
	ParticleManager:SetParticleControl(heal_pfx, 2, Vector(300, 300, 300))
	ParticleManager:SetParticleControl(heal_pfx, 3, location)
	ParticleManager:ReleaseParticleIndex(heal_pfx)
end

function tactics_king_healing:GetTacticsRangeType()
	return "square"
end

function tactics_king_healing:GetTacticsRange()
	return 8
end

function tactics_king_healing:GetTacticsIgnoresObstacles()
	return true
end

function tactics_king_healing:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_king_healing = class({})

function modifier_tactics_king_healing:IsDebuff() return false end
function modifier_tactics_king_healing:IsHidden() return true end
function modifier_tactics_king_healing:IsPurgable() return false end
function modifier_tactics_king_healing:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_king_healing:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_king_healing:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
	return funcs
end

function modifier_tactics_king_healing:GetOverrideAnimation()
	return ACT_DOTA_DIE
end

function modifier_tactics_king_healing:GetOverrideAnimationRate()
	return 0.45
end

function modifier_tactics_king_healing:OnDestroy()
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