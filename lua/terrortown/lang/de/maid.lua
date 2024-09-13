L = LANG.GetLanguageTableReference("en")

L[MAID.name] = "Maid"
L["maids"] = "Maids"
L["info_popup_" .. MAID.abbr] = "You are a Maid!"
L["body_found_" .. MAID.abbr] = "They were a Maid!"
L["search_role_" .. MAID.abbr] = "This person was a Maid!"
L["target_" .. MAID.abbr] = "Maid"
L["ttt2_desc_" .. MAID.abbr] = [[ A Maid is a neutral role until she gets paid by a detective or traitor.
The maid has a special knfie that can perform one of the following actions:
In the traitor team she can clean up bodies.
In the the detective team she can cook meals for people and heal them.
If she works for a defective she can cook poisoned meals that will heal players, but kill them after a while.]]

L["maid_paid_by"] = "You got paid by {name}."
L["maid_work_1"] = "You work for them now."
L["maid_work_2"] = "You still work for your employer."

L["maid_healed_you"] = "The maid cooked a healthy meal for you."
L["maid_heal"] = "You healed {ply}"
L["maid_poison"] = "You poisoned {ply}"
L["maid_corpse_removed"] = "You removed the corpse of {ply}"
L["maid_kill"] = "You killed {ply} with poison"

L["label_ttt2_maid_salary"] = "The salary for the maid"
L["label_ttt2_maid_poison_time_min"] = "Minimum time to poison kill (Defective Maid)"
L["label_ttt2_maid_poison_time_max"] = "Maximum time to poison kill (Defective Maid)"
L["label_ttt2_maid_heal_amount"] = "The amount one meal can heal"
L["label_ttt2_maid_ability_cooldown"] = "The cooldown of the maids abilities"
L["label_ttt2_maid_refund_credits"] = "Refund credits if the maid was already hired"
L["label_ttt2_maid_is_public_role"] = "Is the role shown to everyone?"
L["label_ttt2_maid_throw_knife_damage"] = "Damage dealt when a throwing knife hits"
L["label_ttt2_maid_throw_knife_speed"] = "How fast can the knives be thrown (knives per second)"
L["label_ttt2_maid_throw_angle_velocity"] = "Angle Velocity of one knife (x100)"
L["label_ttt2_maid_throw_velocity"] = "Velocity of one thrown knife (x100)"
