if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_maid.vmt")
end

roles.InitCustomTeam(ROLE.name, {
	icon = "vgui/ttt/dynamic/roles/icon_maid",
	color = Color(101, 82, 180)
})

function ROLE:PreInitialize()
	self.color = Color(101, 82, 180)
	self.abbr = "maid"
	self.surviveBonus = 0
	self.score.killsMultiplier = 1
	self.score.teamKillsMultiplier = -1
	self.defaultEquipment = SPECIAL_EQUIPMENT
	self.defaultTeam = TEAM_NONE
	self.isPublicRole = GetConVar("ttt2_maid_is_public_role"):GetBool()
	self.conVarData = {
		pct		  = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum	  = 1, -- maximum amount of roles in a round
		minPlayers   = 7, -- minimum amount of players until this role is able to get selected
		togglable	= true, -- option to toggle a role for a client if possible (F1 menu)
	}
end

if SERVER then
	hook.Add("TTT2OnTransferCredits", "Maid_Salary", function(send, rec, creds, is_dead)
		if rec:GetSubRole() != ROLE_MAID then
			return
		end
		if (not is_dead) and (creds >= GetConVar("ttt2_maid_salary"):GetInt()) then
			LANG.Msg(rec, "maid_got_paid", { name = send:Nick() }, MSG_CHAT_ROLE)
			if not rec.maid_paid then
				rec.maid_paid = true
				rec.maid_owner = send
				rec:UpdateTeam(send:GetTeam())
				rec:SetBaseRole(send:GetBaseRole())
				LANG.Msg(rec, "maid_work_1", {}, MSG_CHAT_ROLE)
			else
				LANG.Msg(rec, "maid_work_2", {}, MSG_CHAT_ROLE)
			end
		elseif (GetConVar("ttt2_maid_refund_credits")) then
			-- revert transaction
			send:SetCredits(send:GetCedits() + creds)
			rec:SetCredits(rec:GetCredits() - creds)
		end
	end)

	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		if not isRoleChange then return end
		ply:GiveEquipmentWeapon("weapon_ttt_maid_knife")
	end
end

function ROLE:AddToSettingsMenu(parent)
	local form = vgui.CreateTTT2Form(parent, "header_roles_additional")
	for var, val in pairs(MAID_CVARS) do
		if type(val[2]) == "boolean" then
			form:MakeCheckBox({
				serverConvar = tostring(var),
				label = "label_" .. tostring(var)
			})
		else
			form:MakeSlider({
				serverConvar = tostring(var),
				label = "label_" .. tostring(var),
				min = val[1],
				max = val[3],
				decimal = 0
			})
		end
	end
end
