--	Venomancer Poison Nova

LinkLuaModifier("modifier_tactics_poison_nova", "tactics/abilities/venomancer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_poison_nova_debuff", "tactics/abilities/venomancer", LUA_MODIFIER_MOTION_NONE)

tactics_poison_nova = class({})

function tactics_poison_nova:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local caster_position = caster:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

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
			caster:SpendActionPoint()
			TurnManager:SpendMana(player_id, mana_cost)

			-- Perform the spell
			Tactics:SetPlayerBusy(player_id)
			caster:AddNewModifier(caster, self, "modifier_tactics_poison_nova", {duration = 0.87})

			caster:EmitSound("Hero_Venomancer.PoisonNova")

			local nova_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(nova_pfx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(nova_pfx, 1, Vector(100, 1, 400))
			ParticleManager:ReleaseParticleIndex(nova_pfx)

			local target_positions = Tactics:CalculateSquareArea(caster_position.x, caster_position.y, 1)
			for _, target_position in pairs(target_positions) do
				local target_team = Tactics:GetGridUnitTeam(target_position.x, target_position.y)
				if target_team and target_team ~= caster:GetTeam() then
					local target = Tactics:GetGridUnit(target_position.x, target_position.y)
					target:AddNewModifier(caster, self, "modifier_tactics_poison_nova_debuff", {})
				end
			end
		end
	end
end

function tactics_poison_nova:GetTacticsRangeType()
	return "queen"
end

function tactics_poison_nova:GetTacticsRange()
	return 1
end

function tactics_poison_nova:GetTacticsIgnoresObstacles()
	return false
end

function tactics_poison_nova:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_poison_nova = class({})

function modifier_tactics_poison_nova:IsDebuff() return false end
function modifier_tactics_poison_nova:IsHidden() return true end
function modifier_tactics_poison_nova:IsPurgable() return false end
function modifier_tactics_poison_nova:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_poison_nova:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_poison_nova:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_poison_nova:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end


function modifier_tactics_poison_nova:OnDestroy()
	if IsServer() then
		Tactics:ClearPlayerBusy(self:GetCaster():GetTacticsPlayerID())
	end
end



modifier_tactics_poison_nova_debuff = class({})

function modifier_tactics_poison_nova_debuff:IsDebuff() return true end
function modifier_tactics_poison_nova_debuff:IsHidden() return false end
function modifier_tactics_poison_nova_debuff:IsPurgable() return false end
function modifier_tactics_poison_nova_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_tactics_poison_nova_debuff:OnCreated(keys)
	if IsServer() then
		self:GetParent():EmitSound("Hero_Venomancer.PoisonNovaImpact")
	end
end

function modifier_tactics_poison_nova_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end