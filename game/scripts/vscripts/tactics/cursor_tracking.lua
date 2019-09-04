-- Mouse tracking functions

function Tactics:MousePositionThink(keys)
	if IsServer() then
		local grid_loc = Tactics:GetGridCoordinatesFromWorld(keys.x, keys.y)
		Tactics:SetCursorGridPosition(grid_loc.x, grid_loc.y, keys.player_id)

		-- Fetch hovered units
		local hover_unit = Tactics:GetGridUnit(grid_loc.x, grid_loc.y)
		local previous_hover_unit = Tactics:GetHoveredUnit(keys.player_id)
		local previous_selected_unit = Tactics:GetSelectedUnit(keys.player_id)
		local selected_unit = EntIndexToHScript(keys.selected_entity)

		-- Hovered unit logic
		if not hover_unit and previous_hover_unit then
			previous_hover_unit:RemoveModifierByName("modifier_tactics_mouse_hover")
			Tactics:ClearHoveredUnit(keys.player_id)
		elseif hover_unit and hover_unit ~= previous_hover_unit then
			if previous_hover_unit then
				previous_hover_unit:RemoveModifierByName("modifier_tactics_mouse_hover")
			end
			hover_unit:AddNewModifier(hover_unit, nil, "modifier_tactics_mouse_hover", {player_id = keys.player_id})
			Tactics:SetHoveredUnit(hover_unit, keys.player_id)
		end

		-- Selected unit logic
		if not Tactics:IsPlayerBusy(keys.player_id) then
			local previous_selected_unit = Tactics:GetSelectedUnit(keys.player_id)
			local selected_unit = EntIndexToHScript(keys.selected_entity)
			if selected_unit and selected_unit ~= previous_selected_unit then
				if previous_selected_unit then
					previous_selected_unit:RemoveModifierByName("modifier_tactics_mouse_selected")
				end
				selected_unit:AddNewModifier(selected_unit, nil, "modifier_tactics_mouse_selected", {player_id = keys.player_id})
				Tactics:SetSelectedUnit(selected_unit, keys.player_id)
			end
		end

		-- Ability targeting logic
		if keys.active_ability >= 0 then
			if hover_unit then
				hover_unit:RemoveModifierByName("modifier_tactics_mouse_hover")
				Tactics:ClearHoveredUnit(keys.player_id)
			end
			if selected_unit then
				selected_unit:RemoveModifierByName("modifier_tactics_mouse_selected")
				Tactics:ClearSelectedUnit(keys.player_id)
			end

			if keys.active_ability ~= Tactics.player_ability_preview_index[keys.player_id] then
				local active_ability = EntIndexToHScript(keys.active_ability)
				Tactics:DrawAbilityAreaPreview(active_ability, keys.player_id)
				Tactics.player_ability_preview_index[keys.player_id] = keys.active_ability
			end
			
		else
			Tactics:EraseAbilityPreview(keys.player_id)
			Tactics.player_ability_preview_index[keys.player_id] = -1
		end
	end
end



function Tactics:LeftMousePressed(keys)
	if IsServer() then
		Tactics:SetLeftMousePressed(keys.player_id)
	end
end

function Tactics:RightMousePressed(keys)
	if IsServer() then
		Tactics:SetRightMousePressed(keys.player_id)
	end
end



function Tactics:SetPlayerBusy(player_id)
	self.is_player_busy[player_id] = true
end

function Tactics:ClearPlayerBusy(player_id)
	self.is_player_busy[player_id] = false
end

function Tactics:IsPlayerBusy(player_id)
	return self.is_player_busy[player_id]
end


function Tactics:SetLeftMousePressed(player_id)
	self.player_cursor_grid_position[player_id]["left_button_pressed"] = true
end

function Tactics:ClearLeftMousePressed(player_id)
	self.player_cursor_grid_position[player_id]["left_button_pressed"] = false
end

function Tactics:GetLeftMousePressed(player_id)
	return self.player_cursor_grid_position[player_id]["left_button_pressed"]
end

function Tactics:SetRightMousePressed(player_id)
	self.player_cursor_grid_position[player_id]["right_button_pressed"] = true
end

function Tactics:ClearRightMousePressed(player_id)
	self.player_cursor_grid_position[player_id]["right_button_pressed"] = false
end

function Tactics:GetRightMousePressed(player_id)
	return self.player_cursor_grid_position[player_id]["right_button_pressed"]
end



function Tactics:SetHoveredUnit(unit, player_id)
	self.player_cursor_grid_position[player_id]["hovered_unit"] = unit
end

function Tactics:ClearHoveredUnit(player_id)
	self.player_cursor_grid_position[player_id]["hovered_unit"] = false
