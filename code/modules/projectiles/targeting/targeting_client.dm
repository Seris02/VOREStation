//These are called by the on-screen buttons, adjusting what the victim can and cannot do.
/mob/proc/add_gun_icons()
	if (!hud_used) return 1
	hud_used.add_screen(item_use_icon)
	hud_used.add_screen(gun_move_icon)
	hud_used.add_screen(radio_use_icon)

/mob/proc/remove_gun_icons()
	if (!hud_used) return 1
	hud_used.remove_screen(item_use_icon)
	hud_used.remove_screen(gun_move_icon)
	hud_used.remove_screen(radio_use_icon)
