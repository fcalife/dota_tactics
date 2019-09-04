--	Dazzle's Shallow Grave

LinkLuaModifier("modifier_tactics_shallow_grave", "tactics/abilities/dazzle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_shallow_grave_effect", "tactics/abilities/dazzle", LUA_MODIFIER_MOTION_NONE)

tactics_shallow_grave = class({})

function tactics_shallow_grave:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_position = caster:GetBoardPosition()
		local target_position = target:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 2 - caster:GetManaCostReduction())

		-- Check if the target is valid
		local valid_cast = false
		local valid_squares = Tactics:CalculateSquareArea(caster_position.x, caster_position.y, self:GetTacticsRange())
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
			caster:SpendActionPoint()
			TurnManager:SpendMana(player_id, mana_cost)
			Tactics:SetPlayerBusy(player_id)

			-- Perform the ability
			caster:FaceTowards(target:GetAbsOrigin())
			caster:AddNewModifier(caster, self, "modifier_tactics_shallow_grave", {duration = 0.4})
			Timers:CreateTimer(0.4, function()
				target:EmitSound("Hero_Dazzle.Shallow_Grave")
				target:AddNewModifier(caster, self, "modifier_tactics_shallow_grave_effect", {})
			end)
		end
	end
end

function tactics_shallow_grave:GetTacticsRangeType()
	return "square"
end

function tactics_shallow_grave:GetTacticsRange()
	return 4
end

function tactics_shallow_grave:GetTacticsIgnoresObstacles()
	return true
end

function tactics_shallow_grave:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_shallow_grave = class({})

function modifier_tactics_shallow_grave:IsDebuff() return false end
function modifier_tactics_shallow_grave:IsHidden() return true end
function modifier_tactics_shallow_grave:IsPurgable() return false end
function modifier_tactics_shallow_grave:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_shallow_grave:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_shallow_grave:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_shallow_grave:GetOverrideAnimation()
	return ACT_DOTA_SHALLOW_GRAVE
end


function modifier_tactics_shallow_grave:OnDestroy()
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



modifier_tactics_shallow_grave_effect = class({})

function modifier_tactics_shallow_grave_effect:IsDebuff() return false end
function modifier_tactics_shallow_grave_effect:IsHidden() return false end
function modifier_tactics_shallow_grave_effect:IsPurgable() return false end
function modifier_tactics_shallow_grave_effect:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_shallow_grave_effect:GetEffectName()
	return "particles/dazzle_shallow_grave.vpcf"
end

function modifier_tactics_shallow_grave_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tactics_shallow_grave_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH
	}
	return funcs
end

function modifier_tactics_shallow_grave_effect:GetMinHealth()
	return 50
end