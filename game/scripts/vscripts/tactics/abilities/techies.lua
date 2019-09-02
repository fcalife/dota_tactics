--	Techies' Proximity Mine

LinkLuaModifier("modifier_tactics_proximity_mine", "tactics/abilities/techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_proximity_mine_thinker", "tactics/abilities/techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_proximity_mine_detected", "tactics/abilities/techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tactics_proximity_mine_spent", "tactics/abilities/techies", LUA_MODIFIER_MOTION_NONE)

tactics_proximity_mine = class({})

function tactics_proximity_mine:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		local caster_position = caster:GetBoardPosition()
		local target_position = Tactics:GetGridCoordinatesFromWorld(target.x, target.y)
		local player_id = caster:GetTacticsPlayerID()
		local mana_cost = math.max(0, 1 - caster:GetManaCostReduction())
		local caster_team = caster:GetTeam()

		-- Check player and unit resources
		local valid_cast = false

		local valid_positions = Tactics:CalculateQueenArea(caster_position.x, caster_position.y, self:GetTacticsRange())
		for _, valid_position in pairs(valid_positions) do
			if (valid_position.x == target_position.x) and (valid_position.y == target_position.y) and (Tactics:IsEmpty(target_position.x, target_position.y) or Tactics:GetGridUnitTeam(target_position.x, target_position.y) == caster_team) then
				valid_cast = true
				break
			end
		end

		if Tactics:IsMine(target_position.x, target_position.y) then
			valid_cast = false
		end

		valid_cast = valid_cast and TurnManager:HasActionPoints(player_id)
		valid_cast = valid_cast and (not caster:HasCastedThisTurn())
		valid_cast = valid_cast and (TurnManager:GetMana(player_id) >= mana_cost)

		-- If this cast is valid, perform the ability
		if valid_cast then

			-- Spend resources
			caster:SetHasCastedThisTurn()
			caster:ProcessCastModifiers()
			TurnManager:SpendActionPoint(player_id)
			TurnManager:SpendMana(player_id, mana_cost)
			Tactics:SetPlayerBusy(player_id)

			-- Perform the spell
			caster:FaceTowards(target)
			caster:AddNewModifier(caster, self, "modifier_tactics_proximity_mine", {duration = 0.47})
			caster:EmitSound("Hero_Techies.LandMine.Plant")
			local mine = CreateUnitByName("npc_tactics_mine", Tactics:GetWorldCoordinatesFromGrid(target_position.x, target_position.y), true, nil, nil, caster_team)
			Tactics:SetMine(target_position.x, target_position.y)
			mine:AddNewModifier(caster, self, "modifier_tactics_proximity_mine_thinker", {})
		end
	end
end

function tactics_proximity_mine:GetTacticsRangeType()
	return "queen"
end

function tactics_proximity_mine:GetTacticsRange()
	return 1
end

function tactics_proximity_mine:GetTacticsIgnoresObstacles()
	return false
end

function tactics_proximity_mine:GetTacticsCanTargetUnits()
	return false
end



modifier_tactics_proximity_mine = class({})

function modifier_tactics_proximity_mine:IsDebuff() return false end
function modifier_tactics_proximity_mine:IsHidden() return true end
function modifier_tactics_proximity_mine:IsPurgable() return false end
function modifier_tactics_proximity_mine:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_proximity_mine:CheckState()
	if IsServer() then
		local states = {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
		return states
	end
end

function modifier_tactics_proximity_mine:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_tactics_proximity_mine:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function modifier_tactics_proximity_mine:OnDestroy()
	if IsServer() then

		-- Resolve end of cast
		local caster = self:GetParent()
		local team = caster:GetTeam()
		local world_position = caster:GetAbsOrigin()
		local player_id = caster:GetTacticsPlayerID()

		-- Resume facing the enemy
		if team == DOTA_TEAM_GOODGUYS then
			caster:FaceTowards(world_position + Vector(0, 100, 0))
		elseif team == DOTA_TEAM_BADGUYS then
			caster:FaceTowards(world_position + Vector(0, -100, 0))
		end
		Tactics:ClearPlayerBusy(player_id)
	end
end



modifier_tactics_proximity_mine_thinker = class({})

function modifier_tactics_proximity_mine_thinker:IsDebuff() return false end
function modifier_tactics_proximity_mine_thinker:IsHidden() return true end
function modifier_tactics_proximity_mine_thinker:IsPurgable() return false end
function modifier_tactics_proximity_mine_thinker:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tactics_proximity_mine_thinker:CheckState()
	local states = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true
	}
	return states
end

function modifier_tactics_proximity_mine_thinker:OnCreated(keys)
	if IsServer() then
		self.world_position = self:GetParent():GetAbsOrigin()
		self.grid_position = Tactics:GetGridCoordinatesFromWorld(self.world_position.x, self.world_position.y)
		self:StartIntervalThink(0.03)
	end
end

function modifier_tactics_proximity_mine_thinker:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_tactics_proximity_mine_spent") then
			local units = FindUnitsInRadius(parent:GetTeam(), self.world_position, nil, 192, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(units) do
				if not enemy:HasModifier("modifier_tactics_proximity_mine_detected") then
					parent:EmitSound("Hero_Techies.LandMine.Priming")
					enemy:AddNewModifier(parent, self:GetAbility(), "modifier_tactics_proximity_mine_detected", {duration = 3})
				end
			end

			local units = FindUnitsInRadius(parent:GetTeam(), self.world_position, nil, 64, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
			if #units > 0 then
				parent:EmitSound("Hero_Techies.LandMine.Detonate")

				local blast_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(blast_pfx, 0, parent:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(blast_pfx)

				CombatManager:DealDamage(parent, units[1], 350, DAMAGE_TYPE_MAGICAL)
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_tactics_proximity_mine_spent", {})

				if not units[1]:IsAlive() then
					local modifiers = units[1]:FindAllModifiers()
					for _, modifier in pairs(modifiers) do
						modifier:Destroy()
					end
				end
				self:Destroy()
			end
		end
	end
end

function modifier_tactics_proximity_mine_thinker:Destroy()
	if IsServer() then
		local parent = self:GetParent()
		parent:Kill(self:GetAbility(), parent)
		Tactics:ClearMine(self.grid_position.x,self.grid_position.y)
	end
end

modifier_tactics_proximity_mine_detected = class({})

function modifier_tactics_proximity_mine_detected:IsDebuff() return false end
function modifier_tactics_proximity_mine_detected:IsHidden() return true end
function modifier_tactics_proximity_mine_detected:IsPurgable() return false end
function modifier_tactics_proximity_mine_detected:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

modifier_tactics_proximity_mine_spent = class({})

function modifier_tactics_proximity_mine_spent:IsDebuff() return false end
function modifier_tactics_proximity_mine_spent:IsHidden() return true end
function modifier_tactics_proximity_mine_spent:IsPurgable() return false end
function modifier_tactics_proximity_mine_spent:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end