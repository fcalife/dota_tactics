-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc
require('dota_tactics')

-- BMD Libraries
require('libraries/timers')
require('libraries/playertables')
require('internal/gamesetup')
require('internal/events')
require('events')

-- Game files
require('internal/util')
require('tactics/core')

-- Global modifiers
--LinkLuaModifier("modifier_global_butt", "global_modifiers", LUA_MODIFIER_MOTION_NONE)

function Precache(context)

	-- Gamemode loading precache
	print("Performing pre-load precache")

	-- Examples
	-- PrecacheResource("particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", context)
	-- PrecacheResource("particle_folder", "particles/buildinghelper", context)
	-- PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
	-- PrecacheResource("model_folder", "particles/heroes/antimage", context)
	-- PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts", context)
	-- PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
	-- PrecacheItemByNameSync("example_ability", context)

	-- Basic stuff
	PrecacheResource("particle_folder", "particles/grid_overlays", context)
	PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf", context)
	PrecacheResource("particle", "particles/king_heal_target.vpcf", context)

	PrecacheResource("particle", "particles/tactics_rune_regen_pillar.vpcf", context)
	PrecacheResource("particle", "particles/tactics_rune_dd_pillar.vpcf", context)
	PrecacheResource("particle", "particles/tactics_rune_regen_pickup.vpcf", context)
	PrecacheResource("particle", "particles/tactics_rune_dd_pickup.vpcf", context)
	PrecacheResource("particle", "particles/tactics_rune_regen_ground_tile.vpcf", context)
	PrecacheResource("particle", "particles/tactics_rune_dd_ground_tile.vpcf", context)
	PrecacheResource("particle", "particles/echo_sabre.vpcf", context)
	PrecacheResource("particle", "particles/echo_shell.vpcf", context)
	PrecacheResource("soundfile", "soundevents/tactics_soundevents.vsndevts", context)

	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_lancer.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_creeps.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_warlock_golem.vsndevts", context)

	-- Centaur
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_centaur.vsndevts", context)
	PrecacheResource("particle", "particles/econ/items/centaur/centaur_ti6/centaur_ti6_warstomp.vpcf", context)

	-- Venomancer
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_venomancer.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_poison_venomancer.vpcf", context)

	-- Lion
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_lion.vsndevts", context)
	PrecacheResource("particle", "particles/econ/items/lion/lion_ti9/lion_spell_impale_ti9.vpcf", context)

	-- Zeus
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_zuus.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", context)

	-- Ursa
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_ursa.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf", context)

	-- Sniper
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_sniper.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_sniper.vsndevts", context)
	PrecacheResource("particle", "particles/sniper_assassinate.vpcf", context)

	-- Tusk
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_tusk.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_walruskick_txt_ult.vpcf", context)

	-- Abaddon
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_abaddon.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_abaddon.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf", context)
	PrecacheResource("particle", "particles/prismatic_shield_small.vpcf", context)
	PrecacheResource("particle", "particles/prismatic_shield.vpcf", context)
	PrecacheResource("particle", "particles/prismatic_shield_big.vpcf", context)

	-- Dark Seer
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_dark_seer.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf", context)

	-- Sand King
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_sandking.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_sandking.vsndevts", context)
	PrecacheResource("particle", "particles/econ/items/sand_king/sandking_barren_crown/sandking_rubyspire_burrowstrike.vpcf", context)

	-- Shadow Shaman
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_shadowshaman.vsndevts", context)

	-- Furion
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_furion.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_furion.vsndevts", context)

	-- Antimage
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_antimage.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", context)

	-- Skywrath Mage
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_skywrath_mage.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_skywrath_mage.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf", context)

	-- Enigma
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_enigma.vsndevts", context)

	-- Necrolyte
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_necrolyte.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_necrolyte.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_necrolyte/necrolyte_pulse_friend.vpcf", context)

	-- Vengeful Spirit
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_vengefulspirit.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", context)

	-- Undying
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_undying.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_undying.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_undying/undying_decay.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_undying/undying_decay_strength_xfer.vpcf", context)

	-- Pudge
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_pudge.vsndevts", context)

	-- Dazzle
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_dazzle.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_dazzle.vsndevts", context)
	PrecacheResource("particle", "particles/dazzle_shallow_grave.vpcf", context)

	-- Techies
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_techies.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", context)

	-- We done
	print("Finished pre-load precache")
end

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:_InitGameMode()
end