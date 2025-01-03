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
SWEP.CanBuy = {}

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
SWEP.ThrowingDmg = GetConVar("ttt2_maid_throw_knife_damage")
SWEP.AngleVelocity = GetConVar("ttt2_maid_throw_angle_velocity")
SWEP.ThrowVelocity = GetConVar("ttt2_maid_throw_velocity")

-- Pull out faster than standard guns
SWEP.DeploySpeed = 5

function SWEP:IsAlivePlayer(ent)
	return ent:IsValid() and ent:IsPlayer() and ent:Alive()
end

function SWEP:IsDeadPlayer(ent)
	return ent:IsValid() and ent:IsRagdoll() and ent.player_ragdoll
end

function SWEP:PoisonedMeal(owner, ent)
	if self:IsAlivePlayer(ent) then
		self:HealingMeal(owner, ent)
		local min = GetConVar("ttt2_maid_poison_time_min"):GetInt()
		local max = GetConVar("ttt2_maid_poison_time_max"):GetInt()
		local delay = math.random(min, max)
		timer.Simple(delay, function()
			if not IsValid(self) then return end
			if self:IsAlivePlayer(ent) then
				ent:Kill()
				LANG.Msg(owner, "maid_kill", { ply = ent:Nick() }, MSG_MSTACK_ROLE)
			end
		end)
		LANG.Msg(owner, "maid_poison", { ply = ent:Nick() }, MSG_MSTACK_ROLE)
		return true
	end
end

function SWEP:RemoveBody(owner, ent)
	if self:IsDeadPlayer(ent) then
		ent:Remove()
		LANG.Msg(owner, "maid_corpse_removed", { ply = ent:GetName() }, MSG_MSTACK_ROLE)
		return true
	end
end

function SWEP:HealingMeal(owner, ent)
	if self:IsAlivePlayer(ent) then
		local heal = GetConVar("ttt2_maid_heal_amount"):GetInt()
		LANG.Msg(ent, "maid_healed_you", {}, MSG_MSTACK_ROLE)
		ent:SetHealth(heal + ent:Health())
		LANG.Msg(owner, "maid_heal", { ply = ent:Nick() }, MSG_MSTACK_ROLE)
		return true
	end
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then
		return
	end

	local owner = self:GetOwner()
	if owner.maid_owner then
		local ent = owner:GetEyeTrace().Entity
		local succ = false
		-- defective
		if owner.maid_owner:GetSubRole() == ROLE_DEFECTIVE then
			succ = self:PoisonedMeal(owner, ent)
		-- traitor team
		elseif owner.maid_owner:HasEvilTeam() then
			succ = self:RemoveBody(owner, ent)
		-- any other team
		elseif owner:GetTeam() ~= TEAM_NONE then
			succ = self:HealingMeal(owner, ent)
		end

		if succ then
			self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
		else
			self:SetNextPrimaryFire(CurTime())
		end
	end
end

function SWEP:ThrowKnife()
	local mdl = "models/weapons/w_knife_t.mdl"
	local owner = self:GetOwner()
	if (not owner) or (not owner:IsValid()) then return end

	-- client
	self:EmitSound(self.ShootSound, 75, 150)
	if CLIENT then return end

	local view = owner:GetAimVector()
	local cross = view:Cross(vector_up)
	cross:Normalize()
	cross:Mul(self.AngleVelocity:GetInt() * 100)
	local pos = view * 16
	pos:Add(owner:EyePos())

	-- create knife bullet entity
	local ent = ents.Create("prop_physics")
	ent.maid_throwing_knife = true
	ent:SetModel(mdl)
	ent:SetPos(pos)
	local angle = owner:EyeAngles()
	angle.pitch = angle.pitch + 80
	ent:SetAngles(angle)
	ent:Spawn()

	-- launch ent
	local phys = ent:GetPhysicsObject()
	view:Mul(self.ThrowVelocity:GetInt() * 100)
	view:Add(VectorRand(-10, 10))
	phys:ApplyForceCenter(view)
	phys:AddGameFlag(64)
	phys:AddGameFlag(1)
	phys:EnableCollisions(true)
	phys:SetBuoyancyRatio(1)
	phys:SetContents(1)
	phys:SetAngleDragCoefficient(0.001)
	phys:SetAngleVelocity(cross)

	-- ply dmg
	ent:AddCallback("PhysicsCollide", function(collider, data)
		local hit_ent = data.HitEntity
		if hit_ent then
			if hit_ent:IsValid() and hit_ent:IsPlayer() and (not ent:OnGround()) then
				hit_ent:TakeDamage(self.ThrowingDmg:GetInt(), owner, self)
			elseif hit_ent:IsWorld() and ent:IsValid() then
				ent:Remove()
			end
		end
	end)

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
