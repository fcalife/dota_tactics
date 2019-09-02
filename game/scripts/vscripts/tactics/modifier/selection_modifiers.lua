LinkLuaModifier("modifier_tactics_mouse_hover", "tactics/modifier/selection_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_mouse_selected", "tactics/modifier/selection_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_active_skill", "tactics/modifier/selection_modifiers", LUA_MODIFIER_MOTION_NONE)

modifier_tactics_mouse_hover = class({})

function modifier_tactics_mouse_hover:IsDebuff() return true end
function modifier_tactics_mouse_hover:IsHidden() return true end
function modifier_tactics_mouse_hover:IsPurgable() return false end
function modifier_tactics_mouse_hover:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_mouse_hover:OnCreated(keys)
	if IsServer() then
		local unit = self:GetParent()
		local team = PlayerResource:GetTeam(keys.player_id)
		self.hover_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_unit_hovered.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit, team)
		ParticleManager:SetParticleControl(self.hover_pfx, 0, unit:GetAbsOrigin() + Vector(0, 0, 256))
		ParticleManager:SetParticleControl(self.hover_pfx, 1, Vector(255, 255, 255))

		-- Possible paths overlay
		local overlay_type = 1
		if unit:GetTeam() ~= team or unit:HasMovedThisTurn() or (not TurnManager:HasActionPoints(keys.player_id)) then
			overlay_type = 0
		end

		local position = unit:GetBoardPosition()
		local unit_id = unit:GetTacticsPlayerID()
		local movement_type = unit:GetMovementType()
		local movement_range = unit:GetMovementRange()

		if movement_type == "Queen" then
			self.path_pfx = Tactics:DrawPath(Tactics:CalculateQueenPath(position.x, position.y, movement_range, unit_id), overlay_type, keys.player_id)
		elseif movement_type == "Rook" then
			self.path_pfx = Tactics:DrawPath(Tactics:CalculateRookPath(position.x, position.y, movement_range, unit_id), overlay_type, keys.player_id)
		elseif movement_type == "Bishop" then
			self.path_pfx = Tactics:DrawPath(Tactics:CalculateBishopPath(position.x, position.y, movement_range, unit_id), overlay_type, keys.player_id)
		elseif movement_type == "Pawn" then
			self.path_pfx = Tactics:DrawPath(Tactics:CalculatePawnPath(position.x, position.y, movement_range, unit_id), overlay_type, keys.player_id)
		end
	end
end

function modifier_tactics_mouse_hover:OnDestroy()
	if IsServer() then
		Tactics:EraseGrid(self.path_pfx)
		ParticleManager:DestroyParticle(self.hover_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.hover_pfx)
	end
end



modifier_tactics_mouse_selected = class({})

function modifier_tactics_mouse_selected:IsDebuff() return true end
function modifier_tactics_mouse_selected:IsHidden() return true end
function modifier_tactics_mouse_selected:IsPurgable() return false end
function modifier_tactics_mouse_selected:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_mouse_selected:OnCreated(keys)
	if IsServer() then
		self.unit = self:GetParent()
		self.team = PlayerResource:GetTeam(keys.player_id)
		self.player_id = keys.player_id
		self.active_path_pfx = {}
		self.cursor_position = {}
		self.cursor_position.x = 0
		self.cursor_position.y = 0

		-- Selection overlay
		self.selected_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_unit_selected.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit, self.team)
		ParticleManager:SetParticleControl(self.selected_pfx, 0, self.unit:GetAbsOrigin() + Vector(0, 0, 256))
		ParticleManager:SetParticleControl(self.selected_pfx, 1, Vector(255, 255, 255))

		-- Possible paths overlay
		self.position = self.unit:GetBoardPosition()
		local movement_type = self.unit:GetMovementType()
		local movement_range = self.unit:GetMovementRange()
		local overlay_type = 1

		if self.unit:HasMovedThisTurn() or (not TurnManager:HasActionPoints(self.player_id)) then
			overlay_type = 0
		end

		if movement_type == "Queen" then
			self.path_grid = Tactics:CalculateQueenPath(self.position.x, self.position.y, movement_range, self.player_id)
			self.path_pfx = Tactics:DrawPath(self.path_grid, overlay_type, self.player_id)
		elseif movement_type == "Rook" then
			self.path_grid = Tactics:CalculateRookPath(self.position.x, self.position.y, movement_range, self.player_id)
			self.path_pfx = Tactics:DrawPath(self.path_grid, overlay_type, self.player_id)
		elseif movement_type == "Bishop" then
			self.path_grid = Tactics:CalculateBishopPath(self.position.x, self.position.y, movement_range, self.player_id)
			self.path_pfx = Tactics:DrawPath(self.path_grid, overlay_type, self.player_id)
		elseif movement_type == "Pawn" then
			self.path_grid = Tactics:CalculatePawnPath(self.position.x, self.position.y, movement_range, self.player_id)
			self.path_pfx = Tactics:DrawPath(self.path_grid, overlay_type, self.player_id)
		end

		self:StartIntervalThink(0.03)
	end
