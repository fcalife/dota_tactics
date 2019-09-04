--	Tusk Walrus Kick

LinkLuaModifier("modifier_tactics_walrus_kick", "tactics/abilities/tusk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_walrus_kick_effect", "tactics/abilities/tusk", LUA_MODIFIER_MOTION_BOTH)

tactics_walrus_kick = class({})

function tactics_walrus_kick:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_position = caster:GetBoardPosition()
		local target_position = target:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Check if the target is valid
		local valid_cast = false
		local valid_squares = Tactics:CalculateRookPath(caster_position.x, caster_position.y, self:GetTacticsRange(), player_id)
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

			-- Perform the skill
			caster:EmitSound("Hero_Tusk.WalrusPunch.Cast")
			caster:FaceTowards(target:GetAbsOrigin())
			caster:AddNewModifier(caster, self, "modifier_tactics_walrus_kick", {duration = 1.5})
			local speed = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * 0.03 * 1500
			Timers:CreateTimer(0.2, function()
				target:EmitSound("Hero_Tusk.WalrusKick.Target")
				target:AddNewModifier(caster, self, "modifier_tactics_walrus_kick_effect", {move_x = speed.x, move_y = speed.y})
				Tactics:SetEmpty(target_position.x, target_position.y)

				local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControl(trail_pfx, 0, target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(trail_pfx)

				local test_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruskick_txt_ult.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(test_pfx, 0, target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(test_pfx)
			end)
		end
	end
end

function tactics_walrus_kick:GetTacticsRangeType()
	return "rook"
end

function tactics_walrus_kick:GetTacticsRange()
	return 1
end

function tactics_walrus_kick:GetTacticsIgnoresObstacles()
	return false
end

function tactics_walrus_kick:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_walrus_kick = class({})

function modifier_tactics_walrus_kick:IsDebuff() return false end
function modifier_tactics_walrus_kick:IsHidden() return true end
function modifier_tactics_walrus_kick:IsPurgable() return false end
function modifier_tactics_walrus_kick:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_walrus_kick:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_walrus_kick:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_walrus_kick:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_5
end


function modifier_tactics_walrus_kick:OnDestroy()
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



modifier_tactics_walrus_kick_effect = class({})

function modifier_tactics_walrus_kick_effect:IsDebuff() return false end
function modifier_tactics_walrus_kick_effect:IsHidden() return true end
function modifier_tactics_walrus_kick_effect:IsPurgable() return false end
function modifier_tactics_walrus_kick_effect:IsMotionController() return true end
function modifier_tactics_walrus_kick_effect:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end
function modifier_tactics_walrus_kick_effect:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_walrus_kick_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_walrus_kick_effect:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_tactics_walrus_kick_effect:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_STUNNED] = true
		}
		return states
	end
end

function modifier_tactics_walrus_kick_effect:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.03)
		self.move_x = keys.move_x
		self.move_y = keys.move_y
	end
end

function modifier_tactics_walrus_kick_effect:OnDestroy()
	if IsServer() then

		-- Resolve end of cast
		local unit = self:GetParent()
		local team = unit:GetTeam()
		local player_id = unit:GetTacticsPlayerID()
		local world_position = unit:GetAbsOrigin()
		local grid_position = Tactics:GetGridCoordinatesFromWorld(world_position.x, world_position.y)
		local new_world_position = Tactics:GetWorldCoordinatesFromGrid(grid_position.x, grid_position.y)
		new_world_position = Vector(new_world_position.x, new_world_position.y, 0)

		if unit:IsAlive() then
			unit:SetAbsOrigin(new_world_position)
			unit:SetBoardPosition(grid_position.x, grid_position.y)
			Tactics:SetGridContent(grid_position.x, grid_position.y, unit)

			if team == DOTA_TEAM_GOODGUYS then
				unit:FaceTowards(world_position + Vector(0, 100, 0))
			elseif team == DOTA_TEAM_BADGUYS then
				unit:FaceTowards(world_position + Vector(0, -100, 0))
			end
		end

		ResolveNPCPositions(new_world_position, 128)
		Tactics:ClearPlayerBusy(player_id)
	end
end

function modifier_tactics_walrus_kick_effect:OnIntervalThink()
	if IsServer() then
		local unit = self:GetParent()
		local current_loc = unit:GetAbsOrigin()
		local next_loc_world = current_loc + Vector(self.move_x, self.move_y, 0):Normalized() * 128
		local next_loc_grid = Tactics:GetGridCoordinatesFromWorld(next_loc_world.x, next_loc_world.y)
		if Tactics:IsTraversable(next_loc_grid.x, next_loc_grid.y) then
			unit:SetAbsOrigin(unit:GetAbsOrigin() + Vector(self.move_x, self.move_y, 0))
		else
			local impact_loc = Tactics:GetWorldCoordinatesFromGrid(next_loc_grid.x, next_loc_grid.y)
			local impact_pfx = ParticleManager:CreateParticle("particles/attack_damage.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(impact_pfx, 0, impact_loc)
			ParticleManager:SetParticleControl(impact_pfx, 1, impact_loc)
			ParticleManager:ReleaseParticleIndex(impact_pfx)
			unit:EmitSound("Hero_Tusk.WalrusPunch.Damage")
			self:Destroy()
		end
	end
end