-- Core initialization
if Tactics == nil then
	_G.Tactics = class({})
end

-- Extra files
require('tactics/overlays')
require('tactics/units')
require('tactics/cursor_tracking')
require('tactics/turn_manager')
require('tactics/combat_manager')
require('tactics/modifier/universal_modifiers')
require('tactics/modifier/selection_modifiers')
require('tactics/modifier/rune_modifiers')

-- Core dota tactics functions
function Tactics:Init()

	print("Initializing dota tactics core...")

	-- Load KVs
	self.unit_stats = LoadKeyValues("scripts/npc/npc_units_custom.txt")

	-- Universal modifiers
	--LinkLuaModifier("modifier_royale_level_damage", "royale/modifier_royale_level_stats.lua", LUA_MODIFIER_MOTION_NONE)

	-- Listeners
	CustomGameEventManager:RegisterListener("mouse_position_think", Dynamic_Wrap(Tactics, "MousePositionThink"))
	CustomGameEventManager:RegisterListener("left_mouse_pressed", Dynamic_Wrap(Tactics, "LeftMousePressed"))
	CustomGameEventManager:RegisterListener("right_mouse_pressed", Dynamic_Wrap(Tactics, "RightMousePressed"))
	CustomGameEventManager:RegisterListener("refresh_movement", Dynamic_Wrap(Tactics, "CheatRefreshMovement"))
	CustomGameEventManager:RegisterListener("end_turn", Dynamic_Wrap(TurnManager, "PlayerRequestedEndTurn"))

	-- Globals
	--SendToConsole("dota_create_fake_clients")

	-- Detect proper player ids
	self.radiant_player_id = 1
	self.dire_player_id = 2
	for id = 0, 40 do
		if PlayerResource:IsValidPlayer(id) then
			if PlayerResource:GetTeam(id) == DOTA_TEAM_GOODGUYS then
				self.radiant_player_id = id
			elseif PlayerResource:GetTeam(id) == DOTA_TEAM_BADGUYS then
				self.dire_player_id = id
			end
		end
	end

	self.is_player_busy = {}
	self.is_player_busy[self.radiant_player_id] = false
	self.is_player_busy[self.dire_player_id] = false

	-- Initialize player mouse cursor position tracking
	self.player_cursor_grid_position = {}

	self.player_cursor_grid_position[self.radiant_player_id] = {}
	self.player_cursor_grid_position[self.dire_player_id] = {}

	self.player_cursor_grid_position[self.radiant_player_id].x = 0
	self.player_cursor_grid_position[self.radiant_player_id].y = 0
	self.player_cursor_grid_position[self.radiant_player_id]["left_button_down"] = false
	self.player_cursor_grid_position[self.radiant_player_id]["right_button_down"] = false
	self.player_cursor_grid_position[self.radiant_player_id]["hovered_unit"] = false
	self.player_cursor_grid_position[self.radiant_player_id]["selected_unit"] = false

	self.player_cursor_grid_position[self.dire_player_id].x = 0
	self.player_cursor_grid_position[self.dire_player_id].y = 0
	self.player_cursor_grid_position[self.dire_player_id]["left_button_down"] = false
	self.player_cursor_grid_position[self.dire_player_id]["right_button_down"] = false
	self.player_cursor_grid_position[self.dire_player_id]["hovered_unit"] = false
	self.player_cursor_grid_position[self.dire_player_id]["selected_unit"] = false

	-- Initialize player ability cast tracking
	self.player_ability_preview_index = {}
	self.player_ability_preview_overlay = {}
	self.player_ability_preview_overlay_path_grid = {}

	self.player_ability_preview_index[self.radiant_player_id] = -1
	self.player_ability_preview_index[self.dire_player_id] = -1
	self.player_ability_preview_overlay[self.radiant_player_id] = -1
	self.player_ability_preview_overlay[self.dire_player_id] = -1
	self.player_ability_preview_overlay_path_grid[self.radiant_player_id] = -1
	self.player_ability_preview_overlay_path_grid[self.dire_player_id] = -1

	-- Empty board setup
	self.game_board = {}
	for x = 1, 12 do
		self.game_board[x] = {}
		for y = 1, 12 do
			self.game_board[x][y] = {}
			self.game_board[x][y]["pos"] = Vector(128 + 256 * (x - 7), 128 + 256 * (y - 7), -128)
			if (x + y) <= 3 or (x + y) >= 23 or (x - y) >= 10 or (y - x) >= 10 then
				self:SetObstacle(x, y)
			else
				self:SetEmpty(x, y)
			end
		end
	end

	-- Generate and initialize map
	self:InitializeMap()

	-- Spawn units in the chosen places
	self:SpawnInitialUnits(self.initial_positions)

	-- Initialize the turn manager
	TurnManager:Init()
