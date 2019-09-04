--	Sand King burrowstrike

LinkLuaModifier("modifier_tactics_burrowstrike", "tactics/abilities/sand_king", LUA_MODIFIER_MOTION_NONE)

tactics_burrowstrike = class({})

function tactics_burrowstrike:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Check player and unit resources
		local valid_cast = false

		local valid_positions = Tactics:CalculateRookArea(caster_position.x, caster_position.y, self:GetTacticsRange())
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
			Tactics:SetEmpty(caster_position.x, caster_position.y)
			caster:AddNoDraw()

			-- Effects
			caster:EmitSound("Ability.SandKing_BurrowStrike")
			local burrow_pfx = ParticleManager:CreateParticle("particles/econ/items/sand_king/sandking_barren_crown/sandking_rubyspire_burrowstrike.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(burrow_pfx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(burrow_pfx, 1, target)
			ParticleManager:ReleaseParticleIndex(burrow_pfx)

			local travel_vector = Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y) - caster:GetAbsOrigin()
			local distance = travel_vector:Length2D()
			local direction = travel_vector:Normalized()
			local burrow_proj = {
				Ability = self,
				EffectName = "",
				vSpawnOrigin = caster:GetAbsOrigin(),
				fDistance = distance,
				fStartRadius = 64,
				fEndRadius = 64,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				bDeleteOnHit = false,
				vVelocity = direction * 3500 * Vector(1, 1, 0),
				bProvidesVision = false
			}
			ProjectileManager:CreateLinearProjectile(burrow_proj)

			-- Movement end
			local end_position = Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y)
			Timers:CreateTimer(distance / 3500, function()
				caster:RemoveNoDraw()
				FindClearSpaceForUnit(caster, Vector(end_position.x, end_position.y, 0), true)
				caster:SetBoardPosition(target_position.x, target_position.y)
				Tactics:SetGridContent(target_position.x, target_position.y, caster)
				caster:AddNewModifier(caster, self, "modifier_tactics_burrowstrike", {duration = 0.53})
			end)
		end
	end
end

function tactics_burrowstrike:OnProjectileHit(target, location)
	local caster = self:GetCaster()
	local knockup = {
		center_x = location.x,
		center_y = location.y,
		center_z = location.z,
		duration = 0.4,
		knockback_duration = 0.4,
		knockback_distance = 0,
		knockback_height = 450
	}

	if target then
		target:AddNewModifier(caster, self, "modifier_knockback", knockup)

		Timers:CreateTimer(knockup.duration, function()
			target:EmitSound("Hero_Lion.ImpaleTargetLand")
			CombatManager:DealDamage(caster, target, 250, DAMAGE_TYPE_MAGICAL)
		end)
	end
end

function tactics_burrowstrike:GetTacticsRangeType()
	return "rook"
end

function tactics_burrowstrike:GetTacticsRange()
	return 5
end

function tactics_burrowstrike:GetTacticsIgnoresObstacles()
	return true
end

function tactics_burrowstrike:GetTacticsCanTargetUnits()
	return false
end



modifier_tactics_burrowstrike = class({})

function modifier_tactics_burrowstrike:IsDebuff() return false end
function modifier_tactics_burrowstrike:IsHidden() return true end
function modifier_tactics_burrowstrike:IsPurgable() return false end
function modifier_tactics_burrowstrike:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_burrowstrike:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_burrowstrike:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_burrowstrike:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end


function modifier_tactics_burrowstrike:OnDestroy()
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