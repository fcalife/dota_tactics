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