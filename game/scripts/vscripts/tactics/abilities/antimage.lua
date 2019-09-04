--	Antimage Blink

LinkLuaModifier("modifier_tactics_blink", "tactics/abilities/antimage", LUA_MODIFIER_MOTION_NONE)

tactics_blink = class({})

function tactics_blink:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local end_position = Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y)
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 2 - caster:GetManaCostReduction())

		-- Check player and unit resources
		local valid_cast = false
		local valid_positions = Tactics:CalculateSquareArea(caster_position.x, caster_position.y, self:GetTacticsRange())
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
			caster:AddNewModifier(caster, self, "modifier_tactics_blink", {duration = 0.93})

			Timers:CreateTimer(0.4, function()
				Tactics:SetEmpty(caster_position.x, caster_position.y)

				caster:EmitSound("Hero_Antimage.Blink_out")
				local blink_out_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(blink_out_pfx, 0, caster:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(blink_out_pfx)

				FindClearSpaceForUnit(caster, Vector(end_position.x, end_position.y, 0), true)
				caster:SetBoardPosition(target_position.x, target_position.y)
				Tactics:SetGridContent(target_position.x, target_position.y, caster)
			end)

			Timers:CreateTimer(0.5, function()
				local blink_in_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(blink_in_pfx, 0, end_position)
				ParticleManager:ReleaseParticleIndex(blink_in_pfx)
			end)
		end
	end
end

function tactics_blink:GetTacticsRangeType()
	return "square"
end

function tactics_blink:GetTacticsRange()
	return 6
end

function tactics_blink:GetTacticsIgnoresObstacles()
	return true
end

function tactics_blink:GetTacticsCanTargetUnits()
	return false
end



modifier_tactics_blink = class({})

function modifier_tactics_blink:IsDebuff() return false end
function modifier_tactics_blink:IsHidden() return true end
function modifier_tactics_blink:IsPurgable() return false end
function modifier_tactics_blink:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_blink:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_blink:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_blink:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

function modifier_tactics_blink:OnDestroy()
	if IsServer() then

		-- Resolve end of cast
		local unit = self:GetParent()
		local team = unit:GetTeam()
		local player_id = unit:GetTacticsPlayerID()
		local world_position = unit:GetAbsOrigin()
		local grid_position = Tactics:GetGridCoordinatesFromWorld(world_position.x, world_position.y)
		if team == DOTA_TEAM_GOODGUYS then
			unit:FaceTowards(world_position + Vector(0, 100, 0))
		elseif team == DOTA_TEAM_BADGUYS then
			unit:FaceTowards(world_position + Vector(0, -100, 0))
		end
		Tactics:ClearPlayerBusy(player_id)
	end
end