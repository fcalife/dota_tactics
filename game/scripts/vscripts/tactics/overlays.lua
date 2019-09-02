-- Visual overlays dota tactics functions

function Tactics:DrawDisabledMovementOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_disabled_square.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(120, 120, 120))
	return grid_pfx
end

function Tactics:DrawMovementOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_regular_square.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(230, 230, 230))
	return grid_pfx
end

function Tactics:DrawActiveMovementOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_active_square.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(255, 255, 255))
	return grid_pfx
end

function Tactics:DrawMovementOverlayEndpoint(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_select_destination.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(255, 255, 255))
	return grid_pfx
end

function Tactics:DrawMovementOverlayConfirmation(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_confirmation_end.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(255, 255, 255))
	return grid_pfx
end

function Tactics:DrawOffensiveFixedAreaOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_regular_square.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(255, 125, 0))
	return grid_pfx
end

function Tactics:DrawOffensiveAreaOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_active_square.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(255, 125, 0))
	return grid_pfx
end

function Tactics:DrawOffensiveActiveAreaOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_select_destination.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(255, 125, 0))
	return grid_pfx
end

function Tactics:DrawFriendlyFixedAreaOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_regular_square.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(0, 255, 255))
	return grid_pfx
end

function Tactics:DrawFriendlyAreaOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_active_square.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(0, 255, 255))
	return grid_pfx
end

function Tactics:DrawFriendlyActiveAreaOverlayElement(x, y, team)
	local grid_pfx = ParticleManager:CreateParticleForTeam("particles/grid_overlays/grid_select_destination.vpcf", PATTACH_CUSTOMORIGIN, nil, team)
	ParticleManager:SetParticleControl(grid_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 264))
	ParticleManager:SetParticleControl(grid_pfx, 1, Vector(0, 255, 255))
	return grid_pfx
end



-- Type 0 = disabled movement, 1 = regular, 2 = active, 3 = movement endpoint
function Tactics:DrawPath(path_grid, type, player_id)
	local overlay_pfx = {}
	local player_team = PlayerResource:GetTeam(player_id)
	for _, grid_square in pairs(path_grid) do
		if type == 0 then
			table.insert(overlay_pfx, self:DrawDisabledMovementOverlayElement(grid_square.x, grid_square.y, player_team))
		elseif type == 1 then
			table.insert(overlay_pfx, self:DrawMovementOverlayElement(grid_square.x, grid_square.y, player_team))
		elseif type == 2 then
			table.insert(overlay_pfx, self:DrawActiveMovementOverlayElement(grid_square.x, grid_square.y, player_team))
		elseif type == 3 then
			table.insert(overlay_pfx, self:DrawMovementOverlayEndpoint(grid_square.x, grid_square.y, player_team))
		end
	end

	return overlay_pfx
end

-- Predefined AOEs
function Tactics:DrawFixedOffensiveArea(area_grid, player_id)
	local overlay_pfx = {}
	local player_team = PlayerResource:GetTeam(player_id)
	for _, grid_square in pairs(area_grid) do
		if not self:IsObstacle(grid_square.x, grid_square.y) then
			table.insert(overlay_pfx, self:DrawOffensiveFixedAreaOverlayElement(grid_square.x, grid_square.y, player_team))
		end
	end

	return overlay_pfx
end

function Tactics:DrawFixedFriendlyArea(area_grid, player_id)
	local overlay_pfx = {}
	local player_team = PlayerResource:GetTeam(player_id)
	for _, grid_square in pairs(area_grid) do
		if not self:IsObstacle(grid_square.x, grid_square.y) then
			table.insert(overlay_pfx, self:DrawFriendlyFixedAreaOverlayElement(grid_square.x, grid_square.y, player_team))
		end
	end

	return overlay_pfx
end

-- Selectable AOEs
function Tactics:DrawOffensiveArea(area_grid, player_id)
	local overlay_pfx = {}
	local player_team = PlayerResource:GetTeam(player_id)
	for _, grid_square in pairs(area_grid) do
		if not self:IsObstacle(grid_square.x, grid_square.y) then
			if self:IsUnit(grid_square.x, grid_square.y) then
				if self:GetGridUnitTeam(grid_square.x, grid_square.y) ~= player_team then
					table.insert(overlay_pfx, self:DrawOffensiveActiveAreaOverlayElement(grid_square.x, grid_square.y, player_team))
				end
			else
				table.insert(overlay_pfx, self:DrawOffensiveAreaOverlayElement(grid_square.x, grid_square.y, player_team))
			end
		end
	end

	return overlay_pfx
end