end

function Tactics:CheatRefreshMovement()
	for _, unit in pairs(Tactics:GetAllUnits()) do
		unit:ClearHasMovedThisTurn()
	end
end

-- Basic functions
function Tactics:Flip(x)
	return 13 - x
end

function Tactics:GetWorldCoordinatesFromGrid(x, y)
	return Vector(128 + 256 * (x - 7), 128 + 256 * (y - 7), -128)
end

function Tactics:GetGridCoordinatesFromWorld(world_x, world_y)
	local grid_loc = {}

	grid_loc.x = math.ceil( (world_x + 1536) / 256 )
	grid_loc.y = math.ceil( (world_y + 1536) / 256 )

	return grid_loc
end

function Tactics:SetMine(x, y)
	self.game_board[x][y]["mine"] = true
end

function Tactics:IsMine(x, y)
	if self.game_board[x][y]["mine"] then
		return self.game_board[x][y]["mine"]
	else
		return nil
	end
end

function Tactics:ClearMine(x, y)
	self.game_board[x][y]["mine"] = nil
end

function Tactics:SetEmpty(x, y)
	self:SetGridContent(x, y, "empty")
end

function Tactics:SetObstacle(x, y)
	self:SetGridContent(x, y, "obstacle")
end

function Tactics:SetPlacement(x, y)
	self:SetGridContent(x, y, "placement")
end

function Tactics:SetGridContent(x, y, content)
	self.game_board[x][y]["content"] = content
end

function Tactics:GetGridContent(x, y)
	if x < 1 or x > 12 or y < 1 or y > 12 then
		return "obstacle"
	else
		return self.game_board[x][y]["content"]
	end
end

function Tactics:GetAllUnits()
	local units = {}
	for i = 1, 12 do
		for j = 1, 12 do
			if self:IsUnit(i, j) then
				if not self:GetGridContent(i, j):IsNull() then
					table.insert(units, self:GetGridContent(i, j))
				end
			end
		end
	end
	return units
end

function Tactics:GetKing(team)
	for i = 1, 12 do
		for j = 1, 12 do
			if self:IsUnit(i, j) then
				local unit = self:GetGridContent(i, j)
				if unit and unit:GetTeam() == team and unit:HasModifier("modifier_tactics_unit") then
					if unit:FindModifierByName("modifier_tactics_unit").is_king then
						return unit
					end 
				end
			end
		end
	end
end

function Tactics:IsEmpty(x, y)
	if self:GetGridContent(x, y) == "empty" then
		return true
	else
		return false
	end
end

function Tactics:IsObstacle(x, y)
	if self:GetGridContent(x, y) == "obstacle" then
		return true
	else
		return false
	end
end

function Tactics:IsPlacement(x, y)
	if self:GetGridContent(x, y) == "placement" then
		return true
	else
		return false
	end
end

function Tactics:IsUnit(x, y)
	if self:IsEmpty(x, y) or self:IsObstacle(x, y) or self:IsPlacement(x, y) then
		return false
	else
		return true
	end
