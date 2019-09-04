-- Tactics items

item_tactics_blade_of_attack = class({})

LinkLuaModifier("modifier_tactics_blade_of_attack", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

function item_tactics_blade_of_attack:GetIntrinsicModifierName()
	return "modifier_tactics_blade_of_attack"
end

modifier_tactics_blade_of_attack = class({})

function modifier_tactics_blade_of_attack:IsDebuff() return false end
function modifier_tactics_blade_of_attack:IsHidden() return true end
function modifier_tactics_blade_of_attack:IsPurgable() return false end
function modifier_tactics_blade_of_attack:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_tactics_blade_of_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	}
	return funcs
end

function modifier_tactics_blade_of_attack:GetModifierBaseAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end



item_tactics_daedalus = class({})

LinkLuaModifier("modifier_tactics_daedalus", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

function item_tactics_daedalus:GetIntrinsicModifierName()
	return "modifier_tactics_daedalus"
end

modifier_tactics_daedalus = class({})

function modifier_tactics_daedalus:IsDebuff() return false end
function modifier_tactics_daedalus:IsHidden() return true end
function modifier_tactics_daedalus:IsPurgable() return false end
function modifier_tactics_daedalus:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_tactics_daedalus:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	}
	return funcs
end

function modifier_tactics_daedalus:GetModifierBaseAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end



item_tactics_ring_of_health = class({})