end

function Tactics:GetHoveredUnit(player_id)
	return self.player_cursor_grid_position[player_id]["hovered_unit"]
end

function Tactics:SetSelectedUnit(unit, player_id)
	self.player_cursor_grid_position[player_id]["selected_unit"] = unit
end

function Tactics:ClearSelectedUnit(player_id)
	self.player_cursor_grid_position[player_id]["selected_unit"] = false
end

function Tactics:GetSelectedUnit(player_id)
	return self.player_cursor_grid_position[player_id]["selected_unit"]
end


function Tactics:SetCursorGridPosition(x, y, player_id)
	self.player_cursor_grid_position[player_id].x = x
	self.player_cursor_grid_position[player_id].y = y
end

function Tactics:GetCursorGridPosition(player_id)
	local grid_loc = {}

	grid_loc.x = self.player_cursor_grid_position[player_id].x
	grid_loc.y = self.player_cursor_grid_position[player_id].y

	return grid_loc
end

function Tactics:DrawAbilityAreaPreview(ability, player_id)
	local caster = ability:GetCaster()
	local position = caster:GetBoardPosition()
	local caster_team = caster:GetTeam()
	local aoe_type = ability:GetTacticsRangeType()
	local range = ability:GetTacticsRange()
	local ignores_obstacles = ability:GetTacticsIgnoresObstacles()
	local can_target_units = ability:GetTacticsCanTargetUnits()
	local ability_name = ability:GetAbilityName()
	local path_grid = {}

	if ability_name == "item_tactics_tpscroll" then
		local king_position = self:GetKing(caster_team):GetBoardPosition()
		path_grid = self:CalculateSquareEmptyArea(king_position.x, king_position.y, range)
	elseif aoe_type == "pawn" then
		if player_id == self:GetRadiantPlayerID() then
			table.insert(path_grid, Vector(position.x - 1, position.y + 1, 0))
			table.insert(path_grid, Vector(position.x + 1, position.y + 1, 0))
		elseif player_id == self:GetDirePlayerID() then
			table.insert(path_grid, Vector(position.x - 1, position.y - 1, 0))
			table.insert(path_grid, Vector(position.x + 1, position.y - 1, 0))
		end
	elseif aoe_type == "queen" then
		if ignores_obstacles then
			path_grid = self:CalculateQueenArea(position.x, position.y, range)
			if ability_name == "tactics_proximity_mine" then
				for grid_key, grid_square in pairs(path_grid) do
					if Tactics:GetGridUnitTeam(grid_square.x, grid_square.y) ~= caster_team then
						table.remove(path_grid, grid_key)
					end
				end
			end
		else
			path_grid = self:CalculateQueenPath(position.x, position.y, range, player_id)
		end
	elseif aoe_type == "rook" then
		if ignores_obstacles then
			if can_target_units then
				path_grid = self:CalculateRookArea(position.x, position.y, range)
			else
				path_grid = self:CalculateBurrowstrikeArea(position.x, position.y, range)
			end
		else
			path_grid = self:CalculateRookPath(position.x, position.y, range, player_id)
		end
	elseif aoe_type == "bishop" then
		if ignores_obstacles then
			path_grid = self:CalculateBishopArea(position.x, position.y, range)
		else
			path_grid = self:CalculateBishopPath(position.x, position.y, range, player_id)
		end
	elseif aoe_type == "square" then
		path_grid = self:CalculateSquareArea(position.x, position.y, range)
	end

	-- Store valid path
	self.player_ability_preview_overlay_path_grid[player_id] = path_grid

	-- No target abilities dont show targeting
	if ability_name == "tactics_hoof_stomp" or ability_name == "tactics_poison_nova" or ability_name == "tactics_health_pulse" then
		self.player_ability_preview_overlay[player_id] = -1
	elseif ability_name == "tactics_proximity_mine" then
		self.player_ability_preview_overlay[player_id] = self:DrawFixedFriendlyArea(path_grid, player_id)
	else
		self.player_ability_preview_overlay[player_id] = self:DrawFixedOffensiveArea(path_grid, player_id)
	end

	-- Effect preview
	caster:AddNewModifier(caster, ability, "modifier_tactics_active_skill", {player_id = player_id})
end

function Tactics:EraseAbilityPreview(player_id)
	if self.player_ability_preview_overlay[player_id] ~= -1 then
		self:EraseGrid(self.player_ability_preview_overlay[player_id])
	end
	local active_ability = EntIndexToHScript(Tactics.player_ability_preview_index[player_id])
	active_ability:GetCaster():RemoveModifierByName("modifier_tactics_active_skill")
end