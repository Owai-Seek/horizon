/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, SPAN_DANGER(" Speech is currently admin-disabled."))
		return

	if(!mob)
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			return
		if(mob.stat)
			to_chat(src, SPAN_DANGER("You cannot use LOOC while unconscious or dead."))
			return
		if(istype(mob, /mob/dead))
			to_chat(src, SPAN_DANGER("You cannot use LOOC while ghosting."))
			return

	msg = emoji_parse(msg)

	mob.log_talk(msg,LOG_OOC, tag="LOOC")

	var/list/heard = get_hearers_in_view(7, src.mob)
	var/list/admin_seen = list()
	for(var/mob/M in heard)
		if(!M.client)
			continue
		var/client/C = M.client
		if (C.holder)
			admin_seen[C] = TRUE
			continue //they are handled after that

		if (isobserver(M))
			continue //Also handled later.

		to_chat(C, SPAN_LOOC(SPAN_PREFIX("LOOC:</span> <EM>[src.mob.name]:</EM> <span class='message'>[msg]")))

	for(var/cli in GLOB.admins)
		var/client/C = cli
		if (admin_seen[C])
			to_chat(C, SPAN_LOOC("[ADMIN_FLW(usr)] <span class='prefix'>LOOC:</span> <EM>[src.key]/[src.mob.name]:</EM> <span class='message'>[msg]</span>"))