end

function modifier_tactics_mouse_selected:OnDestroy()
	if IsServer() then
		Tactics:EraseGrid(self.active_path_pfx)
		Tactics:EraseGrid(self.path_pfx)
		ParticleManager:DestroyParticle(self.selected_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.selected_pfx)
	end
end

function modifier_tactics_mouse_selected:OnIntervalThink()
	if IsServer() then

		if self.unit:HasMovedThisTurn() or (not TurnManager:HasActionPoints(self.player_id)) then
			return nil
		end

		-- Update cursor position
		local cursor_position = Tactics:GetCursorGridPosition(self.player_id)
		local attack_target = Tactics:GetGridUnit(cursor_position.x, cursor_position.y)
		local is_attack = false
		if attack_target and attack_target:GetTeam() ~= self.team then
			is_attack = true
		end

		if cursor_position.x ~= self.cursor_position.x or cursor_position.y ~= self.cursor_position.y then
			self.cursor_position.x = cursor_position.x
			self.cursor_position.y = cursor_position.y
			Tactics:EraseGrid(self.active_path_pfx)
			if Tactics:IsGridCoordInPath(cursor_position.x, cursor_position.y, self.path_grid) then
				self.active_path_pfx = Tactics:DrawPath(Tactics:CalculateActivePath(self.position.x, self.position.y, cursor_position.x, cursor_position.y, self.path_grid, self.player_id), 2, self.player_id)
				if is_attack  then
					table.insert(self.active_path_pfx, Tactics:DrawOffensiveFixedAreaOverlayElement(cursor_position.x, cursor_position.y, self.team))
				else
					table.insert(self.active_path_pfx, Tactics:DrawMovementOverlayEndpoint(cursor_position.x, cursor_position.y, self.team))
				end
			end
		end

		-- Resolve movement if an appropriate mouse button was clicked
		if Tactics:GetLeftMousePressed(self.player_id) or Tactics:GetRightMousePressed(self.player_id) then
			if Tactics:IsGridCoordInPath(cursor_position.x, cursor_position.y, self.path_grid) and not (cursor_position.x == self.position.x and cursor_position.y == self.position.y) then

				-- If this is an attack, resolve it and adjust the movement destination
				if is_attack then
					if cursor_position.x > self.position.x then
						cursor_position.x = cursor_position.x - 1
					elseif cursor_position.x < self.position.x then
						cursor_position.x = cursor_position.x + 1
					end
					if cursor_position.y > self.position.y then
						cursor_position.y = cursor_position.y - 1
					elseif cursor_position.y < self.position.y then
						cursor_position.y = cursor_position.y + 1
					end
				end

				-- Perform movement
				Tactics:SetPlayerBusy(self.player_id)
				Tactics:SetEmpty(self.position.x, self.position.y)
				local move_loc = Tactics:GetWorldCoordinatesFromGrid(cursor_position.x, cursor_position.y)
				local move_time = (move_loc - self.unit:GetAbsOrigin()):Length2D() / 550
				self.unit:MoveToPosition(move_loc)
				self.unit:SetHasMovedThisTurn()
				if is_attack then
					self.unit:AddNewModifier(self.unit, nil, "modifier_tactics_moving", {attack_target = attack_target:GetEntityIndex(), duration = move_time})
				else
					self.unit:AddNewModifier(self.unit, nil, "modifier_tactics_moving", {duration = move_time + 0.2})
				end

				-- Spend action point
				TurnManager:SpendActionPoint(self.player_id)

				-- Clean up
				self:Destroy()
				Tactics:ClearLeftMousePressed(self.player_id)
				Tactics:ClearRightMousePressed(self.player_id)
				return nil

			-- Invalid command, ignore
			else
				Tactics:ClearLeftMousePressed(self.player_id)
				Tactics:ClearRightMousePressed(self.player_id)
			end
		end
	end