end

function Tactics:IsTraversable(x, y)
	
	-- Obstacles and units are not traversable
	if self:IsObstacle(x, y) or self:IsUnit(x, y) then
		return false
	end

	return true
end

function Tactics:GetGridUnit(x, y)
	if self:IsUnit(x, y) then
		return self:GetGridContent(x, y)
	else
		return nil
	end
end

function Tactics:GetGridUnitTeam(x, y)
	if self:IsUnit(x, y) then
		return self:GetGridContent(x, y):GetTeam()
	else
		return nil
	end
end

function Tactics:IsGridCoordInPath(x, y, path_grid)
	for _, grid in pairs(path_grid) do
		if x == grid.x and y == grid.y then
			return true
		end
	end
	return false
end 

function Tactics:GetRadiantPlayerID()
	return self.radiant_player_id
end

function Tactics:GetDirePlayerID()
	return self.dire_player_id
end

function Tactics:GetEnemyPlayerID(player_id)
	if player_id == self.radiant_player_id then
		return self.dire_player_id
	elseif player_id == self.dire_player_id then
		return self.radiant_player_id
	else
		return nil
	end
end


-- Map generation functions
function Tactics:InitializeMap()
	print(" --- Generating random map elements")
	self:GenerateObstacles()
	self:GenerateRunes()
	self.initial_positions = self:GenerateInitialPositions()
	print("Finished map generation")
end

function Tactics:GenerateObstacles()
	local obstacle_area = 0
	local obstacle_count = 0
	local keep_generating_obstacles = true

	print(" --- Generating map obstacles")
	while keep_generating_obstacles do
		local added_area = self:GenerateObstacle(obstacle_count, obstacle_area)
		obstacle_area = obstacle_area + added_area
		obstacle_count = obstacle_count + math.min(1, added_area)

		if RollPercentage(15 * math.max(0, obstacle_count - 2) + 5 * math.max(0, obstacle_area - 6)) then
			keep_generating_obstacles = false
		end
	end
	print("Finished obstacle generation")
end

function Tactics:GenerateObstacle(current_count, current_area)
	--local area = RandomInt(1, 6 - math.floor(current_area * 0.25))
	local area = 1
	local actual_area = self:SpawnObstacle(area)
	return actual_area
end

function Tactics:SpawnObstacle(area)
	
	-- Pick a obstacle type of the chosen area
	local obstacle = self:PickRandomObstacleOfArea(area)

	-- Find a random placement (try up to 10 times)
	local is_valid_position = false
	local x = RandomInt(1, 13 - obstacle.width)
	local y = RandomInt(4, 7 - obstacle.height)
	for i = 1, 10 do
		is_valid_position = true
		for _, coords in pairs(obstacle.grid) do
			if self:IsObstacle(x + coords.x, y + coords.y) or self:IsObstacle(x + coords.x + 1, y + coords.y + 1) or self:IsObstacle(x + coords.x + 1, y + coords.y - 1) or self:IsObstacle(x + coords.x - 1, y + coords.y - 1) or self:IsObstacle(x + coords.x - 1, y + coords.y + 1) or (x + coords.x == 6 and y + coords.y == 6) or (x + coords.x == 7 and y + coords.y == 6) then
				is_valid_position = false
			end
		end
		if is_valid_position then
			break
		end
	end

	-- Spawn the obstacle
	if not is_valid_position then
		print("Invalid obstacle position, ignoring")
		return 0
	else

		-- Regular obstacle
		self:SetObstacle(x, y)
		CreateUnitByNameAsync(obstacle.name, self:GetWorldCoordinatesFromGrid(x, y), true, nil, nil, DOTA_TEAM_NEUTRALS, function(spawned_unit)
			spawned_unit:FaceTowards(spawned_unit:GetAbsOrigin() + RandomVector(100))
			spawned_unit:AddNewModifier(spawned_unit, nil, "modifier_tactics_obstacle", {})
		end)

		-- Mirrored obstacle
		x = self:Flip(x)
		y = self:Flip(y)
		self:SetObstacle(x, y)
		CreateUnitByNameAsync(obstacle.name, self:GetWorldCoordinatesFromGrid(x, y), true, nil, nil, DOTA_TEAM_NEUTRALS, function(spawned_unit)
			spawned_unit:FaceTowards(spawned_unit:GetAbsOrigin() + RandomVector(100))
			spawned_unit:AddNewModifier(spawned_unit, nil, "modifier_tactics_obstacle", {})
		end)

		return area
	end
