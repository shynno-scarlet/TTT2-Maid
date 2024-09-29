L = LANG.GetLanguageTableReference("de")

L[MAID.name] = "Maid"
L["maids"] = "Maids"
L["info_popup_" .. MAID.abbr] = "Du bist eine Maid!"
L["body_found_" .. MAID.abbr] = "Sie war eine Maid!"
L["search_role_" .. MAID.abbr] = "Diese Person war eine Maid!"
L["target_" .. MAID.abbr] = "Maid"
L["ttt2_desc_" .. MAID.abbr] = [[Eine Maid ist eine neutrale Rolle bis sie von einem Traitor oder Detektiv angeheuert wird.
Die Maid hat ein spezielles Messer, welches eine der folgenden Aktionen ausführen kann:
Im Traitor-Team kann sie Leichen entsorgen.
Im Detektiv-Team kann sie für andere Spieler ein gesundes Essen kochen.
Im Defektiv-Team kann sie vergiftetes Essen kochen, welches Spieler erst heilt und später tötet.]]

L["maid_paid_by"] = "Du wurdest von {name} bezahlt."
L["maid_work_1"] = "Er/Sie ist nun dein neuer Meister."
L["maid_work_2"] = "Du arbeitest weiterhin für deinen alten Meister."
L["maid_refund"] = "Diese Maid hat bereits einen Meister. Deine Credits wurden zurückerstattet."
L["maid_dead"] = "Diese Maid ist bereits tot. Deine Credits wurden zurückerstattet."
L["maid_not_enough_credits"] = "Du musst mindestens {num} Credits bezahlen."
L["maid_blocked"] = "Eine Maid kann niemandem Credits überweisen."

L["maid_healed_you"] = "Eine Maid hat dir ein gesundes Essen zubereitet."
L["maid_heal"] = "Du hast {ply} geheilt."
L["maid_poison"] = "Du hast {ply} vergiftet."
L["maid_corpse_removed"] = "Du hast die Leiche von {ply} entsorgt."
L["maid_kill"] = "Du hast {ply} mit deinem Gift getötet."

L["maid_secondary_def"] = "DEFEKTIV MAID: Du kannst für andere Spieler vergiftetes Essen kochen."
L["maid_secondary_traitor"] = "TRAITOR MAID: Du kannst Leichen entfernen."
L["maid_secondary_inno"] = "INNOCENT MAID: Du kannst für andere Spieler gesundes Essen kochen."

L["label_ttt2_maid_salary"] = "Die Bezahlung für die Maid"
L["label_ttt2_maid_poison_time_min"] = "Minimale Zeit bis zum Gift-Tod (Defektiv Maid)"
L["label_ttt2_maid_poison_time_max"] = "Maximale Zeit bis zum Gift-Tod (Defektiv Maid)"
L["label_ttt2_maid_heal_amount"] = "Wie viele HP heilt ein Essen?"
L["label_ttt2_maid_ability_cooldown"] = "Cooldown der Spezial-Fähigkeiten der Maid"
L["label_ttt2_maid_refund_credits"] = "Credits zurückerstatten, wenn die Maid bereits einen Meister hat"
L["label_ttt2_maid_is_public_role"] = "Soll die Maid allen Spielern angezeigt werden?"
L["label_ttt2_maid_throw_knife_damage"] = "Schaden der von einem Wurfmesser verursacht wird"
L["label_ttt2_maid_throw_knife_speed"] = "Wie schnell können Messer geworfen werden (Messer pro Sekunde)"
L["label_ttt2_maid_throw_angle_velocity"] = "Winkelgeschwindigkeit der Wurfmesser (x100)"
L["label_ttt2_maid_throw_velocity"] = "Geschwindigkeit der Wurfmesser (x100)"
