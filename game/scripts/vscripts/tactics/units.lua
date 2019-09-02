-- Unit-based dota tactics functions

function CDOTA_BaseNPC:GetTacticsPlayerID()
	if self:GetTeam() == DOTA_TEAM_GOODGUYS then
		return Tactics:GetRadiantPlayerID()
	elseif self:GetTeam() == DOTA_TEAM_BADGUYS then
		return Tactics:GetDirePlayerID()
	else
		return nil
	end
end

function CDOTA_BaseNPC:SetBoardPosition(x, y)
	if not self.board_position then
		self.board_position = {}
	end

	self.board_position.x = x
	self.board_position.y = y
end

function CDOTA_BaseNPC:GetBoardPosition()
	if self.board_position then
		local board_position = {}
		board_position.x = self.board_position.x
		board_position.y = self.board_position.y

		return board_position
	else
		return nil
	end
end



function CDOTA_BaseNPC:GetMovementType()
	return Tactics.unit_stats[self:GetUnitName()]["MovementType"]
end

function CDOTA_BaseNPC:GetMovementRange()
	local movement_range = Tactics.unit_stats[self:GetUnitName()]["MovementRange"]

	-- Modifiers
	if self:HasModifier("modifier_tactics_wind_lace") then
		return movement_range + 1
	elseif self:HasModifier("modifier_tactics_phase_boots") then
		return movement_range + 4
	elseif self:HasModifier("modifier_tactics_travel_boots") then
		return 12
	end
	return movement_range
end

function CDOTA_BaseNPC:GetAttackDamage()
	return Tactics.unit_stats[self:GetUnitName()]["AttackDamageMax"]
end

function CDOTA_BaseNPC:GetAttackPoint()
	return Tactics.unit_stats[self:GetUnitName()]["AttackAnimationPoint"]
end

function CDOTA_BaseNPC:GetManaCostReduction()
	local mana_reduction = 0
	if self:HasModifier("modifier_tactics_arcane_rune") then
		mana_reduction = mana_reduction + 1
	end
	return mana_reduction
end

function CDOTA_BaseNPC:ProcessCastModifiers()
	local grid_location = self:GetBoardPosition()
	local rune_name = Tactics:GetRuneName(grid_location.x, grid_location.y)
	if not rune_name or rune_name ~= "arcane" then
		self:RemoveModifierByName("modifier_tactics_arcane_rune")
	end
end

function CDOTA_BaseNPC:PlayMovementLine()
	local lines = Tactics.unit_stats[self:GetUnitName()]["MovementLines"]
	self:EmitSound(lines[tostring(RandomInt(1, lines["count"]))])
end

function CDOTA_BaseNPC:PlayAttackMoveLine()
	local lines = Tactics.unit_stats[self:GetUnitName()]["AttackLines"]
	self:EmitSound(lines[tostring(RandomInt(1, lines["count"]))])
end



function CDOTA_BaseNPC:SetHasMovedThisTurn()
	self:AddNewModifier(self, nil, "modifier_tactics_already_moved_this_turn", {})
end

function CDOTA_BaseNPC:ClearHasMovedThisTurn()
	self:RemoveModifierByName("modifier_tactics_already_moved_this_turn")
end

function CDOTA_BaseNPC:HasMovedThisTurn()
	if self:HasModifier("modifier_tactics_already_moved_this_turn") then
		return true
	else
		return false
	end
end



function CDOTA_BaseNPC:SetHasCastedThisTurn()
	self:AddNewModifier(self, nil, "modifier_tactics_already_casted_this_turn", {})
end

function CDOTA_BaseNPC:ClearHasCastedThisTurn()
	self:RemoveModifierByName("modifier_tactics_already_casted_this_turn")
end

function CDOTA_BaseNPC:HasCastedThisTurn()
	if self:HasModifier("modifier_tactics_already_casted_this_turn") then
		return true
	else
		return false
	end
end