if SERVER then
	AddCSLuaFile()
end

MAID_CVARS = {
	ttt2_maid_salary = {1, 1, 5},
	ttt2_maid_poison_time_min = {10, 30, 90},
	ttt2_maid_poison_time_max = {10, 45, 90},
	ttt2_maid_heal_amount = {10, 35, 100},
	ttt2_maid_ability_cooldown = {10, 90, 300},
	ttt2_maid_refund_credits = false,
	ttt2_maid_is_public_role = true,
	ttt2_maid_throw_knife_damage = {1,3,100},
	ttt2_maid_throw_knife_speed = {1,4,10},
}

for var, val in pairs(MAID_CVARS) do
	CreateConVar(var, val[2], {FCVAR_NOTIFY, FCVAR_ARCHIVE})
end

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_maid_cvars", function(tbl)
	tbl[ROLE_MAID] = tbl[ROLE_MAID] or {}

	for var, val in pairs(cvrs) do
	table.insert(tbl[ROLE_MAID], {
		cvar = var,
		checkbox = type(var) == "boolean",
		desc = var .. " (def. " .. tostring(val[2]) .. ")"
	})
	end
end)
