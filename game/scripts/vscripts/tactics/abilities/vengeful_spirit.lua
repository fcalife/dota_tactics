--	Vengeful Spirit Swap

LinkLuaModifier("modifier_tactics_nether_swap", "tactics/abilities/vengeful_spirit", LUA_MODIFIER_MOTION_NONE)

tactics_nether_swap = class({})

function tactics_nether_swap:OnSpellStart()
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

		if caster == target then
			valid_cast = false
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
			caster:SpendActionPoint()
			TurnManager:SpendMana(player_id, mana_cost)
			Tactics:SetPlayerBusy(player_id)

			-- Perform the skill
			caster:FaceTowards(target:GetAbsOrigin())
			caster:AddNewModifier(caster, self, "modifier_tactics_nether_swap", {duration = 0.8})
			Timers:CreateTimer(0.3, function()
				local caster_board_position = Tactics:GetWorldCoordinatesFromGrid(caster_position.x, caster_position.y)
				local target_board_position = Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y)

				-- Play effects
				caster:EmitSound("Hero_VengefulSpirit.NetherSwap")

				local caster_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, caster)
				ParticleManager:SetParticleControlEnt(caster_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_board_position, true)
				ParticleManager:SetParticleControlEnt(caster_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_board_position, true)
				ParticleManager:ReleaseParticleIndex(caster_pfx)

				local target_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, target)
				ParticleManager:SetParticleControlEnt(target_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_board_position, true)
				ParticleManager:SetParticleControlEnt(target_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_board_position, true)
				ParticleManager:ReleaseParticleIndex(target_pfx)

				-- Swap positions
				FindClearSpaceForUnit(caster, Vector(target_board_position.x, target_board_position.y, 0), false)
				FindClearSpaceForUnit(target, Vector(caster_board_position.x, caster_board_position.y, 0), true)
				FindClearSpaceForUnit(caster, Vector(target_board_position.x, target_board_position.y, 0), true)
				caster:SetBoardPosition(target_position.x, target_position.y)
				target:SetBoardPosition(caster_position.x, caster_position.y)
				Tactics:SetGridContent(target_position.x, target_position.y, caster)
				Tactics:SetGridContent(caster_position.x, caster_position.y, target)
			end)
		end
	end
end

function tactics_nether_swap:GetTacticsRangeType()
	return "square"
end

function tactics_nether_swap:GetTacticsRange()
	return 3
end

function tactics_nether_swap:GetTacticsIgnoresObstacles()
	return true
end

function tactics_nether_swap:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_nether_swap = class({})

function modifier_tactics_nether_swap:IsDebuff() return false end
function modifier_tactics_nether_swap:IsHidden() return true end
function modifier_tactics_nether_swap:IsPurgable() return false end
function modifier_tactics_nether_swap:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_nether_swap:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_nether_swap:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_nether_swap:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end


function modifier_tactics_nether_swap:OnDestroy()
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