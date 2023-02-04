/mob/recalculate_vis()
	. = ..()
	if(!plane_holder || !vis_enabled)
		return

	if(vantag_hud)
		if(!(VIS_CH_VANTAG in vis_enabled))
			plane_holder.set_vis(VIS_CH_VANTAG,TRUE)
			vis_enabled += VIS_CH_VANTAG
	else
		if(VIS_CH_VANTAG in vis_enabled)
			plane_holder.set_vis(VIS_CH_VANTAG,FALSE)
			vis_enabled -= VIS_CH_VANTAG
	return

/mob/proc/is_SSD()
	if (!client)
		if (!LAZYLEN(dual_controllers))
			return TRUE
		else
			for (var/mob/M as anything in dual_controllers)
				if (M.client) return FALSE
	return FALSE
