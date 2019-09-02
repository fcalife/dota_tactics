--	Dark Seer surge

LinkLuaModifier("modifier_tactics_surge", "tactics/abilities/dark_seer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_surge_effect", "tactics/abilities/dark_seer", LUA_MODIFIER_MOTION_NONE)

tactics_surge = class({})

function tactics_surge:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Check player and unit resources
		local valid_cast = false

		local valid_positions = Tactics:CalculateBishopPath(caster_position.x, caster_position.y, self:GetTacticsRange(), player_id)
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
			caster:AddNewModifier(caster, self, "modifier_tactics_surge", {duration = 0.4})

			Timers:CreateTimer(0.4, function()
				Tactics:SetEmpty(caster_position.x, caster_position.y)
				caster:EmitSound("Hero_Dark_Seer.Surge")

				-- Perform movement
				if Tactics:IsUnit(target_position.x, target_position.y) then

					-- Adjust movement due to attack offset
					local attack_target = Tactics:GetGridUnit(target_position.x, target_position.y)
					if target_position.x > caster_position.x then
						target_position.x = target_position.x - 1
					elseif target_position.x < caster_position.x then
						target_position.x = target_position.x + 1
					end
					if target_position.y > caster_position.y then
						target_position.y = target_position.y - 1
					elseif target_position.y < caster_position.y then
						target_position.y = target_position.y + 1
					end

					local move_loc = Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y)
					local move_time = (move_loc - caster:GetAbsOrigin()):Length2D() / 1200
					caster:MoveToPosition(move_loc)
					caster:AddNewModifier(caster, self, "modifier_tactics_surge_effect", {duration = move_time})
					caster:AddNewModifier(caster, nil, "modifier_tactics_moving", {attack_target = attack_target:GetEntityIndex(), duration = move_time})
				else
					local move_loc = Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y)
					local move_time = (move_loc - caster:GetAbsOrigin()):Length2D() / 1200
					caster:MoveToPosition(move_loc)
					caster:AddNewModifier(caster, self, "modifier_tactics_surge_effect", {duration = move_time})
					caster:AddNewModifier(caster, nil, "modifier_tactics_moving", {duration = move_time + 0.2})
				end
			end)
		end
	end
end

function tactics_surge:GetTacticsRangeType()
	return "bishop"
end

function tactics_surge:GetTacticsRange()
	return 7
end

function tactics_surge:GetTacticsIgnoresObstacles()
	return false
end

function tactics_surge:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_surge = class({})

function modifier_tactics_surge:IsDebuff() return false end
function modifier_tactics_surge:IsHidden() return true end
function modifier_tactics_surge:IsPurgable() return false end
function modifier_tactics_surge:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_surge:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_surge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_surge:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end



modifier_tactics_surge_effect = class({})

function modifier_tactics_surge_effect:IsDebuff() return false end
function modifier_tactics_surge_effect:IsHidden() return true end
function modifier_tactics_surge_effect:IsPurgable() return false end
function modifier_tactics_surge_effect:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_surge_effect:GetEffectName()
	return "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"
end

function modifier_tactics_surge_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tactics_surge_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
	return funcs
end

function modifier_tactics_surge_effect:GetModifierMoveSpeed_Absolute()
	return 1200
end