function Tactics:DrawBuildingArea(area_grid, player_id)
	local overlay_pfx = {}
	local player_team = PlayerResource:GetTeam(player_id)
	for _, grid_square in pairs(area_grid) do
		if self:IsEmpty(grid_square.x, grid_square.y) then
			table.insert(overlay_pfx, self:DrawFriendlyActiveAreaOverlayElement(grid_square.x, grid_square.y, player_team))
		end
	end

	return overlay_pfx
end

function Tactics:DrawFriendlyArea(area_grid, player_id)
	local overlay_pfx = {}
	local player_team = PlayerResource:GetTeam(player_id)
	for _, grid_square in pairs(area_grid) do
		if not self:IsObstacle(grid_square.x, grid_square.y) then
			if self:IsUnit(grid_square.x, grid_square.y) then
				if self:GetGridUnitTeam(grid_square.x, grid_square.y) == player_team then
					table.insert(overlay_pfx, self:DrawFriendlyActiveAreaOverlayElement(grid_square.x, grid_square.y, player_team))
				end
			else
				table.insert(overlay_pfx, self:DrawFriendlyAreaOverlayElement(grid_square.x, grid_square.y, player_team))
			end
		end
	end

	return overlay_pfx
end

function Tactics:EraseGrid(table)
	if table and #table > 0 then
		for _, pfx in pairs(table) do
			ParticleManager:DestroyParticle(pfx, true)
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
end



-- Path/area calculations
function Tactics:CalculateActivePath(x, y, target_x, target_y, path_grid, player_id)
	local active_path_grid = {}

	-- Horizontal paths
	if y == target_y then
		if target_x > x then
			for _, grid in pairs(path_grid) do
				if grid.x > x and grid.x <= target_x and grid.y == y then
					table.insert(active_path_grid, Vector(grid.x, grid.y, 0))
				end
			end
		elseif x > target_x then
			for _, grid in pairs(path_grid) do
				if x > grid.x and grid.x >= target_x and grid.y == y then
					table.insert(active_path_grid, Vector(grid.x, grid.y, 0))
				end
			end
		end

	-- Vertical paths
	elseif x == target_x then
		if target_y > y then
			for _, grid in pairs(path_grid) do
				if grid.y > y and grid.y <= target_y and grid.x == x then
					table.insert(active_path_grid, Vector(grid.x, grid.y, 0))
				end
			end
		elseif y > target_y then
			for _, grid in pairs(path_grid) do
				if y > grid.y and grid.y >= target_y and grid.x == x then
					table.insert(active_path_grid, Vector(grid.x, grid.y, 0))
				end
			end
		end

	-- Diagonal paths
	elseif (target_x - x) == (target_y - y) or (x - target_x) == (target_y - y) then
		if target_x > x and target_y > y then
			for _, grid in pairs(path_grid) do
				if grid.x > x and grid.x <= target_x and grid.y > y then
					table.insert(active_path_grid, Vector(grid.x, grid.y, 0))
				end
			end
		elseif x > target_x and target_y > y then
			for _, grid in pairs(path_grid) do
				if grid.x < x and grid.x >= target_x and grid.y > y then
					table.insert(active_path_grid, Vector(grid.x, grid.y, 0))
				end
			end
		elseif target_x > x and y > target_y then
			for _, grid in pairs(path_grid) do
				if grid.x > x and grid.x <= target_x and grid.y < y then
					table.insert(active_path_grid, Vector(grid.x, grid.y, 0))
				end
			end
		elseif x > target_x and y > target_y then
			for _, grid in pairs(path_grid) do
				if grid.x < x and grid.x >= target_x and grid.y < y then
					table.insert(active_path_grid, Vector(grid.x, grid.y, 0))
				end
			end
		end
	end

	return active_path_grid
end

-- Assumes range > 0
function Tactics:CalculatePawnPath(x, y, range, player_id)
	local path_grid = {}
	local min_x = math.max(x - range, 1)
	local max_x = math.min(x + range, 12)
	local min_y = math.max(y - range, 1)
	local max_y = math.min(y + range, 12)
	local team = PlayerResource:GetTeam(player_id)

	-- Stop at obstacles
	for i = (x - 1), min_x, -1 do
		if not self:IsTraversable(i, y) then
			if self:IsUnit(i, y) and self:GetGridUnitTeam(i, y) ~= team then
				min_x = i
			else
				min_x = i + 1
			end
			break
		end
	end
	for i = (x + 1), max_x do
		if not self:IsTraversable(i, y) then
			if self:IsUnit(i, y) and self:GetGridUnitTeam(i, y) ~= team then
				max_x = i
			else
				max_x = i - 1
			end
			break
		end
	end
	for j = (y - 1), min_y, -1 do
		if not self:IsTraversable(x, j) then
			if self:IsUnit(x, j) and self:GetGridUnitTeam(x, j) ~= team then
				min_y = j
			else
				min_y = j + 1
			end
			break
		end
	end
	for j = (y + 1), max_y do
		if not self:IsTraversable(x, j) then
			if self:IsUnit(x, j) and self:GetGridUnitTeam(x, j) ~= team then
				max_y = j
			else
				max_y = j - 1
			end
			break
		end
	end

	-- Pawns cannot move backwards
	if player_id == self:GetRadiantPlayerID() then
		min_y = y
	elseif player_id == self:GetDirePlayerID() then
		max_y = y
	end

	-- Return path
	for i = min_x, max_x do
		table.insert(path_grid, Vector(i, y, 0))
	end

	for j = min_y, max_y do
		if j ~= y then
			table.insert(path_grid, Vector(x, j, 0))
		end
	end

	return path_grid
