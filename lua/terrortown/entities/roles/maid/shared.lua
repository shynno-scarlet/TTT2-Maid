if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_maid.vmt")
end

local function printg(msg)
	msg = "[maid role] " .. tostring(msg)
	print(msg)
	for i,ply in ipairs(player.GetAll()) do
		ply:PrintMessage(2, msg)
	end
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

if SERVER then
	hook.Add("TTT2CanTransferCredits", "Maid_Salary", function(send, rec, creds)
		-- block all transfers from the maid
		if send:GetSubRole() == ROLE_MAID then
			LANG.Msg(send, "maid_blocked", {}, MSG_CHAT_ROLE)
			return false, LANG.GetTranslation("maid_blocked")
		end

		-- check role
		if rec:GetSubRole() ~= ROLE_MAID then
			return
		end

		-- check credit amount
		local salary = GetConVar("ttt2_maid_salary"):GetInt()
		if (creds < salary) then
			LANG.Msg(send, "maid_not_enough_credits", { num = salary }, MSG_CHAT_ROLE)
			return false, LANG.GetTranslation("maid_not_enough_credits")
		end

		-- check alive
		if not (rec:IsValid() and rec:Alive()) then
			LANG.Msg(send, "maid_dead", {}, MSG_CHAT_ROLE)
			return false, LANG.GetTranslation("maid_dead")
		end

		-- process payment
		LANG.Msg(rec, "maid_got_paid", { name = send:Nick() }, MSG_CHAT_ROLE)
		if not rec.maid_paid then
			rec.maid_paid = true
			rec.maid_owner = send
			rec:UpdateTeam(send:GetRealTeam(), false, false)
			LANG.Msg(rec, "maid_work_1", {}, MSG_CHAT_ROLE)
			printg("maid got paid")
		else
			LANG.Msg(rec, "maid_work_2", {}, MSG_CHAT_ROLE)
			printg("maid was already paid")
			if (GetConVar("ttt2_maid_refund_credits"):GetBool()) then
				LANG.Msg(send, "maid_refund", {}, MSG_CHAT_ROLE)
				printg("maid was already paid")
				return false, LANG.GetTranslation("maid_refund")
			end
		end

		printg("processed payment")
	end)

	hook.Add("TTTBeginRound", "Maid_Cleanup", function (arguments)
		for i,ply in ipairs(player.GetAll()) do
			ply.maid_paid = false
			rec.maid_owner = nil
		end
	end)

	printg("Version 13 Loaded")
end