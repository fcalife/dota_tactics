--	Zeus arc lightning

tactics_arc_lightning = class({})

function tactics_arc_lightning:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_position = caster:GetBoardPosition()
		local target_position = target:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 2 - caster:GetManaCostReduction())
		local damage = 150

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

			-- Perform the spell
			caster:FaceTowards(target:GetAbsOrigin())
			Tactics:SetPlayerBusy(player_id)
			caster:EmitSound("Hero_Zuus.ArcLightning.Cast")
			self:Jump(caster, target, damage)

			local previous_target = target
			local targets = {}
			table.insert(targets, target)
			Timers:CreateTimer(0.35, function()
				local search_grid = previous_target:GetBoardPosition()
				local next_targets = Tactics:CalculateSquareArea(search_grid.x, search_grid.y, 1)
				local found_target = false
				for _, possible_target in pairs(next_targets) do
					local target_team = Tactics:GetGridUnitTeam(possible_target.x, possible_target.y)
					if target_team and target_team ~= caster:GetTeam() then
						local already_targeted = false
						local test_target = Tactics:GetGridUnit(possible_target.x, possible_target.y)
						for _, hit_target in pairs(targets) do
							if hit_target == test_target then
								already_targeted = true
								break
							end
						end
						if not already_targeted then
							found_target = test_target
							break
						end
					end
				end
				if found_target then
					self:Jump(previous_target, found_target, damage)
					table.insert(targets, found_target)
					previous_target = found_target
					return 0.35
				else
					Tactics:ClearPlayerBusy(player_id)
					local world_position = caster:GetAbsOrigin()
					if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
						caster:FaceTowards(world_position + Vector(0, 100, 0))
					else
						caster:FaceTowards(world_position + Vector(0, -100, 0))
					end
				end
			end)
		end
	end
end

function tactics_arc_lightning:Jump(origin, target, damage)
	target:EmitSound("Hero_Zuus.ArcLightning.Target")
	local arc_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(arc_pfx, 0, origin, PATTACH_POINT_FOLLOW, "attach_hitloc", origin:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(arc_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(arc_pfx)
	CombatManager:DealDamage(self:GetCaster(), target, damage, DAMAGE_TYPE_MAGICAL)
end

function tactics_arc_lightning:GetTacticsRangeType()
	return "queen"
end

function tactics_arc_lightning:GetTacticsRange()
	return 2
end

function tactics_arc_lightning:GetTacticsIgnoresObstacles()
	return true
end

function tactics_arc_lightning:GetTacticsCanTargetUnits()
	return true
end