end

-- Assumes range > 0
function Tactics:CalculateRookPath(x, y, range, player_id)
	local path_grid = {}
	local min_x = math.max(x - range, 1)
	local max_x = math.min(x + range, 12)
	local min_y = math.max(y - range, 1)
	local max_y = math.min(y + range, 12)
	local team = PlayerResource:GetTeam(player_id)

	-- Stop at obstacles
	for i = (x - 1), min_x, -1 do
		if not self:IsTraversable(i, y) then
			if self:IsUnit(i, y) and self:GetGridUnitTeam(i, y) ~= team then
				min_x = i
			else
				min_x = i + 1
			end
			break
		end
	end
	for i = (x + 1), max_x do
		if not self:IsTraversable(i, y) then
			if self:IsUnit(i, y) and self:GetGridUnitTeam(i, y) ~= team then
				max_x = i
			else
				max_x = i - 1
			end
			break
		end
	end
	for j = (y - 1), min_y, -1 do
		if not self:IsTraversable(x, j) then
			if self:IsUnit(x, j) and self:GetGridUnitTeam(x, j) ~= team then
				min_y = j
			else
				min_y = j + 1
			end
			break
		end
	end
	for j = (y + 1), max_y do
		if not self:IsTraversable(x, j) then
			if self:IsUnit(x, j) and self:GetGridUnitTeam(x, j) ~= team then
				max_y = j
			else
				max_y = j - 1
			end
			break
		end
	end

	-- Return path
	for i = min_x, max_x do
		table.insert(path_grid, Vector(i, y, 0))
	end

	for j = min_y, max_y do
		if j ~= y then
			table.insert(path_grid, Vector(x, j, 0))
		end
	end

	return path_grid
end

function Tactics:CalculateRookArea(x, y, range)
	local area_grid = {}
	local min_x = math.max(x - range, 1)
	local max_x = math.min(x + range, 12)
	local min_y = math.max(y - range, 1)
	local max_y = math.min(y + range, 12)

	-- Return path
	for i = min_x, max_x do
		table.insert(area_grid, Vector(i, y, 0))
	end

	for j = min_y, max_y do
		if j ~= y then
			table.insert(area_grid, Vector(x, j, 0))
		end
	end

	return area_grid
end

function Tactics:CalculateLineArea(x, y, x_direction, y_direction, range)
	local area_grid = {}
	local min_x = math.max(x - range, 1)
	local max_x = math.min(x + range, 12)
	local min_y = math.max(y - range, 1)
	local max_y = math.min(y + range, 12)

	if x_direction == 1 then
		for i = x + 1, max_x do
			table.insert(area_grid, Vector(i, y, 0))
		end
	end

	if x_direction == -1 then
		for i = min_x, x - 1 do
			table.insert(area_grid, Vector(i, y, 0))
		end
	end

	if y_direction == 1 then
		for j = y + 1, max_y do
			table.insert(area_grid, Vector(x, j, 0))
		end
	end

	if y_direction == -1 then
		for j = min_y, y - 1 do
			table.insert(area_grid, Vector(x, j, 0))
		end
	end

	return area_grid
end

function Tactics:CalculateBurrowstrikeArea(x, y, range)
	local area_grid = {}
	local min_x = math.max(x - range, 1)
	local max_x = math.min(x + range, 12)
	local min_y = math.max(y - range, 1)
	local max_y = math.min(y + range, 12)

	-- Return path
	for i = min_x, max_x do
		if self:IsEmpty(i, y) then
			table.insert(area_grid, Vector(i, y, 0))
		end
	end

	for j = min_y, max_y do
		if j ~= y then
			if self:IsEmpty(x, j) then
				table.insert(area_grid, Vector(x, j, 0))
			end
		end
	end

	return area_grid
end

