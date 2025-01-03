if SERVER then
	AddCSLuaFile()
end

MAID_CVARS = {
	["ttt2_maid_salary"] = {1, 1, 5},
	["ttt2_maid_poison_time_min"] = {10, 30, 90},
	["ttt2_maid_poison_time_max"] = {10, 45, 90},
	["ttt2_maid_heal_amount"] = {10, 35, 100},
	["ttt2_maid_ability_cooldown"] = {10, 90, 300},
	["ttt2_maid_refund_credits"] = {0, false, 1},
	["ttt2_maid_is_public_role"] = {0, true, 1},
	["ttt2_maid_throw_knife_damage"] = {1,3,100},
	["ttt2_maid_throw_knife_speed"] = {1,4,10},
	["ttt2_maid_throw_angle_velocity"] = {1, 30, 100},
	["ttt2_maid_throw_velocity"] = {1, 30, 100},
}

local function str(val)
	if type(val) == "boolean" then
		if val then
			val = 1
		else
			val = 0
		end
	end
	return tostring(val)
end

local function desc(var, def)
	return var .. " (def. " .. tostring(def) .. ")"
end

for var, val in pairs(MAID_CVARS) do
	CreateConVar(var, str(val[2]), {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, desc(var, val[2]), val[1], val[3])
end

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_maid_cvars", function(tbl)
	tbl[ROLE_MAID] = tbl[ROLE_MAID] or {}

	for var, val in pairs(MAID_CVARS) do
		table.insert(tbl[ROLE_MAID], {
			cvar = var,
			min = val[1],
			max = val[3],
			checkbox = type(val[2]) == "boolean",
			slider = type(val[2]) == "number",
			decimal = 0,
			desc = desc(var, val[2])
		})
	end
end)