end



modifier_tactics_active_skill = class({})

function modifier_tactics_active_skill:IsDebuff() return true end
function modifier_tactics_active_skill:IsHidden() return true end
function modifier_tactics_active_skill:IsPurgable() return false end
function modifier_tactics_active_skill:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_active_skill:OnCreated(keys)
	if IsServer() then
		self.player_id = keys.player_id
		self.area_grid = {}
		self.area_pfx = {}
		self.cursor_position = Tactics:GetCursorGridPosition(self.player_id)
		self.caster_position = self:GetParent():GetBoardPosition()
		self.is_area_mobile = true
		local ability_name = self:GetAbility():GetAbilityName()

		-- Determine area to show based on the ability being used
		if ability_name == "tactics_hoof_stomp" or ability_name == "tactics_poison_nova" then
			self.area_grid = Tactics:CalculateQueenArea(self.caster_position.x, self.caster_position.y, self:GetAbility():GetTacticsRange())
			self.is_area_mobile = false
			for key, grid_square in pairs(self.area_grid) do
				if grid_square.x == self.caster_position.x and grid_square.y == self.caster_position.y then
					table.remove(self.area_grid, key)
					break
				end
			end
		elseif ability_name == "tactics_health_pulse" then
			self.area_grid = Tactics:CalculateQueenArea(self.caster_position.x, self.caster_position.y, self:GetAbility():GetTacticsRange())
			self.is_area_mobile = false
		elseif ability_name == "tactics_burrowstrike" then
			if Tactics:IsEmpty(self.cursor_position.x, self.cursor_position.y) then
				local path_grid = Tactics:CalculateRookArea(self.caster_position.x, self.caster_position.y, self:GetAbility():GetTacticsRange())
				self.area_grid = Tactics:CalculateActivePath(self.caster_position.x, self.caster_position.y, self.cursor_position.x, self.cursor_position.y, path_grid, self.player_id)
			end
		elseif ability_name == "tactics_earth_spike" then
			local x_direction = 0
			local y_direction = 0
			if self.cursor_position.x < self.caster_position.x then
				x_direction = -1
			elseif self.cursor_position.x > self.caster_position.x then
				x_direction = 1
			elseif self.cursor_position.y < self.caster_position.y then
				y_direction = -1
			elseif self.cursor_position.y > self.caster_position.y then
				y_direction = 1
			end
			
			self.area_grid = Tactics:CalculateLineArea(self.caster_position.x, self.caster_position.y, x_direction, y_direction, self:GetAbility():GetTacticsRange())
		elseif ability_name == "tactics_sprout" then
			self.area_grid = Tactics:CalculateSquareArea(self.cursor_position.x, self.cursor_position.y, 1)
			for key, grid_square in pairs(self.area_grid) do
				if grid_square.x == self.cursor_position.x and grid_square.y == self.cursor_position.y then
					table.remove(self.area_grid, key)
					break
				end
			end
		elseif ability_name == "tactics_decay" then
			self.area_grid = Tactics:CalculateSquareArea(self.cursor_position.x, self.cursor_position.y, 1)
		else
			self.area_grid = Tactics:CalculateSquareArea(self.cursor_position.x, self.cursor_position.y, 0)
		end

		-- Draw it
		if self:IsCursorOnValidPosition() then
			if ability_name == "tactics_sprout" or ability_name == "tactics_blink" then
				self.area_pfx = Tactics:DrawBuildingArea(self.area_grid, self.player_id)
			elseif self:GetAbility():GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY then
				self.area_pfx = Tactics:DrawOffensiveArea(self.area_grid, self.player_id)
			elseif self:GetAbility():GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
				self.area_pfx = Tactics:DrawFriendlyArea(self.area_grid, self.player_id)
			end
		elseif ability_name == "tactics_hoof_stomp" or ability_name == "tactics_poison_nova" then
			self.area_pfx = Tactics:DrawOffensiveArea(self.area_grid, self.player_id)
		elseif ability_name == "tactics_health_pulse" then
			self.area_pfx = Tactics:DrawFriendlyArea(self.area_grid, self.player_id)
		end

		if self.is_area_mobile then
			self:StartIntervalThink(0.03)
		end
	end
