-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
  if GameMode._reentrantCheck then
    return
  end

  local newState = GameRules:State_Get()
  if IsServer() then
    if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
      self.bSeenWaitForPlayers = true
      GameMode:OnGameStatePlayersLoading()
    elseif newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
      GameMode:OnGameStateGameSetup()
    elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
      GameMode:PostLoadPrecache()
      GameMode:OnGameStateHeroSelect()
    elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
      GameMode:OnGameStateStrategyTime()
    elseif newState == DOTA_GAMERULES_STATE_TEAM_SHOWCASE then
      GameMode:OnGameStateShowcaseTime()
    elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
      GameMode:OnGameStatePreGame()
    elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
      GameMode:OnGameInProgress()
    end
  end

  GameMode._reentrantCheck = true
  GameMode:OnGameRulesStateChange(keys)
  GameMode._reentrantCheck = false
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:_OnNPCSpawned(keys)
  if GameMode._reentrantCheck then
    return
  end

  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    GameMode:OnHeroInGame(npc)
  end

  GameMode._reentrantCheck = true
  GameMode:OnNPCSpawned(keys)
  GameMode._reentrantCheck = false
end

-- An entity died
function GameMode:_OnEntityKilled( keys )
  if GameMode._reentrantCheck then
    return
  end

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then
    DebugPrint("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
  end

  GameMode._reentrantCheck = true
  GameMode:OnEntityKilled( keys )
  GameMode._reentrantCheck = false
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
  if GameMode._reentrantCheck then
    return
  end

  GameMode:_CaptureGameMode()

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  local userID = keys.userid

  self.vUserIds = self.vUserIds or {}
  self.vUserIds[userID] = ply

  GameMode._reentrantCheck = true
  GameMode:OnConnectFull( keys )
  GameMode._reentrantCheck = false
end