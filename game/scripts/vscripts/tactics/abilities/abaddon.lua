--	Abaddon aphotic shield

LinkLuaModifier("modifier_tactics_shield", "tactics/abilities/abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_shield_effect", "tactics/abilities/abaddon", LUA_MODIFIER_MOTION_NONE)

tactics_shield = class({})

function tactics_shield:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_position = caster:GetBoardPosition()
		local target_position = target:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Check if the target is valid
		local valid_cast = false
		local valid_squares = Tactics:CalculateQueenArea(caster_position.x, caster_position.y, self:GetTacticsRange())
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
			caster:AddNewModifier(caster, self, "modifier_tactics_shield", {duration = 0.92})
			Timers:CreateTimer(0.25, function()
				caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")
				local projectile= {
					Target = target,
					Source = caster,
					Ability = self,
					EffectName = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf",
					bDodgeable = false,
					bProvidesVision = false,
					bVisibleToEnemies = true,
					bReplaceExisting = false,
					iMoveSpeed = 1300,
					iVisionRadius = 0,
					iVisionTeamNumber = caster:GetTeamNumber()
				}
				ProjectileManager:CreateTrackingProjectile(projectile)
			end)
		end
	end
end

function tactics_shield:OnProjectileHit(target, location)
	target:EmitSound("Hero_Abaddon.AphoticShield.Cast")
	target:AddNewModifier(self:GetCaster(), self, "modifier_tactics_shield_effect", {}):IncrementStackCount()
end

function tactics_shield:GetTacticsRangeType()
	return "queen"
end

function tactics_shield:GetTacticsRange()
	return 2
end

function tactics_shield:GetTacticsIgnoresObstacles()
	return true
end

function tactics_shield:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_shield = class({})

function modifier_tactics_shield:IsDebuff() return false end
function modifier_tactics_shield:IsHidden() return true end
function modifier_tactics_shield:IsPurgable() return false end
function modifier_tactics_shield:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_shield:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_shield:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end


function modifier_tactics_shield:OnDestroy()
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



modifier_tactics_shield_effect = class({})

function modifier_tactics_shield_effect:IsDebuff() return false end
function modifier_tactics_shield_effect:IsHidden() return false end
function modifier_tactics_shield_effect:IsPurgable() return false end
function modifier_tactics_shield_effect:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_shield_effect:OnCreated(keys)
	if IsServer() then
		local parent = self:GetParent()
		local radius = 150
		local particle = "particles/prismatic_shield.vpcf"

		if parent:GetUnitName() == "npc_tactics_pawn_radiant" or parent:GetUnitName() == "npc_tactics_pawn_dire" then
			radius = 120
			particle = "particles/prismatic_shield_small.vpcf"
		elseif parent:GetUnitName() == "npc_tactics_king_radiant" or parent:GetUnitName() == "npc_tactics_king_dire" then
			radius = 175
			particle = "particles/prismatic_shield_big.vpcf"
		end

		self.shield_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControl(self.shield_pfx, 0, parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.shield_pfx, 1, Vector(radius, 0, 0))
	end
end

function modifier_tactics_shield_effect:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.shield_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.shield_pfx)
	end
end

function modifier_tactics_shield_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_tactics_shield_effect:GetModifierMagical_ConstantBlock()
	return 10000
end

function modifier_tactics_shield_effect:GetModifierPhysical_ConstantBlock()
	return 10000
end

function modifier_tactics_shield_effect:OnTooltip()
	return self:GetStackCount()
end

function modifier_tactics_shield_effect:OnTakeDamage(keys)
	if IsServer() then
		if keys.unit == self:GetParent() then
			local parent = self:GetParent()
			parent:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
			self:DecrementStackCount()
			if self:GetStackCount() <= 0 then
				local blast_pfx = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(blast_pfx, 0, parent:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(blast_pfx)
				self:Destroy()
			end
		end
	end
end