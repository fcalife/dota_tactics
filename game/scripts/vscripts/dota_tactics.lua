if GameMode == nil then
	print("Initializing game mode...")
	_G.GameMode = class({})
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
	GameMode = self
	print("Performing initialization tasks...")

	-- Global filter setup
	--GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "GoldFilter"), self)
	--GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, "ExpFilter"), self)
	--GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, "DamageFilter"), self)
	--GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(GameMode, "ModifierFilter"), self)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)

	-- Custom console commands
	--Convars:RegisterCommand("runes_on", Dynamic_Wrap(GameMode, 'EnableAllRunes'), "Enables all runes", FCVAR_CHEAT )
	--Convars:RegisterCommand("runes_off", Dynamic_Wrap(GameMode, 'DisableAllRunes'), "Disables all runes", FCVAR_CHEAT )

	print("Initialization tasks done!")
end

-- Global gold filter function
function GameMode:GoldFilter(keys)
	--keys.gold = 0
	return true
end

-- Global experience filter function
function GameMode:ExpFilter(keys)
	--keys.experience: 40
	--keys.player_id_const: 1
	--keys.reason_const: 1

	--local hero = PlayerResource:GetSelectedHeroEntity(keys.player_id_const)

	return true
end

-- Global damage filter function
function GameMode:DamageFilter(keys)
	-- keys.damage: 5
	-- keys.damagetype_const: 1
	-- keys.entindex_inflictor_const: 801	--optional
	-- keys.entindex_attacker_const: 172
	-- keys.entindex_victim_const: 379

	return true
end

-- Global modifier filter function
function GameMode:ModifierFilter(keys)
	--keys.duration: -1
	--keys.entindex_ability_const: 164	--optional
	--keys.entindex_caster_const: 163
	--keys.entindex_parent_const: 163
	--keys.name_const: modifier_kobold_taskmaster_speed_aura

	--local victim = EntIndexToHScript(keys.entindex_parent_const)

	return true
end

-- Global order filter function
function GameMode:OrderFilter(keys)

	-- keys.entindex_ability	 ==> 	0
	-- keys.sequence_number_const	 ==> 	20
	-- keys.queue	 ==> 	0
	-- keys.units	 ==> 	table: 0x031d5fd0
	-- keys.entindex_target	 ==> 	0
	-- keys.position_z	 ==> 	384
	-- keys.position_x	 ==> 	-5694.3334960938
	-- keys.order_type	 ==> 	1
	-- keys.position_y	 ==> 	-6381.1127929688
	-- keys.issuer_player_id_const	 ==> 	0

	--local order_type = keys.order_type

	if keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
		return false
	end

	return true
end

-- Called right after the game setup is finished, as the first player finishes loading into the game
function GameMode:OnFirstPlayerLoaded()
	print("First player has finished loading the gamemode")

end

function GameMode:OnGameStatePlayersLoading()
	print("Game state is now: players loading")
end

function GameMode:OnGameStateGameSetup()
	print("Game state is now: game setup")
end

-- Called during hero select, performs additional precaching
function GameMode:PostLoadPrecache()
	print("Performing post-load precache...")    
	--PrecacheItemByNameAsync("item_example_item", function(...) end)
	--PrecacheItemByNameAsync("example_ability", function(...) end)
	--PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
end

function GameMode:OnGameStateHeroSelect()
	print("Game state is now: hero selection")
	if USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS then
		for i = 0, 9 do
			if PlayerResource:IsValidPlayer(i) then
				local color = TEAM_COLORS[PlayerResource:GetTeam(i)]
				PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
			end
		end
	end
	Tactics:Init()
end

function GameMode:OnGameStateStrategyTime()
	print("Game state is now: strategy time")
end

function GameMode:OnGameStateShowcaseTime()
	print("Game state is now: showcase time")
end
function GameMode:OnGameStatePreGame()
	print("Game state is now: pre-game")
end

function GameMode:OnGameInProgress()
	if IsServer() then
		print("The game has officially begun")
	end
end