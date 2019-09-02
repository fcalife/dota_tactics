-- Turn managing functions

if CombatManager == nil then
	_G.CombatManager = class({})
end

-- Core dota tactics functions
function CombatManager:Init()
	print(" --- Initializing combat manager...")	
end

-- Basic functions
function CombatManager:PerformMoveAttack(attacker, target)

	-- Perform attack
	Timers:CreateTimer(attacker:GetAttackPoint(), function()
		if target:HasModifier("modifier_tactics_shield_effect") then
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, attacker:GetAverageTrueAttackDamage(target), nil)
		else
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, attacker:GetAverageTrueAttackDamage(target), nil)
		end
		attacker:PerformAttack(target, true, true, true, false, true, false, false)
		CombatManager:PlayDamageEffect(target)
	end)
end

function CombatManager:PerformTurnEffects()
	local current_turn_team = TurnManager:GetCurrentTurnTeam()
	local units = Tactics:GetAllUnits()

	for _, unit in pairs(units) do
		local unit_team = unit:GetTeam()
		local unit_modifiers = unit:FindAllModifiers()
		for _, unit_modifier in pairs(unit_modifiers) do

			-- Ring of Health
			if unit_modifier:GetName() == "modifier_tactics_ring_of_health" and unit_team ~= current_turn_team then
				CombatManager:ApplyHealing(unit, unit, 50)
			end

			-- Serpent Ward attack
			if unit_modifier:GetName() == "modifier_tactics_serpent_ward_idle" and unit_team ~= current_turn_team then
				unit:EmitSound("Hero_ShadowShaman.SerpentWard")
				unit:AddNewModifier(unit, nil, "modifier_tactics_serpent_ward_attack", {duration = 1})
				local ward_position = unit:GetBoardPosition()
				for i = -1, 1 do
					for j = -1, 1 do
						local enemy = Tactics:GetGridUnit(ward_position.x + i, ward_position.y + j)
						if enemy and enemy:GetTeam() ~= unit_team then
							CombatManager:PerformMoveAttack(unit, enemy)
						end
					end
				end
			end

			-- Venomancer poison
			if unit_modifier:GetName() == "modifier_tactics_poison_nova_debuff" and unit_team == current_turn_team then
				unit:EmitSound("Hero_Venomancer.PoisonNovaImpact")
				CombatManager:DealDamage(unit_modifier:GetCaster(), unit, 50, DAMAGE_TYPE_MAGICAL)
			end

			-- Dazzle shallow grave
			if unit_modifier:GetName() == "modifier_tactics_shallow_grave_effect" and unit_team == current_turn_team then
				unit:RemoveModifierByName("modifier_tactics_shallow_grave_effect")
			end

			-- Respawn runes
			for x = 1, 12 do
				for y = 1, 12 do
					if Tactics:IsRune(x, y) then
						Tactics:SpawnRune(x, y)
					end
				end
			end
		end
	end
end

function CombatManager:DealDamage(attacker, target, damage, damage_type)
	if target:HasModifier("modifier_tactics_shield_effect") then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, target, damage, nil)
	else
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damage, nil)
	end
	ApplyDamage({attacker = attacker, victim = target, damage = damage, damage_type = damage_type})
	CombatManager:PlayDamageEffect(target)
end

function CombatManager:ApplyHealing(caster, target, heal)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL , target, heal, nil)
	target:Heal(heal, caster)
end

function CombatManager:PlayDamageEffect(target)
	local damage_pfx = ParticleManager:CreateParticle("particles/attack_damage.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(damage_pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(damage_pfx, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(damage_pfx)
end