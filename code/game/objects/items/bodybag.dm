
/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	var/unfoldedbag_path = /obj/structure/closet/body_bag

/obj/item/bodybag/attack_self(mob/user)
	if(user.is_holding(src))
		deploy_bodybag(user, get_turf(user))
	else
		deploy_bodybag(user, get_turf(src))

/obj/item/bodybag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(proximity)
		if(isopenturf(target))
			deploy_bodybag(user, target)

/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	R.open(user)
	R.add_fingerprint(user)
	R.foldedbag_instance = src
	moveToNullspace()

/obj/item/bodybag/suicide_act(mob/user)
	if(isopenturf(user.loc))
		user.visible_message(SPAN_SUICIDE("[user] is crawling into [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		var/obj/structure/closet/body_bag/R = new unfoldedbag_path(user.loc)
		R.add_fingerprint(user)
		qdel(src)
		user.forceMove(R)
		playsound(src, 'sound/items/zip.ogg', 15, TRUE, -3)
		return (OXYLOSS)
	..()

// Bluespace bodybag

/obj/item/bodybag/bluespace
	name = "bluespace body bag"
	desc = "A folded bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/bluespace
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NO_MAT_REDEMPTION

/obj/item/bodybag/bluespace/examine(mob/user)
	. = ..()
	if(contents.len)
		var/s = contents.len == 1 ? "" : "s"
		. += SPAN_NOTICE("You can make out the shape[s] of [contents.len] object[s] through the fabric.")

/obj/item/bodybag/bluespace/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		if(isliving(A))
			to_chat(A, SPAN_NOTICE("You suddenly feel the space around you torn apart! You're free!"))
	return ..()

/obj/item/bodybag/bluespace/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	for(var/atom/movable/A in contents)
		A.forceMove(R)
		if(isliving(A))
			to_chat(A, SPAN_NOTICE("You suddenly feel air around you! You're free!"))
	R.open(user)
	R.add_fingerprint(user)
	R.foldedbag_instance = src
	moveToNullspace()

/obj/item/bodybag/bluespace/container_resist_act(mob/living/user)
	if(user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't get out while you're restrained like this!"))
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, SPAN_NOTICE("You claw at the fabric of [src], trying to tear it open..."))
	to_chat(loc, SPAN_WARNING("Someone starts trying to break free of [src]!"))
	if(!do_mob(user, src, 12 SECONDS, timed_action_flags = (IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM)))
		return
	// you are still in the bag? time to go unless you KO'd, honey!
	// if they escape during this time and you rebag them the timer is still clocking down and does NOT reset so they can very easily get out.
	if(user.incapacitated())
		to_chat(loc, SPAN_WARNING("The pressure subsides. It seems that they've stopped resisting..."))
		return
	loc.visible_message(SPAN_WARNING("[user] suddenly appears in front of [loc]!"), SPAN_USERDANGER("[user] breaks free of [src]!"))
	qdel(src)