end

function modifier_tactics_active_skill:OnIntervalThink()
	if IsServer() then
		local cursor_position = Tactics:GetCursorGridPosition(self.player_id)
		if cursor_position.x ~= self.cursor_position.x or cursor_position.y ~= self.cursor_position.y then
			if not self:IsCursorOnValidPosition() then
				Tactics:EraseGrid(self.area_pfx)
			else
				self.cursor_position.x = cursor_position.x
				self.cursor_position.y = cursor_position.y

				Tactics:EraseGrid(self.area_pfx)

				local ability_name = self:GetAbility():GetAbilityName()

				if ability_name == "tactics_burrowstrike" then
					if Tactics:IsEmpty(self.cursor_position.x, self.cursor_position.y) then
						local path_grid = Tactics:CalculateRookArea(self.caster_position.x, self.caster_position.y, self:GetAbility():GetTacticsRange())
						self.area_grid = Tactics:CalculateActivePath(self.caster_position.x, self.caster_position.y, self.cursor_position.x, self.cursor_position.y, path_grid, self.player_id)
					end
				elseif ability_name == "tactics_earth_spike" then
					local x_direction = 0
					local y_direction = 0
					if self.cursor_position.x < self.caster_position.x then
						x_direction = -1
					elseif self.cursor_position.x > self.caster_position.x then
						x_direction = 1
					elseif self.cursor_position.y < self.caster_position.y then
						y_direction = -1
					elseif self.cursor_position.y > self.caster_position.y then
						y_direction = 1
					end
					
					self.area_grid = Tactics:CalculateLineArea(self.caster_position.x, self.caster_position.y, x_direction, y_direction, self:GetAbility():GetTacticsRange())
				elseif ability_name == "tactics_sprout" then
					self.area_grid = Tactics:CalculateSquareArea(self.cursor_position.x, self.cursor_position.y, 1)
					for key, grid_square in pairs(self.area_grid) do
						if grid_square.x == self.cursor_position.x and grid_square.y == self.cursor_position.y then
							table.remove(self.area_grid, key)
							break
						end
					end
				elseif ability_name == "tactics_decay" then
					self.area_grid = Tactics:CalculateSquareArea(self.cursor_position.x, self.cursor_position.y, 1)
				else
					self.area_grid = Tactics:CalculateSquareArea(self.cursor_position.x, self.cursor_position.y, 0)
				end

				-- Draw it
				if ability_name == "tactics_sprout" or ability_name == "tactics_blink" then
					self.area_pfx = Tactics:DrawBuildingArea(self.area_grid, self.player_id)
				elseif self:GetAbility():GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY then
					self.area_pfx = Tactics:DrawOffensiveArea(self.area_grid, self.player_id)
				elseif self:GetAbility():GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
					self.area_pfx = Tactics:DrawFriendlyArea(self.area_grid, self.player_id)
				end
			end
		end
	end
end

function modifier_tactics_active_skill:OnDestroy()
	if IsServer() then
		Tactics:EraseGrid(self.area_pfx)
	end
end

function modifier_tactics_active_skill:IsCursorOnValidPosition()
	local cursor_position = Tactics:GetCursorGridPosition(self.player_id)
	for _, grid_square in pairs(Tactics.player_ability_preview_overlay_path_grid[self.player_id]) do
		if grid_square.x == cursor_position.x and grid_square.y == cursor_position.y then
			return true
		end
	end
	return false
end