/mob/living/dual_control
	var/mob/living/controlling
	var/mob/living/held
	var/datum/hud/current_hud
	var/life_tick = 0

/mob/living/dual_control/New(var/mob/to_control, var/mob/from)
	if (!from || !to_control)
		return
	..()
	held = from
	controlling = to_control
	name = to_control.name
	real_name = from.real_name
	from.transforming = TRUE
	ckey = from.ckey
	from.transforming = FALSE
	forceMove(to_control)
	from.moveToNullspace()
	LAZYADD(to_control.dual_controllers, src)
	RegisterSignal(to_control, COMSIG_MOB_CLIENT_LOGIN, .proc/update_hud)
	RegisterSignal(to_control, COMSIG_MOB_DEATH, .proc/dual_death)
	update_hud(FALSE)
	client.images -= dsoverlay
	dsoverlay = controlling.dsoverlay
	client.images |= dsoverlay

/mob/living/dual_control/Life()
	life_tick++
	if (client && life_tick % 10 == 0) //20 seconds
		..()
		update_hud(life_tick % 100 != 0)
		if (controlling)
			stat = controlling.stat
			blinded = controlling.blinded
			sleeping = controlling.sleeping
			paralysis = controlling.paralysis
			stunned = controlling.stunned
			weakened = controlling.weakened

/mob/living/dual_control/update_hud(planes_only = TRUE)
	if (!controlling || !client) return
	sight = controlling.sight
	see_invisible = controlling.see_invisible
	if (current_hud != controlling.hud_used)
		current_hud?.remove_viewer(src, FALSE)
		if (controlling.hud_used)
			current_hud = controlling.hud_used
			zone_sel = controlling.zone_sel
			current_hud.show_to(src)
	if (current_hud)
		current_hud.refresh_viewer_planes(src)

/mob/living/dual_control/proc/dual_death()
	death(deathmessage = DEATHGASP_NO_MESSAGE)

/mob/living/dual_control/stop_pulling()
	if (!controlling) return
	return controlling.stop_pulling()

/mob/living/dual_control/swap_hand()
	if (!controlling) return
	return controlling.swap_hand()

/mob/living/dual_control/mode()
	if (!controlling) return
	return controlling.mode()

/mob/living/dual_control/drop_item()
	if (!controlling) return
	if(!isrobot(controlling) && controlling.stat == CONSCIOUS && (isturf(controlling.loc) || isbelly(controlling.loc)))
		return controlling.drop_item()

/mob/living/dual_control/toggle_throw_mode()
	if (!controlling) return
	return controlling.toggle_throw_mode()

/mob/living/dual_control/checkMoveCooldown()
	if (!controlling) return ..()
	return controlling.checkMoveCooldown()

/mob/living/dual_control/say(message, speaking, whispering)
	if (!controlling) return
	return controlling.say(message, speaking, whispering)

/mob/living/dual_control/say_understands(other, speaking)
	if (!controlling) return
	return controlling.say_understands(other, speaking)

/mob/living/dual_control/combine_message(message_pieces, verb, speaker, always_stars, radio)
	if (!controlling) return
	return controlling.combine_message(message_pieces, verb, speaker, always_stars, radio)

/mob/living/dual_control/emote(act, m_type, message)
	if (!controlling) return
	return controlling.emote(act, m_type, message)

/mob/living/dual_control/proc/move_controlling(n, direct)
	if (!controlling || !controlling.canmove) return
	var/total_delay = controlling.movement_delay(n, direct)
	if(controlling.confused)
		switch(controlling.m_intent)
			if("run")
				if(prob(75))
					direct = turn(direct, pick(90, -90))
					n = get_step(controlling, direct)
			if("walk")
				if(prob(25))
					direct = turn(direct, pick(90, -90))
					n = get_step(controlling, direct)

	total_delay = DS2NEARESTTICK(total_delay) //Rounded to the next tick in equivalent ds
	controlling.setMoveCooldown(total_delay)
	controlling.SelfMove(n, direct, total_delay)
	if((direct & (direct - 1)) && controlling.loc == n)
		controlling.setMoveCooldown(total_delay * SQRT_TWO)

/mob/living/dual_control/facedir(ndir)
	if (!controlling) return
	return controlling.facedir(ndir)

/mob/living/dual_control/shiftnorth()
	if (!controlling) return
	return controlling.shiftnorth()

/mob/living/dual_control/shiftsouth()
	if (!controlling) return
	return controlling.shiftsouth()

/mob/living/dual_control/shiftwest()
	if (!controlling) return
	return controlling.shiftwest()

/mob/living/dual_control/shifteast()
	if (!controlling) return
	return controlling.shifteast()

/mob/living/dual_control/toggle_throw_mode()
	if (!controlling) return
	return controlling.toggle_throw_mode()

/mob/living/dual_control/swap_hand()
	if (!controlling) return
	return controlling.swap_hand()

/mob/living/dual_control/ClickOn(var/atom/A, var/params)
	if (!controlling) return
	if(!checkClickCooldown()) // Hard check, before anything else, to avoid crashing
		return

	setClickCooldown(1)

	if(client && client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && !(modifiers["ctrl"] || modifiers["middle"]))
		examinate(A)
		return 0
	return controlling.ClickOn(A, params)

/mob/living/dual_control/lay_down()
	set name = "Rest"
	set category = "IC"

	if (!controlling) return
	controlling.resting = !controlling.resting
	to_chat(src, "<span class='notice'>You are now [controlling.resting ? "resting" : "getting up"]</span>")
	controlling.update_canmove()

/mob/living/dual_control/resist()
	set name = "Resist"
	set category = "IC"

	if (!controlling) return
	controlling.resist()

/mob/living/dual_control/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if (!controlling) return
	controlling.a_intent_change(input)

/mob/living/dual_control/examinate(atom/A as mob|obj|turf in validate_atom_examine(A))
	set name = "Examine"
	set category = "IC"

	if((is_blind(src) || usr.stat) && !isobserver(src))
		to_chat(src, "<span class='notice'>Something is there but you can't see it.</span>")
		return 1

	//Could be gone by the time they finally pick something
	if(!A)
		return 1

	face_atom(A)
	var/list/results = A.examine(src)
	if(!results || !results.len)
		results = list("You were unable to examine that. Tell a developer!")
	to_chat(src, jointext(results, "<br>"))
	update_examine_panel(A)

/mob/living/dual_control/proc/validate_atom_examine(atom/A)
	return view(controlling||usr)

/mob/living/dual_control/face_atom(var/atom/A)
	if (!controlling) return
	controlling.face_atom(A)

/mob/living/dual_control/insidePanel()
	set name = "Vore Panel"
	set category = "IC"

	if(!vorePanel)
		log_debug("[src] ([type], \ref[src]) didn't have a vorePanel and tried to use the verb.")
		vorePanel = new(controlling||src)

	if (vorePanel.host != controlling)
		qdel(vorePanel)
		vorePanel = new(controlling)
	vorePanel.tgui_interact(src)

/obj/item/weapon/pen/debug
/obj/item/weapon/pen/debug/attack(mob/living/M, mob/living/user)
	new /mob/living/dual_control(M, user)