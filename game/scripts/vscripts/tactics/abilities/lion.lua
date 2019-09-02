--	Lion Earth Spike

LinkLuaModifier("modifier_tactics_earth_spike", "tactics/abilities/lion", LUA_MODIFIER_MOTION_NONE)

tactics_earth_spike = class({})

function tactics_earth_spike:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Check player and unit resources
		local valid_cast = false

		local valid_positions = Tactics:CalculateRookArea(caster_position.x, caster_position.y, 3)
		for _, valid_position in pairs(valid_positions) do
			if (valid_position.x == target_position.x) and (valid_position.y == target_position.y) then
				valid_cast = true
				break
			end
		end

		-- Prevent self-cast
		if (caster_position.x == target_position.x) and (caster_position.y == target_position.y) then
			valid_cast = false
		end

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

			-- Perform the spell
			Tactics:SetPlayerBusy(player_id)
			caster:AddNewModifier(caster, self, "modifier_tactics_earth_spike", {duration = 0.4})
			caster:EmitSound("Hero_Lion.Impale")

			local direction = (Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y) - caster:GetAbsOrigin()):Normalized()
			local spike_proj = {
				Ability = self,
				EffectName = "particles/econ/items/lion/lion_ti9/lion_spell_impale_ti9.vpcf",
				vSpawnOrigin = caster:GetAbsOrigin(),
				fDistance = 768,
				fStartRadius = 64,
				fEndRadius = 64,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				bDeleteOnHit = false,
				vVelocity = direction * 2500 * Vector(1, 1, 0),
				bProvidesVision = false,
				ExtraData = {}
			}
			ProjectileManager:CreateLinearProjectile(spike_proj)
		end
	end
end

function tactics_earth_spike:OnProjectileHit(target, location)
	local caster = self:GetCaster()
	local knockup = {
		center_x = location.x,
		center_y = location.y,
		center_z = location.z,
		duration = 0.35,
		knockback_duration = 0.35,
		knockback_distance = 0,
		knockback_height = 450
	}

	if target then
		target:AddNewModifier(caster, self, "modifier_knockback", knockup)
		target:EmitSound("Hero_Lion.ImpaleHitTarget")

		Timers:CreateTimer(knockup.duration, function()
			target:EmitSound("Hero_Lion.ImpaleTargetLand")
			CombatManager:DealDamage(caster, target, 200, DAMAGE_TYPE_MAGICAL)
		end)
	end
end

function tactics_earth_spike:GetTacticsRangeType()
	return "rook"
end

function tactics_earth_spike:GetTacticsRange()
	return 3
end

function tactics_earth_spike:GetTacticsIgnoresObstacles()
	return true
end

function tactics_earth_spike:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_earth_spike = class({})

function modifier_tactics_earth_spike:IsDebuff() return false end
function modifier_tactics_earth_spike:IsHidden() return true end
function modifier_tactics_earth_spike:IsPurgable() return false end
function modifier_tactics_earth_spike:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_earth_spike:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_earth_spike:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_earth_spike:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end


function modifier_tactics_earth_spike:OnDestroy()
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