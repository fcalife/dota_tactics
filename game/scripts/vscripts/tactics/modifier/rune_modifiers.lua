LinkLuaModifier("modifier_tactics_regen_rune", "tactics/modifier/rune_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_dd_rune", "tactics/modifier/rune_modifiers", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_tactics_regen_rune_thinker", "tactics/modifier/rune_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_dd_rune_thinker", "tactics/modifier/rune_modifiers", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_tactics_regen_rune_particle", "tactics/modifier/rune_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_dd_rune_particle", "tactics/modifier/rune_modifiers", LUA_MODIFIER_MOTION_NONE)



modifier_tactics_regen_rune = class({})

function modifier_tactics_regen_rune:IsDebuff() return false end
function modifier_tactics_regen_rune:IsHidden() return false end
function modifier_tactics_regen_rune:IsPurgable() return false end
function modifier_tactics_regen_rune:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_regen_rune:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_tactics_regen_rune:OnIntervalThink()
	if IsServer() then
		CombatManager:ApplyHealing(self:GetParent(), self:GetParent(), 10)
	end
end

function modifier_tactics_regen_rune:GetTexture()
	return "rune_regen"
end

function modifier_tactics_regen_rune:GetEffectName()
	return "particles/generic_gameplay/rune_regen_owner.vpcf"
end

function modifier_tactics_regen_rune:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_tactics_regen_rune_particle = class({})

function modifier_tactics_regen_rune_particle:IsDebuff() return false end
function modifier_tactics_regen_rune_particle:IsHidden() return true end
function modifier_tactics_regen_rune_particle:IsPurgable() return false end
function modifier_tactics_regen_rune_particle:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_regen_rune_particle:GetEffectName()
	return "particles/tactics_rune_regen_pillar.vpcf"
end

function modifier_tactics_regen_rune_particle:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_tactics_regen_rune_thinker = class({})

function modifier_tactics_regen_rune_thinker:IsDebuff() return false end
function modifier_tactics_regen_rune_thinker:IsHidden() return true end
function modifier_tactics_regen_rune_thinker:IsPurgable() return false end
function modifier_tactics_regen_rune_thinker:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_regen_rune_thinker:OnCreated(keys)
	if IsServer() then
		self.world_position = Vector(keys.x, keys.y, 0)
		self.grid_position = Tactics:GetGridCoordinatesFromWorld(self.world_position.x, self.world_position.y)
		self:StartIntervalThink(0.03)
	end
end

function modifier_tactics_regen_rune_thinker:OnIntervalThink()
	if IsServer() then
		local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self.world_position, nil, 64, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
		if #units > 0 then
			units[1]:EmitSound("Rune.Regen")
			units[1]:AddNewModifier(units[1], nil, "modifier_tactics_regen_rune", {duration = 5})
			units[1]:AddNewModifier(units[1], nil, "modifier_tactics_regen_rune_particle", {duration = 5})
			Tactics:ConsumeRune(self.grid_position.x, self.grid_position.y)
		end
	end
end



modifier_tactics_dd_rune = class({})

function modifier_tactics_dd_rune:IsDebuff() return false end
function modifier_tactics_dd_rune:IsHidden() return false end
function modifier_tactics_dd_rune:IsPurgable() return false end
function modifier_tactics_dd_rune:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_dd_rune:GetTexture()
	return "rune_doubledamage"
end

function modifier_tactics_dd_rune:GetEffectName()
	return "particles/generic_gameplay/rune_doubledamage_owner.vpcf"
end

function modifier_tactics_dd_rune:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tactics_dd_rune:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_tactics_dd_rune:GetModifierBaseAttack_BonusDamage()
	return 100
end

function modifier_tactics_dd_rune:OnAttackLanded(keys)
	if IsServer() then
		if keys.attacker == self:GetParent() then
			self:Destroy()
		end
	end
end


modifier_tactics_dd_rune_particle = class({})

function modifier_tactics_dd_rune_particle:IsDebuff() return false end
function modifier_tactics_dd_rune_particle:IsHidden() return true end
function modifier_tactics_dd_rune_particle:IsPurgable() return false end
function modifier_tactics_dd_rune_particle:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_dd_rune_particle:GetEffectName()
	return "particles/tactics_rune_dd_pillar.vpcf"
end

function modifier_tactics_dd_rune_particle:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_tactics_dd_rune_thinker = class({})

function modifier_tactics_dd_rune_thinker:IsDebuff() return false end
function modifier_tactics_dd_rune_thinker:IsHidden() return true end
function modifier_tactics_dd_rune_thinker:IsPurgable() return false end
function modifier_tactics_dd_rune_thinker:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_dd_rune_thinker:OnCreated(keys)
	if IsServer() then
		self.world_position = Vector(keys.x, keys.y, 0)
		self.grid_position = Tactics:GetGridCoordinatesFromWorld(self.world_position.x, self.world_position.y)
		self:StartIntervalThink(0.03)
	end
end

function modifier_tactics_dd_rune_thinker:OnIntervalThink()
	if IsServer() then
		local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self.world_position, nil, 64, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
		if #units > 0 then
			units[1]:EmitSound("Rune.DD")
			units[1]:AddNewModifier(units[1], nil, "modifier_tactics_dd_rune", {})
			units[1]:AddNewModifier(units[1], nil, "modifier_tactics_dd_rune_particle", {duration = 3})
			Tactics:ConsumeRune(self.grid_position.x, self.grid_position.y)
		end
	end
end