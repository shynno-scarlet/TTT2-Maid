if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = "Maid Knife"
SWEP.Spawnable = false
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.DrawCrosshair = true

SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "knife_desc"
}

SWEP.Icon = "vgui/ttt/icon_knife"
SWEP.IconLetter = "m"

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "knife"
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.UseHands = true

SWEP.Primary.Damage = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = GetConVar("ttt2_maid_ability_cooldown"):GetInt()

SWEP.Kind = WEAPON_SPECIAL

SWEP.HitDistance = 512

SWEP.AllowDrop = false
SWEP.IsSilent = true

-- Pull out faster than standard guns
SWEP.DeploySpeed = 5

function SWEP:IsAlivePlayer(ent)
	return ent:IsValid() and ent:IsPlayer() and ent:Alive()
end

function SWEP:IsDeadPlayer(ent)
	return ent:IsValid() and ent:IsRagdoll() and ent.player_ragdoll
end

function SWEP:PoisonedMeal(owner)
	local ent = Player:GetEyeTrace().Entity
	if SWEP:IsAlivePlayer(ent) then
		SWEP:HealingMeal(owner)
		local min = GetConVar("ttt2_maid_poison_time_min"):GetInt()
		local max = GetConVar("ttt2_maid_poison_time_max"):GetInt()
		local delay = math.random(min, max)
		timer.Simple(delay, function()
			if SWEP:IsAlivePlayer(ent) then
				ent:KillSilent()
				LANG.Msg(owner, "maid_kill", { ply = ent:Nick() }, MSG_CHAT_ROLE)
			end
		end)
		LANG.Msg(owner, "maid_poison", { ply = ent:Nick() }, MSG_CHAT_ROLE)
	else
		SWEP:SetNextSecondaryFire(0)
	end
end

function SWEP:RemoveBody(owner)
	local ent = Player:GetEyeTrace().Entity
	if SWEP:IsDeadPlayer(ent) then
		ent:Remove()
		LANG.Msg(owner, "maid_corpse_removed", { ply = ent:GetName() }, MSG_CHAT_ROLE)
	else
		SWEP:SetNextSecondaryFire(0)
	end
end

function SWEP:HealingMeal(owner)
	local ent = Player:GetEyeTrace().Entity
	if SWEP:IsAlivePlayer(ent) then
		local heal = GetConVar("ttt2_maid_heal_amount"):GetInt()
		LANG.Msg(ent, "maid_healed_you", {}, MSG_CHAT_ROLE)
		ent:SetHealth(heal + ent:GetHealth())
		LANG.Msg(owner, "maid_heal", { ply = ent:Nick() }, MSG_CHAT_ROLE)
	else
		SWEP:SetNextSecondaryFire(0)
	end
end

function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	if owner.maid_owner then
		if owner.maid_owner:GetSubRole() == ROLE_DEFECTIVE then
			SWEP:PoisonedMeal(owner)
		elseif owner.maid_owner:HasEvilTeam() then
			SWEP:RemoveBody(owner)
		elseif owner:GetTeam() != TEAM_NONE then
			SWEP:HealingMeal(owner)
		end
	end
end