LinkLuaModifier("modifier_tactics_ring_of_health", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

function item_tactics_ring_of_health:GetIntrinsicModifierName()
	return "modifier_tactics_ring_of_health"
end

modifier_tactics_ring_of_health = class({})

function modifier_tactics_ring_of_health:IsDebuff() return false end
function modifier_tactics_ring_of_health:IsHidden() return true end
function modifier_tactics_ring_of_health:IsPurgable() return false end
function modifier_tactics_ring_of_health:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end



item_tactics_wind_lace = class({})

LinkLuaModifier("modifier_tactics_wind_lace", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

function item_tactics_wind_lace:GetIntrinsicModifierName()
	return "modifier_tactics_wind_lace"
end

modifier_tactics_wind_lace = class({})

function modifier_tactics_wind_lace:IsDebuff() return false end
function modifier_tactics_wind_lace:IsHidden() return true end
function modifier_tactics_wind_lace:IsPurgable() return false end
function modifier_tactics_wind_lace:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end



item_tactics_phase_boots = class({})

LinkLuaModifier("modifier_tactics_phase_boots", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

function item_tactics_phase_boots:GetIntrinsicModifierName()
	return "modifier_tactics_phase_boots"
end

modifier_tactics_phase_boots = class({})

function modifier_tactics_phase_boots:IsDebuff() return false end
function modifier_tactics_phase_boots:IsHidden() return true end
function modifier_tactics_phase_boots:IsPurgable() return false end
function modifier_tactics_phase_boots:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end



item_tactics_travel_boots = class({})

LinkLuaModifier("modifier_tactics_travel_boots", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

function item_tactics_travel_boots:GetIntrinsicModifierName()
	return "modifier_tactics_travel_boots"
end

modifier_tactics_travel_boots = class({})

function modifier_tactics_travel_boots:IsDebuff() return false end
function modifier_tactics_travel_boots:IsHidden() return true end
function modifier_tactics_travel_boots:IsPurgable() return false end
function modifier_tactics_travel_boots:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end



--	Teleport scroll
LinkLuaModifier("modifier_item_tactics_tpscroll", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

item_tactics_tpscroll = class({})

function item_tactics_tpscroll:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local end_position = Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y)
		local player_id = caster:GetTacticsPlayerID()
		local caster_team = caster:GetTeam()
		local target_king = Tactics:GetKing(caster_team)
		local king_grid = target_king:GetBoardPosition()

		-- Check player and unit resources
		local valid_cast = false
		local valid_positions = Tactics:CalculateSquareArea(king_grid.x, king_grid.y, self:GetTacticsRange())
		for _, valid_position in pairs(valid_positions) do
			if (valid_position.x == target_position.x) and (valid_position.y == target_position.y) and (Tactics:IsEmpty(target_position.x, target_position.y)) then
				valid_cast = true
				break
			end
		end

		-- If this cast is valid, perform the ability
		if valid_cast then
			Tactics:SetPlayerBusy(player_id)
			caster:FaceTowards(target)
			caster:AddNewModifier(caster, self, "modifier_item_tactics_tpscroll", {duration = 2.5})

			caster:EmitSound("Portal.Loop_Disappear")
			target_king:EmitSound("Portal.Loop_Appear")

			local tp_start_pfx = ParticleManager:CreateParticle("particles/items2_fx/teleport_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(tp_start_pfx, 0, caster:GetAbsOrigin())
			if caster_team == DOTA_TEAM_GOODGUYS then
				ParticleManager:SetParticleControl(tp_start_pfx, 1, Vector(0, 255, 0))
			elseif caster_team == DOTA_TEAM_BADGUYS then
				ParticleManager:SetParticleControl(tp_start_pfx, 1, Vector(255, 0, 0))
			end

			local tp_end_pfx = ParticleManager:CreateParticle("particles/items2_fx/teleport_end.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(tp_end_pfx, 0, end_position + Vector(0, 0, 256))
			ParticleManager:SetParticleControl(tp_end_pfx, 1, end_position + Vector(0, 0, 256))
			if caster_team == DOTA_TEAM_GOODGUYS then
				ParticleManager:SetParticleControl(tp_end_pfx, 2, Vector(0, 255, 0))
			elseif caster_team == DOTA_TEAM_BADGUYS then
				ParticleManager:SetParticleControl(tp_end_pfx, 2, Vector(255, 0, 0))
			end

			Tactics:SetEmpty(caster_position.x, caster_position.y)
			caster:SetBoardPosition(target_position.x, target_position.y)
			Tactics:SetGridContent(target_position.x, target_position.y, caster)

			Timers:CreateTimer(2.5, function()
				Tactics:SetEmpty(caster_position.x, caster_position.y)

				caster:StopSound("Portal.Loop_Disappear")
				target_king:StopSound("Portal.Loop_Appear")
				caster:EmitSound("Portal.Hero_Disappear")
				target_king:EmitSound("Portal.Hero_Appear")
				
				FindClearSpaceForUnit(caster, Vector(end_position.x, end_position.y, 0), true)

				ParticleManager:DestroyParticle(tp_start_pfx, false)
				ParticleManager:DestroyParticle(tp_end_pfx, false)
				ParticleManager:ReleaseParticleIndex(tp_start_pfx)
				ParticleManager:ReleaseParticleIndex(tp_end_pfx)

				self:SetActivated(false)

				self:SetCurrentCharges(self:GetCurrentCharges() - 1)
				if self:GetCurrentCharges() <= 0 then
					self:Destroy()
				end
			end)
		end
	end
end

function item_tactics_tpscroll:GetTacticsRangeType()
	return "square"
end

function item_tactics_tpscroll:GetTacticsRange()
	return 1
end

function item_tactics_tpscroll:GetTacticsIgnoresObstacles()
	return true
end

function item_tactics_tpscroll:GetTacticsCanTargetUnits()
	return false
end



modifier_item_tactics_tpscroll = class({})

function modifier_item_tactics_tpscroll:IsDebuff() return false end
function modifier_item_tactics_tpscroll:IsHidden() return true end
function modifier_item_tactics_tpscroll:IsPurgable() return false end
function modifier_item_tactics_tpscroll:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_item_tactics_tpscroll:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_item_tactics_tpscroll:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_item_tactics_tpscroll:GetOverrideAnimation()
	return ACT_DOTA_TELEPORT
end

function modifier_item_tactics_tpscroll:OnDestroy()
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



--	Force Staff
LinkLuaModifier("modifier_tactics_item_tactics_force_staff", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_item_tactics_force_staff_effect", "tactics/abilities/items", LUA_MODIFIER_MOTION_BOTH)

item_tactics_force_staff = class({})

function item_tactics_force_staff:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local caster_position = caster:GetBoardPosition()
		local target_position = target:GetBoardPosition()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())
		local speed = Vector(0, 1, 0):Normalized() * 1551 * 0.03
		if target:GetTeam() == DOTA_TEAM_BADGUYS then
			speed = Vector(0, -1, 0):Normalized() * 1551 * 0.03
		end

		-- Check if the target is valid
		local valid_cast = false
		local valid_squares = Tactics:CalculateQueenArea(caster_position.x, caster_position.y, self:GetTacticsRange())
		for _, grid_square in pairs(valid_squares) do
			if (grid_square.x == target_position.x) and (grid_square.y == target_position.y) then
				valid_cast = true
				break
			end
		end

		-- Cannot push self
		if caster == target then
			valid_cast = false
		end

		-- Check player and unit resources
		valid_cast = valid_cast and (TurnManager:GetMana(player_id) >= mana_cost)

		-- If this cast is valid, perform the ability
		if valid_cast then

			-- Spend resources
			Tactics:SetPlayerBusy(player_id)
			TurnManager:SpendMana(player_id, mana_cost)

			-- Perform the skill
			caster:FaceTowards(target:GetAbsOrigin())
			caster:AddNewModifier(caster, self, "modifier_tactics_item_tactics_force_staff", {duration = 0.8})
			Timers:CreateTimer(0.1, function()
				caster:EmitSound("DOTA_Item.ForceStaff.Activate")
				target:AddNewModifier(caster, self, "modifier_tactics_item_tactics_force_staff_effect", {duration = 0.33, speed = speed.y})
				Tactics:SetEmpty(target_position.x, target_position.y)

				self:SetActivated(false)
			end)
		end
	end
end

function item_tactics_force_staff:GetTacticsRangeType()
	return "queen"
end

function item_tactics_force_staff:GetTacticsRange()
	return 1
end

function item_tactics_force_staff:GetTacticsIgnoresObstacles()
	return true
end

function item_tactics_force_staff:GetTacticsCanTargetUnits()
	return true
end



modifier_tactics_item_tactics_force_staff = class({})

function modifier_tactics_item_tactics_force_staff:IsDebuff() return false end
function modifier_tactics_item_tactics_force_staff:IsHidden() return true end
function modifier_tactics_item_tactics_force_staff:IsPurgable() return false end
function modifier_tactics_item_tactics_force_staff:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_item_tactics_force_staff:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_item_tactics_force_staff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_item_tactics_force_staff:GetOverrideAnimation()
	return ACT_DOTA_TELEPORT
end


function modifier_tactics_item_tactics_force_staff:OnDestroy()
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



modifier_tactics_item_tactics_force_staff_effect = class({})

function modifier_tactics_item_tactics_force_staff_effect:IsDebuff() return false end
function modifier_tactics_item_tactics_force_staff_effect:IsHidden() return true end
function modifier_tactics_item_tactics_force_staff_effect:IsPurgable() return false end
function modifier_tactics_item_tactics_force_staff_effect:IsMotionController() return true end
function modifier_tactics_item_tactics_force_staff_effect:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end
function modifier_tactics_item_tactics_force_staff_effect:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_item_tactics_force_staff_effect:GetEffectName()
	return "particles/econ/events/ti6/force_staff_ti6.vpcf"
end

function modifier_tactics_item_tactics_force_staff_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tactics_item_tactics_force_staff_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_forcestaff.vpcf"
end

function modifier_tactics_item_tactics_force_staff_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_item_tactics_force_staff_effect:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_tactics_item_tactics_force_staff_effect:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_STUNNED] = true
		}
		return states
	end
end

function modifier_tactics_item_tactics_force_staff_effect:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.03)
		self.speed = keys.speed
	end
end

function modifier_tactics_item_tactics_force_staff_effect:OnDestroy()
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

function modifier_tactics_item_tactics_force_staff_effect:OnIntervalThink()
	if IsServer() then
		local unit = self:GetParent()
		local current_loc = unit:GetAbsOrigin()
		local next_loc_world = current_loc + Vector(0, self.speed, 0):Normalized() * 128
		local next_loc_grid = Tactics:GetGridCoordinatesFromWorld(next_loc_world.x, next_loc_world.y)
		if Tactics:IsTraversable(next_loc_grid.x, next_loc_grid.y) then
			unit:SetAbsOrigin(unit:GetAbsOrigin() + Vector(0, self.speed, 0))
		else
			self:Destroy()
		end
	end
end



--	Refresher Orb
item_tactics_refresher_orb = class({})

function item_tactics_refresher_orb:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())

		-- Use the item if valid
		if TurnManager:GetMana(player_id) >= mana_cost then
			TurnManager:SpendMana(player_id, mana_cost)

			caster:EmitSound("DOTA_Item.Refresher.Activate")

			local refresh_pfx = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(refresh_pfx, 0, caster:GetAbsOrigin() + Vector(0, 0, 150))
			ParticleManager:ReleaseParticleIndex(refresh_pfx)

			caster:ClearHasCastedThisTurn()
			self:SetActivated(false)
		end
	end
end



--	Blink Dagger
item_tactics_blink_dagger = class({})

function item_tactics_blink_dagger:OnSpellStart()
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
		local valid_positions = Tactics:CalculateQueenArea(caster_position.x, caster_position.y, self:GetTacticsRange())
		for _, valid_position in pairs(valid_positions) do
			if (valid_position.x == target_position.x) and (valid_position.y == target_position.y) and (Tactics:IsEmpty(target_position.x, target_position.y)) then
				valid_cast = true
				break
			end
		end

		valid_cast = valid_cast and (TurnManager:GetMana(player_id) >= mana_cost)

		-- If this cast is valid, perform the spell
		if valid_cast then
			TurnManager:SpendMana(player_id, mana_cost)
			Tactics:SetEmpty(caster_position.x, caster_position.y)

			caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
			local blink_out_pfx = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(blink_out_pfx, 0, caster:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(blink_out_pfx)

			FindClearSpaceForUnit(caster, Vector(end_position.x, end_position.y, 0), true)
			caster:SetBoardPosition(target_position.x, target_position.y)
			Tactics:SetGridContent(target_position.x, target_position.y, caster)

			self:SetActivated(false)

			Timers:CreateTimer(0.01, function()
				local blink_in_pfx = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(blink_in_pfx, 0, caster:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(blink_in_pfx)
			end)
		end
	end
end

function item_tactics_blink_dagger:GetTacticsRangeType()
	return "queen"
end

function item_tactics_blink_dagger:GetTacticsRange()
	return 1
end

function item_tactics_blink_dagger:GetTacticsIgnoresObstacles()
	return true
end

function item_tactics_blink_dagger:GetTacticsCanTargetUnits()
	return false
end



-- Mystic Staff
item_tactics_mystic_staff = class({})

LinkLuaModifier("modifier_tactics_mystic_staff", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

function item_tactics_mystic_staff:GetIntrinsicModifierName()
	return "modifier_tactics_mystic_staff"
end

modifier_tactics_mystic_staff = class({})

function modifier_tactics_mystic_staff:IsDebuff() return false end
function modifier_tactics_mystic_staff:IsHidden() return true end
function modifier_tactics_mystic_staff:IsPurgable() return false end
function modifier_tactics_mystic_staff:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end



-- Echo Sabre
item_tactics_echo_sabre = class({})

LinkLuaModifier("modifier_tactics_echo_sabre", "tactics/abilities/items", LUA_MODIFIER_MOTION_NONE)

function item_tactics_echo_sabre:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 2 - caster:GetManaCostReduction())

		-- Use the item if valid
		if TurnManager:GetMana(player_id) >= mana_cost then
			TurnManager:SpendMana(player_id, mana_cost)

			caster:EmitSound("Tactics.EchoSabre")

			local refresh_pfx = ParticleManager:CreateParticle("particles/echo_sabre.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(refresh_pfx, 0, caster:GetAbsOrigin() + Vector(0, 0, 150))
			ParticleManager:ReleaseParticleIndex(refresh_pfx)

			caster:AddNewModifier(caster, self, "modifier_tactics_echo_sabre", {})
			self:SetActivated(false)
		end
	end
end

modifier_tactics_echo_sabre = class({})

function modifier_tactics_echo_sabre:IsDebuff() return false end
function modifier_tactics_echo_sabre:IsHidden() return false end
function modifier_tactics_echo_sabre:IsPurgable() return false end
function modifier_tactics_echo_sabre:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_tactics_echo_sabre:GetEffectName()
	return "particles/echo_shell.vpcf"
end

function modifier_tactics_echo_sabre:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end