end

function Tactics:PickRandomObstacleOfArea(area)
	local obstacle = {}
	obstacle.grid = {}
	if area == 1 then
		obstacle.name = "npc_tactics_obstacle_1x1_a"
		obstacle.width = 1
		obstacle.height = 1
		obstacle.grid[1] = Vector(0, 0)
		print("Positioning 1x1 obstacle...")
	end
	return obstacle
end

function Tactics:GenerateRunes()
	local runes = {}
	if RollPercentage(50) then
		runes[1] = "regen"
		runes[2] = "dd"
	else
		runes[1] = "dd"
		runes[2] = "regen"
	end

	print(" --- Generating runes")
	-- Find a position for the left rune
	print("Positioning left rune...")
	local need_position = true
	while need_position do
		local x = RandomInt(1, 5)
		local y = RandomInt(4, 6)
		if self:IsEmpty(x, y) then
			need_position = false
			self:SetRune(x, y, runes[1])
			self:SetRune(self:Flip(x), self:Flip(y), runes[1])
			self:SpawnRune(x, y)
			self:SpawnRune(self:Flip(x), self:Flip(y))
		end
	end

	-- Find a position for the right rune
	print("Positioning right rune...")
	need_position = true
	while need_position do
		local x = RandomInt(8, 12)
		local y = RandomInt(4, 6)
		if self:IsEmpty(x, y) then
			need_position = false
			self:SetRune(x, y, runes[2])
			self:SetRune(self:Flip(x), self:Flip(y), runes[2])
			self:SpawnRune(x, y)
			self:SpawnRune(self:Flip(x), self:Flip(y))
		end
	end
	print("Finished rune generation")
end