-- Assumes range > 0
function Tactics:CalculateBishopPath(x, y, range, player_id)
	local path_grid = {}
	local min_x = math.max(x - range, 1)
	local max_x = math.min(x + range, 12)
	local min_y = math.max(y - range, 1)
	local max_y = math.min(y + range, 12)
	local min_x_n_s = min_x
	local min_x_s_n = min_x
	local max_x_n_s = max_x
	local max_x_s_n = max_x
	local team = PlayerResource:GetTeam(player_id)

	-- Stop at obstacles
	for i = (x - 1), min_x, -1 do
		local j = y + (x - i)
		if j > max_y or not self:IsTraversable(i, j) then
			if self:IsUnit(i, j) and self:GetGridUnitTeam(i, j) ~= team then
				min_x_n_s = i
			else
				min_x_n_s = i + 1
			end
			break
		end
	end
	for i = (x + 1), max_x do
		local j = y + (x - i)
		if j < min_y or not self:IsTraversable(i, j) then
			if self:IsUnit(i, j) and self:GetGridUnitTeam(i, j) ~= team then
				max_x_n_s = i
			else
				max_x_n_s = i - 1
			end
			break
		end
	end
	for i = (x - 1), min_x, -1 do
		local j = y + (i - x)
		if j < min_y or not self:IsTraversable(i, j) then
			if self:IsUnit(i, j) and self:GetGridUnitTeam(i, j) ~= team then
				min_x_s_n = i
			else
				min_x_s_n = i + 1
			end
			break
		end
	end
	for i = (x + 1), max_x do
		local j = y + (i - x)
		if j > max_y or not self:IsTraversable(i, j) then
			if self:IsUnit(i, j) and self:GetGridUnitTeam(i, j) ~= team then
				max_x_s_n = i
			else
				max_x_s_n = i - 1
			end
			break
		end
	end

	-- Return path
	for i = min_x_n_s, max_x_n_s do
		table.insert(path_grid, Vector(i, y + (x - i), 0))
	end

	for i = min_x_s_n, max_x_s_n do
		if i ~= x then
			table.insert(path_grid, Vector(i, y + (i - x), 0))
		end
	end

	return path_grid
end

function Tactics:CalculateBishopArea(x, y, range)
	local area_grid = {}
	local min_x = math.max(x - range, 1)
	local max_x = math.min(x + range, 12)
	local min_y = math.max(y - range, 1)
	local max_y = math.min(y + range, 12)
	local min_x_n_s = min_x
	local min_x_s_n = min_x
	local max_x_n_s = max_x
	local max_x_s_n = max_x

	-- Stop at obstacles
	for i = (x - 1), min_x, -1 do
		local j = y + (x - i)
		if j > max_y then
			min_x_n_s = i + 1
			break
		end
	end
	for i = (x + 1), max_x do
		local j = y + (x - i)
		if j < min_y then
			max_x_n_s = i - 1
			break
		end
	end
	for i = (x - 1), min_x, -1 do
		local j = y + (i - x)
		if j < min_y then
			min_x_s_n = i + 1
			break
		end
	end
	for i = (x + 1), max_x do
		local j = y + (i - x)
		if j > max_y then
			max_x_s_n = i - 1
			break
		end
	end

	-- Return path
	for i = min_x_n_s, max_x_n_s do
		table.insert(area_grid, Vector(i, y + (x - i), 0))
	end

	for i = min_x_s_n, max_x_s_n do
		if i ~= x then
			table.insert(area_grid, Vector(i, y + (i - x), 0))
		end
	end

	return area_grid
end

function Tactics:CalculateQueenPath(x, y, range, player_id)
	local path_grid = self:CalculateRookPath(x, y, range, player_id)
	local bishop_grid = self:CalculateBishopPath(x, y, range, player_id)
	for _, grid_square in pairs(bishop_grid) do
		if grid_square.x ~= x and grid_square.y ~= y then
			table.insert(path_grid, grid_square)
		end
	end

	return path_grid
end

function Tactics:CalculateQueenArea(x, y, range)
	local area_grid = self:CalculateRookArea(x, y, range)
	local bishop_grid = self:CalculateBishopArea(x, y, range)
	for _, grid_square in pairs(bishop_grid) do
		if grid_square.x ~= x and grid_square.y ~= y then
			table.insert(area_grid, grid_square)
		end
	end

	return area_grid
end

function Tactics:CalculateSquareArea(x, y, range)
	local area_grid = {}
	local min_x = math.max(x - range, 1)
	local max_x = math.min(x + range, 12)
	local min_y = math.max(y - range, 1)
	local max_y = math.min(y + range, 12)

	-- Return path
	for i = min_x, max_x do
		for j = min_y, max_y do
			table.insert(area_grid, Vector(i, j, 0))
		end
	end

	return area_grid
end