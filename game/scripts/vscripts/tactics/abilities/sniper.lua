--	Sniper Assassinate

LinkLuaModifier("modifier_tactics_assassinate", "tactics/abilities/sniper", LUA_MODIFIER_MOTION_NONE)

tactics_assassinate = class({})

function tactics_assassinate:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Check player and unit resources
		local valid_cast = false

		local valid_positions = Tactics:CalculateRookPath(caster_position.x, caster_position.y, self:GetTacticsRange(), player_id)
		for _, valid_position in pairs(valid_positions) do
			if (valid_position.x == target_position.x) and (valid_position.y == target_position.y) then
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
			TurnManager:SpendActionPoint(player_id)
			TurnManager:SpendMana(player_id, mana_cost)

			-- Perform the spell
			Tactics:SetPlayerBusy(player_id)
			caster:FaceTowards(target)
			caster:AddNewModifier(caster, self, "modifier_tactics_assassinate", {target_x = target_position.x, target_y = target_position.y, duration = 2.5})
			caster:EmitSound("Ability.AssassinateLoad")
		end
	end
end

function tactics_assassinate:OnProjectileHit(target, location)
	if IsServer() and target then
		target:EmitSound("Hero_Sniper.AssassinateDamage")
		CombatManager:DealDamage(self:GetCaster(), target, 200, DAMAGE_TYPE_MAGICAL)
		return true
	end
end

function tactics_assassinate:OnProjectileThink(location)
	if IsServer() and location then
		local grid_location = Tactics:GetGridCoordinatesFromWorld(location.x, location.y)
		if Tactics:IsObstacle(grid_location.x, grid_location.y) and self.bullet_proj then
			ProjectileManager:DestroyLinearProjectile(self.bullet_proj)
		end
	end
end

function tactics_assassinate:GetTacticsRangeType()
	return "rook"
end

function tactics_assassinate:GetTacticsRange()
	return 12
end

function tactics_assassinate:GetTacticsIgnoresObstacles()
	return false
end

function tactics_assassinate:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_assassinate = class({})

function modifier_tactics_assassinate:IsDebuff() return false end
function modifier_tactics_assassinate:IsHidden() return true end
function modifier_tactics_assassinate:IsPurgable() return false end
function modifier_tactics_assassinate:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_assassinate:OnCreated(keys)
	if IsServer() then
		Timers:CreateTimer(1.0, function()

			-- Resolve end of cast
			local caster = self:GetParent()
			local ability = self:GetAbility()
			local player_id = caster:GetTacticsPlayerID()
			caster:EmitSound("Ability.Assassinate")
			caster:EmitSound("Hero_Sniper.AssassinateProjectile")

			-- Projectile
			local direction = (Tactics:GetWorldCoordinatesFromGrid(keys.target_x, keys.target_y) - caster:GetAbsOrigin()):Normalized()
			local bullet_proj = {
				Ability = ability,
				EffectName = "particles/sniper_assassinate.vpcf",
				vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
				fDistance = 3072,
				fStartRadius = 64,
				fEndRadius = 64,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				bDeleteOnHit = true,
				vVelocity = direction * 3000 * Vector(1, 1, 0),
				bProvidesVision = false,
				ExtraData = {}
			}
			ability.bullet_proj = ProjectileManager:CreateLinearProjectile(bullet_proj)
			Tactics:ClearPlayerBusy(player_id)
		end)
	end
end

function modifier_tactics_assassinate:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_assassinate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
	return funcs
end

function modifier_tactics_assassinate:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function modifier_tactics_assassinate:GetOverrideAnimationRate()
	return 2
end


function modifier_tactics_assassinate:OnDestroy()
	if IsServer() then

		-- Resolve end of cast
		local caster = self:GetParent()
		local team = caster:GetTeam()
		local world_position = caster:GetAbsOrigin()

		-- Resume facing the enemy
		if team == DOTA_TEAM_GOODGUYS then
			caster:FaceTowards(world_position + Vector(0, 100, 0))
		elseif team == DOTA_TEAM_BADGUYS then
			caster:FaceTowards(world_position + Vector(0, -100, 0))
		end
	end
end