function Tactics:GenerateInitialPositions()
	local valid_positions = {}
	valid_positions[1] = Vector(3, 1)
	valid_positions[2] = Vector(4, 1)
	valid_positions[3] = Vector(5, 1)
	valid_positions[4] = Vector(6, 1)
	valid_positions[5] = Vector(7, 1)
	valid_positions[6] = Vector(8, 1)
	valid_positions[7] = Vector(9, 1)
	valid_positions[8] = Vector(10, 1)
	valid_positions[9] = Vector(2, 2)
	valid_positions[10] = Vector(3, 2)
	valid_positions[11] = Vector(4, 2)
	valid_positions[12] = Vector(5, 2)
	valid_positions[13] = Vector(6, 2)
	valid_positions[14] = Vector(7, 2)
	valid_positions[15] = Vector(8, 2)
	valid_positions[16] = Vector(9, 2)
	valid_positions[17] = Vector(10, 2)
	valid_positions[18] = Vector(11, 2)

	print(" --- Generating initial piece placement positions")
	local initial_positions = {}

	-- King position
	local rand = RandomInt(1, 8)
	initial_positions[1] = valid_positions[rand]
	self:SetPlacement(initial_positions[1].x, initial_positions[1].y)
	self:SetPlacement(self:Flip(initial_positions[1].x), self:Flip(initial_positions[1].y))
	table.remove(valid_positions, rand)

	-- Other positions
	for i = 2, 5 do
		rand = RandomInt(1, #valid_positions)
		initial_positions[i] = valid_positions[rand]
		self:SetPlacement(initial_positions[i].x, initial_positions[i].y)
		self:SetPlacement(self:Flip(initial_positions[i].x), self:Flip(initial_positions[i].y))
		table.remove(valid_positions, rand)
	end

	print("Successfully generated initial placement positions")
	return initial_positions
end



-- Runes
function Tactics:SpawnRune(x, y)
	local rune_name = self:GetRuneName(x, y)
	if rune_name then
		print("Trying to spawn "..rune_name.." rune at ("..x..", "..y..")")
		if self:GetRuneThinker(x, y) then
			print("Rune already present!")
		else
			local world_pos = self:GetWorldCoordinatesFromGrid(x, y)
			self.game_board[x][y]["rune"].thinker = CreateModifierThinker(nil, nil, "modifier_tactics_"..rune_name.."_rune_thinker", {x = world_pos.x, y = world_pos.y}, world_pos, DOTA_TEAM_NEUTRALS, false)
			self.game_board[x][y]["rune"].model = ParticleManager:CreateParticle("particles/tactics_rune_"..rune_name.."_pickup.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(self.game_board[x][y]["rune"].model, 0, world_pos + Vector(0, 0, 128))
			print("Rune spawned successfully!")
		end
	else
		return nil
	end
end

function Tactics:IsRune(x, y)
	if self.game_board[x][y]["rune"] then
		return true
	else
		return false
	end
end

function Tactics:SetRune(x, y, rune_name)
	local rune_ground_pfx = ParticleManager:CreateParticle("particles/tactics_rune_"..rune_name.."_ground_tile.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(rune_ground_pfx, 0, self:GetWorldCoordinatesFromGrid(x, y) + Vector(0, 0, 128))
	ParticleManager:ReleaseParticleIndex(rune_ground_pfx)
	self.game_board[x][y]["rune"] = {}
	self.game_board[x][y]["rune"].name = rune_name
end

function Tactics:GetRuneName(x, y)
	if self.game_board[x][y]["rune"] then
		return self.game_board[x][y]["rune"].name
	else
		return nil
	end
end

function Tactics:GetRuneThinker(x, y)
	if self.game_board[x][y]["rune"] then
		return self.game_board[x][y]["rune"].thinker
	else
		return nil
	end
end

function Tactics:GetRuneModel(x, y)
	if self.game_board[x][y]["rune"] then
		return self.game_board[x][y]["rune"].model
	else
		return nil
	end
end

function Tactics:ConsumeRune(x, y)
	if self.game_board[x][y]["rune"] then
		local rune_thinker = self:GetRuneThinker(x, y)
		if rune_thinker then
			rune_thinker:Destroy()
			self.game_board[x][y]["rune"].thinker = nil
			ParticleManager:DestroyParticle(self.game_board[x][y]["rune"].model, true)
			ParticleManager:ReleaseParticleIndex(self.game_board[x][y]["rune"].model)
			self.game_board[x][y]["rune"].model = nil
		end
	end
end


-- Unit spawn functions
function Tactics:SpawnUnit(x, y, unit_name, team)
	local unit = CreateUnitByName(unit_name, self:GetWorldCoordinatesFromGrid(x, y), true, nil, nil, team)
	if team == DOTA_TEAM_GOODGUYS then
		unit:FaceTowards(unit:GetAbsOrigin() + Vector(0, 100, 0))
		unit:SetControllableByPlayer(self:GetRadiantPlayerID(), true)
	elseif team == DOTA_TEAM_BADGUYS then
		unit:FaceTowards(unit:GetAbsOrigin() + Vector(0, -100, 0))
		unit:SetControllableByPlayer(self:GetDirePlayerID(), true)
	end

	unit:SetBoardPosition(x, y)
	unit:AddNewModifier(unit, nil, "modifier_tactics_unit", {})
	self:SetGridContent(x, y, unit)
	return unit
end

function Tactics:SpawnInitialUnits(initial_positions)
	print(" --- Placing units on initial positions")

	-- Spawn kings
	print("Placing kings...")
	local unit = self:SpawnUnit(initial_positions[1].x, initial_positions[1].y, "npc_tactics_king_radiant", DOTA_TEAM_GOODGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_echo_sabre")
	unit = self:SpawnUnit(self:Flip(initial_positions[1].x), self:Flip(initial_positions[1].y), "npc_tactics_king_dire", DOTA_TEAM_BADGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_echo_sabre")

	-- Spawn other units
	print("Placing main units...")
	--for i = 2, 5 do
	--	self:SpawnUnit(initial_positions[i].x, initial_positions[i].y, "npc_tactics_centaur", DOTA_TEAM_GOODGUYS)
	--	self:SpawnUnit(self:Flip(initial_positions[i].x), self:Flip(initial_positions[i].y), "npc_tactics_centaur", DOTA_TEAM_BADGUYS)
	--end

	unit = self:SpawnUnit(initial_positions[2].x, initial_positions[2].y, "npc_tactics_vengeful_spirit", DOTA_TEAM_GOODGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_echo_sabre")
	unit = self:SpawnUnit(self:Flip(initial_positions[2].x), self:Flip(initial_positions[2].y), "npc_tactics_antimage", DOTA_TEAM_BADGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_echo_sabre")

	unit = self:SpawnUnit(initial_positions[3].x, initial_positions[3].y, "npc_tactics_techies", DOTA_TEAM_GOODGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_echo_sabre")
	unit = self:SpawnUnit(self:Flip(initial_positions[3].x), self:Flip(initial_positions[3].y), "npc_tactics_skywrath_mage", DOTA_TEAM_BADGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_echo_sabre")

	unit = self:SpawnUnit(initial_positions[4].x, initial_positions[4].y, "npc_tactics_undying", DOTA_TEAM_GOODGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_mystic_staff")
	unit:AddItemByName("item_tactics_echo_sabre")
	unit = self:SpawnUnit(self:Flip(initial_positions[4].x), self:Flip(initial_positions[4].y), "npc_tactics_enigma", DOTA_TEAM_BADGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_mystic_staff")
	unit:AddItemByName("item_tactics_echo_sabre")

	unit = self:SpawnUnit(initial_positions[5].x, initial_positions[5].y, "npc_tactics_dazzle", DOTA_TEAM_GOODGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_mystic_staff")
	unit:AddItemByName("item_tactics_mystic_staff")
	unit = self:SpawnUnit(self:Flip(initial_positions[5].x), self:Flip(initial_positions[5].y), "npc_tactics_necrolyte", DOTA_TEAM_BADGUYS)
	unit:AddItemByName("item_tactics_tpscroll"):SetCurrentCharges(10)
	unit:AddItemByName("item_tactics_force_staff")
	unit:AddItemByName("item_tactics_refresher_orb")
	unit:AddItemByName("item_tactics_blink_dagger")
	unit:AddItemByName("item_tactics_mystic_staff")
	unit:AddItemByName("item_tactics_mystic_staff")

	-- Spawn pawns
	print("Placing pawns...")
	for x = 1, 12 do
		self:PlacePawn(x, 3)
	end
	for x = 2, 11 do
		self:PlacePawn(x, 2)
	end
end

function Tactics:PlacePawn(x, y)
	if self:IsEmpty(x, y) and (self:IsUnit(x - 1, y - 1) or self:IsUnit(x, y - 1) or self:IsUnit(x + 1, y - 1)) then
		local pawn_radiant = self:SpawnUnit(x, y, "npc_tactics_pawn_radiant", DOTA_TEAM_GOODGUYS)
		local pawn_dire = self:SpawnUnit(self:Flip(x), self:Flip(y), "npc_tactics_pawn_dire", DOTA_TEAM_BADGUYS)
	end
end