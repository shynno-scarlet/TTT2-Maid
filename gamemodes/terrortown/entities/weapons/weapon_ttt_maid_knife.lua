if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = "Maid Knife"
SWEP.Author = "shynno_scarlet"
SWEP.Instructions = "Primary: Throw a knife; Secondary: Use special ability"
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

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1 / GetConVar("ttt2_maid_throw_knife_speed"):GetFloat()
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = GetConVar("ttt2_maid_ability_cooldown"):GetFloat()

SWEP.Kind = WEAPON_SPECIAL

SWEP.HitDistance = 512

SWEP.AllowDrop = false
SWEP.IsSilent = true
SWEP.ShootSound = Sound("Metal.SawbladeStick")
SWEP.ThrowingDmg = GetConVar("ttt2_maid_throw_knife_damage"):GetInt()

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
	if self:IsAlivePlayer(ent) then
		self:HealingMeal(owner)
		local min = GetConVar("ttt2_maid_poison_time_min"):GetInt()
		local max = GetConVar("ttt2_maid_poison_time_max"):GetInt()
		local delay = math.random(min, max)
		timer.Simple(delay, function()
			if self:IsAlivePlayer(ent) then
				ent:KillSilent()
				LANG.Msg(owner, "maid_kill", { ply = ent:Nick() }, MSG_CHAT_ROLE)
			end
		end)
		LANG.Msg(owner, "maid_poison", { ply = ent:Nick() }, MSG_CHAT_ROLE)
	else
		self:SetNextSecondaryFire(0)
	end
end

function SWEP:RemoveBody(owner)
	local ent = Player:GetEyeTrace().Entity
	if self:IsDeadPlayer(ent) then
		ent:Remove()
		LANG.Msg(owner, "maid_corpse_removed", { ply = ent:GetName() }, MSG_CHAT_ROLE)
	else
		self:SetNextSecondaryFire(0)
	end
end

function SWEP:HealingMeal(owner)
	local ent = Player:GetEyeTrace().Entity
	if self:IsAlivePlayer(ent) then
		local heal = GetConVar("ttt2_maid_heal_amount"):GetInt()
		LANG.Msg(ent, "maid_healed_you", {}, MSG_CHAT_ROLE)
		ent:SetHealth(heal + ent:GetHealth())
		LANG.Msg(owner, "maid_heal", { ply = ent:Nick() }, MSG_CHAT_ROLE)
	else
		self:SetNextSecondaryFire(0)
	end
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then
		return
	end
	local owner = self:GetOwner()
	if owner.maid_owner then
		if owner.maid_owner:GetSubRole() == ROLE_DEFECTIVE then
			self:PoisonedMeal(owner)
		elseif owner.maid_owner:HasEvilTeam() then
			self:RemoveBody(owner)
		elseif owner:GetTeam() != TEAM_NONE then
			self:HealingMeal(owner)
		end
	end
end

function SWEP:ThrowKnife()
	local mdl = "models/weapons/cstrike/c_knife_t.mdl"
	local owner = self:GetOwner()

	local view = owner:GetAimVector()
	local pos = view * 16
	pos:Add(owner:EyePos())

	-- create knife bullet entity
	local ent = ents.Create("prop_physics")
	ent.maid_throwing_knife = true
	ent:SetModel(mdl)
	ent:SetPos(pos)
	ent:SetAngles(owner:EyeAngles())
	ent:Spawn()
	local cb = ent:AddCallback("PhysicsCollide", function(collider)
		local hit_ent = collider:GetEntity()
		if hit_ent and hit_ent:IsValid() and hit_ent:IsPlayer() then
			hit_ent:TakeDamage(self.ThrowingDmg, owner, self)
		end
		ent:RemoveCallback(cb)
	end)

	-- launch ent
	local phys = ent:GetPhysicsObject()
	view:Mul(1000)
	view:Add(VectorRand(-100, 100))
	phys:ApplyForceCenter(view)
	self:EmitSound(self.ShootSound, 75, 150)

	-- despawn after 20 sec
	timer.Simple(20, function()
		if ent and ent:IsValid() then
			ent:Remove()
		end
	end)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end
	self:ThrowKnife()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:CanPrimaryAttack()
	return CurTime() > self:GetNextPrimaryFire()
end

function SWEP:CanSecondaryAttack()
	return CurTime() > self:GetNextSecondaryFire()
end

function SWEP:Reload()
	return
end
