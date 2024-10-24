if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_maid.vmt")
	util.AddNetworkString("ttt2_maid_thermalvis")
end

function ROLE:PreInitialize()
	self.Base = "ttt_role_base"
	self.index = ROLE_MAID
	self.name = "maid"
	self.color = Color(101, 82, 180, 255)
	self.abbr = "maid"
	self.surviveBonus = 0
	self.score.killsMultiplier = 1
	self.score.teamKillsMultiplier = -1
	self.defaultEquipment = SPECIAL_EQUIPMENT
	self.defaultTeam = TEAM_NONE
	self.unknownTeam = true
	self.conVarData = {
		pct		  = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum	  = 1, -- maximum amount of roles in a round
		minPlayers   = 7, -- minimum amount of players until this role is able to get selected
		togglable	= true, -- option to toggle a role for a client if possible (F1 menu)
		shopFallback = SHOP_DISABLED,
		credits = 0,
	}
end

if SERVER then
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		ply:GetSubRoleData().isPublicRole = GetConVar("ttt2_maid_is_public_role"):GetBool()
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

local function CreditsHelper(bool, msg, msg_args, send)
	if CLIENT then
		return bool, LANG.GetParamTranslation(msg, msg_args)
	end

	if SERVER then
		LANG.Msg(send, msg, msg_args, MSG_MSTACK_ROLE)
		return bool
	end
end

hook.Add("TTT2CanTransferCredits", "Maid_Payment_Check", function(send, rec, creds)
	-- block all transfers from the maid
	if send:GetSubRole() == ROLE_MAID then
		return CreditsHelper(false, "maid_blocked", {}, send)
	end

	-- check role
	if rec:GetSubRole() ~= ROLE_MAID then
		return
	end

	-- check credit amount
	local salary = GetConVar("ttt2_maid_salary"):GetInt()
	if (creds < salary) then
		return CreditsHelper(false, "maid_not_enough_credits", { num = salary }, send)
	end

	-- check alive
	if not (rec:IsValid() and rec:Alive()) then
		return CreditsHelper(false, "maid_dead", {}, send)
	end
end)

if SERVER then
	hook.Add("TTT2OnTransferCredits", "Maid_Payment", function (send, rec, creds, isDead)
		-- check role
		if rec:GetSubRole() ~= ROLE_MAID then
			return
		end

		-- process payment
		LANG.Msg(rec, "maid_paid_by", { name = send:Nick() }, MSG_MSTACK_ROLE)
		if rec.maid_owner == nil then
			rec.maid_owner = send
			rec:UpdateTeam(send:GetRealTeam(), false, false)
			LANG.Msg(rec, "maid_work_1", {}, MSG_MSTACK_ROLE)
			-- defective
			if owner.maid_owner:GetSubRole() == ROLE_DEFECTIVE then
				LANG.Msg(rec, "maid_secondary_def", {}, MSG_MSTACK_ROLE)
			-- traitor team
			elseif owner.maid_owner:HasEvilTeam() then
				LANG.Msg(rec, "maid_secondary_traitor", {}, MSG_MSTACK_ROLE)
			-- any other team
			elseif owner:GetTeam() ~= TEAM_NONE then
				LANG.Msg(rec, "maid_secondary_inno", {}, MSG_MSTACK_ROLE)
			end
			SendFullStateUpdate()
			net.Start("ttt2_maid_thermalvis")
			net.WritePlayer(send)
			net.Send()
		else
			LANG.Msg(rec, "maid_work_2", {}, MSG_MSTACK_ROLE)
			if (GetConVar("ttt2_maid_refund_credits"):GetBool()) then
				LANG.Msg(send, "maid_refund", {}, MSG_MSTACK_PLAIN)
			end
		end
	end)

	local round_running = false;

	hook.Add("TTTBeginRound", "Maid_Cleanup", function ()
		for i,ply in ipairs(player.GetAll()) do
			ply.maid_owner = nil
		end
		round_running = true;
		timer.Create("notify_maids", 5, -1, function ()
			if round_running then
				for _,ply in ipairs(player.GetAll()) do
					if ply.maid_owner ~= nil then
						local dat = {name = ply.maid_owner:Nick(), role = ply.maid_owner:GetRoleString()}
						LANG.Msg(ply, "maid_announce_master", dat, MSG_MSTACK_ROLE)
					end
				end
			else
				timer.Remove("notify_maids")
			end
		end)
	end)

	hook.Add("TTTEndRound", "EndRound_SetState", function ()
		round_running = false
	end)
end

if CLIENT then
	net.Receive("ttt2_maid_thermalvis", function ()
		local master = net.ReadPlayer()
		LocalPlayer().thermalvis = master
		thermalvision.Add({master}, THERMALVISION_MODE_BOTH)
	end)

	hook.Add("TTTEndRound", "EndRound_ClearThermalVis",  function()
		if LocalPlayer().thermalvis ~= nil then
			thermalvision.Remove({LocalPlayer().thermalvis})
		end
		thermalvision.Clear()
	end)
end
