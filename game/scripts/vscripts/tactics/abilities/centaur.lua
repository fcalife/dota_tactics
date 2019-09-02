--	Centaur Hoof Stomp

LinkLuaModifier("modifier_tactics_hoof_stomp", "tactics/abilities/centaur", LUA_MODIFIER_MOTION_NONE)

tactics_hoof_stomp = class({})

function tactics_hoof_stomp:OnSpellStart()
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

			-- Perform the spell
			Tactics:SetPlayerBusy(player_id)
			caster:AddNewModifier(caster, self, "modifier_tactics_hoof_stomp", {duration = 0.5})
		end
	end
end

function tactics_hoof_stomp:GetTacticsRangeType()
	return "queen"
end

function tactics_hoof_stomp:GetTacticsRange()
	return 1
end

function tactics_hoof_stomp:GetTacticsIgnoresObstacles()
	return true
end

function tactics_hoof_stomp:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_hoof_stomp = class({})

function modifier_tactics_hoof_stomp:IsDebuff() return false end
function modifier_tactics_hoof_stomp:IsHidden() return true end
function modifier_tactics_hoof_stomp:IsPurgable() return false end
function modifier_tactics_hoof_stomp:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_hoof_stomp:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_hoof_stomp:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_hoof_stomp:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end


function modifier_tactics_hoof_stomp:OnDestroy()
	if IsServer() then

		local caster = self:GetCaster()
		local caster_position = caster:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local damage = 200

		caster:EmitSound("Hero_Centaur.HoofStomp")

		local stomp_pfx = ParticleManager:CreateParticle("particles/econ/items/centaur/centaur_ti6/centaur_ti6_warstomp.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(stomp_pfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(stomp_pfx, 1, Vector(400, 0, 0))
		ParticleManager:ReleaseParticleIndex(stomp_pfx)

		local target_positions = Tactics:CalculateSquareArea(caster_position.x, caster_position.y, 1)
		for _, target_position in pairs(target_positions) do
			local target_team = Tactics:GetGridUnitTeam(target_position.x, target_position.y)
			if target_team and target_team ~= caster:GetTeam() then
				local target = Tactics:GetGridUnit(target_position.x, target_position.y)
				CombatManager:DealDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL)
			end
		end
		Tactics:ClearPlayerBusy(player_id)
	end
end