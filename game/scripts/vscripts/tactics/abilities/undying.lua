--	Undying decay

LinkLuaModifier("modifier_tactics_decay", "tactics/abilities/undying", LUA_MODIFIER_MOTION_NONE)

tactics_decay = class({})

function tactics_decay:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local world_position = Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y)
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Check player and unit resources
		local valid_cast = false

		local valid_positions = Tactics:CalculateQueenArea(caster_position.x, caster_position.y, self:GetTacticsRange())
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
			caster:SpendActionPoint()
			TurnManager:SpendMana(player_id, mana_cost)
			Tactics:SetPlayerBusy(player_id)

			-- Perform the spell
			caster:FaceTowards(target)
			caster:AddNewModifier(caster, self, "modifier_tactics_decay", {duration = 0.45})

			local caster_team = caster:GetTeam()
			local heal = 0
			Timers:CreateTimer(0.45, function()
				caster:EmitSound("Hero_Undying.Decay.Cast")

				local ground_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(ground_pfx, 0, world_position)
				ParticleManager:SetParticleControl(ground_pfx, 1, Vector(128 * 3, 0, 0))
				ParticleManager:ReleaseParticleIndex(ground_pfx)

				for i = -1, 1 do
					for j = -1, 1 do
						local enemy = Tactics:GetGridUnit(target_position.x + i, target_position.y + j)
						if enemy and enemy:GetTeam() ~= caster_team then
							enemy:EmitSound("Hero_Undying.Decay.Target")

							local drain_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay_strength_xfer.vpcf", PATTACH_CUSTOMORIGIN, nil)
							ParticleManager:SetParticleControl(drain_pfx, 0, enemy:GetAbsOrigin())
							ParticleManager:SetParticleControl(drain_pfx, 1, caster:GetAbsOrigin())
							ParticleManager:SetParticleControl(drain_pfx, 2, enemy:GetAbsOrigin())
							ParticleManager:ReleaseParticleIndex(drain_pfx)

							CombatManager:DealDamage(caster, enemy, 50, DAMAGE_TYPE_MAGICAL)
							heal = heal + 50
						end
					end
				end
			end)

			if heal > 0 then
				CombatManager:ApplyHealing(caster, caster, heal)
			end
		end
	end
end

function tactics_decay:GetTacticsRangeType()
	return "queen"
end

function tactics_decay:GetTacticsRange()
	return 1
end

function tactics_decay:GetTacticsIgnoresObstacles()
	return true
end

function tactics_decay:GetTacticsCanTargetUnits()
	return true
end


modifier_tactics_decay = class({})

function modifier_tactics_decay:IsDebuff() return false end
function modifier_tactics_decay:IsHidden() return true end
function modifier_tactics_decay:IsPurgable() return false end
function modifier_tactics_decay:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_decay:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_decay:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_decay:GetOverrideAnimation()
	return ACT_DOTA_UNDYING_DECAY
end


function modifier_tactics_decay:OnDestroy()
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