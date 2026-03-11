module main

import json
import tdlib
import handlers
import structs
import messages
import os

fn on_response(client voidptr, resp_type string, raw string) {
	match resp_type {
		'messages' {
			msgs := messages.parse_response(raw)
			messages.display_messages(msgs)
		}
		'message' {
			msg := messages.parse_single(raw) or {
				println('[ non-text message ]')
				return
			}
			mut d := '<'
			if msg.is_outgoing {
				d = '>'
			}
			println('[${msg.id}] ${msg.sender_type}:${msg.sender_id} ${d} ${msg.text}')
		}
		'chat' {
			info := messages.parse_chat(raw) or { return }
			messages.display_chat(info)
		}
		'messageLink' {
			link := messages.parse_link(raw) or { return }
			messages.display_link(link)
		}
		'forumTopics' {
			topics := messages.parse_topics(raw)
			messages.display_topics(topics)
		}
		'user' {
			user := json.decode(structs.UserInfo, raw) or { return }
			messages.display_user(user)
		}
		'supergroup' {
			sg := json.decode(structs.SupergroupInfo, raw) or { return }
			messages.display_supergroup(sg)
		}
		'chatMembers' {
			members := messages.parse_members(raw)
			messages.display_members(members)
		}
		'error' {
			println('Error: ${raw}')
		}
		else {}
	}
}

fn on_message(client voidptr, msg structs.TextMessage) {
	if !msg.is_outgoing {
		println('[${msg.chat_id}] ${msg.sender_type}:${msg.sender_id} > ${msg.text}')
		return
	}

	if msg.text == '/ping' {
		messages.edit(client, msg.chat_id, msg.id, 'pong')
	}
	if msg.text == '/delete' {
		messages.delete_one(client, msg.chat_id, msg.id, true)
	}
	if msg.text == '/silent' {
		messages.send_silent(client, msg.chat_id, 'silent message')
	}
	if msg.text == '/nopreview' {
		messages.send_no_preview(client, msg.chat_id, 'https://google.com no preview')
	}
	if msg.text == '/typing' {
		messages.typing(client, msg.chat_id)
	}
	if msg.text == '/bold' {
		messages.send_bold(client, msg.chat_id, 'bold text')
	}
	if msg.text == '/italic' {
		messages.send_italic(client, msg.chat_id, 'italic text')
	}
	if msg.text == '/underline' {
		messages.send_underline(client, msg.chat_id, 'underline text')
	}
	if msg.text == '/strike' {
		messages.send_strike(client, msg.chat_id, 'strikethrough text')
	}
	if msg.text == '/code' {
		messages.send_code(client, msg.chat_id, 'inline code')
	}
	if msg.text == '/codeblock' {
		messages.send_code_block(client, msg.chat_id, 'fn main() {\n  println("hello")\n}', 'v')
	}
	if msg.text == '/spoiler' {
		messages.send_spoiler(client, msg.chat_id, 'hidden text')
	}
	if msg.text == '/quote' {
		messages.send_quote(client, msg.chat_id, 'quoted text')
	}
	if msg.text == '/link' {
		messages.send_link_text(client, msg.chat_id, 'click here', 'https://google.com')
	}
	if msg.text == '/scheduled' {
		messages.send_scheduled(client, msg.chat_id, 'scheduled', msg.date + 60)
	}
	if msg.text == '/draft' {
		messages.set_draft(client, msg.chat_id, 'draft text')
	}
	if msg.text == '/cleardraft' {
		messages.clear_draft(client, msg.chat_id)
	}
	if msg.text == '/read' {
		messages.mark_read(client, msg.chat_id, msg.id)
	}
	if msg.text == '/history' {
		messages.get_history(client, msg.chat_id, 0, 20)
	}
	if msg.text == '/mute' {
		messages.mute_chat(client, msg.chat_id)
	}
	if msg.text == '/unmute' {
		messages.unmute_chat(client, msg.chat_id)
	}
	if msg.text == '/archive' {
		messages.archive_chat(client, msg.chat_id)
	}
	if msg.text == '/unarchive' {
		messages.unarchive_chat(client, msg.chat_id)
	}
	if msg.text == '/info' {
		messages.open_chat(client, msg.chat_id)
		tdlib.send_query(client, '{"@type":"getChat","chat_id":${msg.chat_id}}')
	}
	if msg.text == '/sginfo' {
		sg_id := -1000000000000 - msg.chat_id
		tdlib.send_query(client, '{"@type":"getSupergroup","supergroup_id":${sg_id}}')
	}
	if msg.text == '/members' {
		sg_id := -1000000000000 - msg.chat_id
		tdlib.send_query(client, '{"@type":"getSupergroupMembers","supergroup_id":${sg_id},"filter":{"@type":"supergroupMembersFilterRecent"},"offset":0,"limit":50}')
	}
	if msg.text == '/topics' {
		tdlib.send_query(client, '{"@type":"getForumTopics","chat_id":${msg.chat_id},"query":"","offset_date":0,"offset_message_id":0,"offset_message_thread_id":0,"limit":50}')
	}
	if msg.text == '/getlink' {
		if msg.reply_to_id > 0 {
			messages.get_link(client, msg.chat_id, msg.reply_to_id)
		}
	}
	if msg.text == '/forward' {
		if msg.reply_to_id > 0 {
			messages.forward_one(client, msg.chat_id, msg.chat_id, msg.reply_to_id)
		}
	}
	if msg.text == '/copy' {
		if msg.reply_to_id > 0 {
			messages.copy_one(client, msg.chat_id, msg.chat_id, msg.reply_to_id)
		}
	}
	if msg.text == '/pin' {
		if msg.reply_to_id > 0 {
			messages.pin(client, msg.chat_id, msg.reply_to_id, false)
		}
	}
	if msg.text == '/unpin' {
		if msg.reply_to_id > 0 {
			messages.unpin(client, msg.chat_id, msg.reply_to_id)
		}
	}
	if msg.text == '/unpinall' {
		messages.unpin_all(client, msg.chat_id)
	}
	if msg.text.starts_with('/history ') {
		parts := msg.text.all_after('/history ').split(' ')
		if parts.len == 2 {
			cid := parts[0].i64()
			limit := parts[1].int()
			if cid != 0 && limit > 0 {
				messages.open_chat(client, cid)
				messages.get_history(client, cid, 0, limit)
			}
		}
	}
	if msg.text.starts_with('/resolve ') {
		messages.resolve_chat(client, msg.text.all_after('/resolve '))
	}
	if msg.text.starts_with('/getmsg ') {
		parts := msg.text.all_after('/getmsg ').split(' ')
		if parts.len == 2 {
			cid := parts[0].i64()
			mid := parts[1].i64()
			if cid != 0 && mid != 0 {
				messages.open_chat(client, cid)
				messages.get(client, cid, mid)
			}
		}
	}
	if msg.text.starts_with('/search ') {
		messages.search(client, msg.chat_id, msg.text.all_after('/search '), 20)
	}
	if msg.text.starts_with('/gsearch ') {
		messages.search_global(client, msg.text.all_after('/gsearch '), 20)
	}
	if msg.text.starts_with('/user ') {
		uid := msg.text.all_after('/user ').i64()
		if uid > 0 {
			tdlib.send_query(client, '{"@type":"getUser","user_id":${uid}}')
		}
	}
	if msg.text.starts_with('/send ') {
		parts := msg.text.all_after('/send ').split(' ')
		if parts.len >= 2 {
			cid := parts[0].i64()
			txt := msg.text.all_after('${parts[0]} ')
			if cid != 0 {
				messages.open_chat(client, cid)
				messages.send(client, cid, txt)
			}
		}
	}
	if msg.text.starts_with('/sendto @') {
		parts := msg.text.all_after('/sendto ').split(' ')
		if parts.len >= 2 {
			username := parts[0]
			txt := msg.text.all_after('${parts[0]} ')
			chat := messages.fetch_chat_by_username(client, username) or { return }
			messages.send(client, chat.id, txt)
		}
	}
	if msg.text.starts_with('/topic ') {
		parts := msg.text.all_after('/topic ').split(' ')
		if parts.len >= 2 {
			tid := parts[0].i64()
			txt := msg.text.all_after('${parts[0]} ')
			if tid > 0 {
				messages.send_to_topic(client, msg.chat_id, tid, txt)
			}
		}
	}
	if msg.text.starts_with('/join ') {
		link := msg.text.all_after('/join ')
		if link.starts_with('https://') {
			messages.join_by_link(client, link)
		} else {
			chat := messages.fetch_chat_by_username(client, link) or { return }
			messages.join_chat(client, chat.id)
		}
	}
	if msg.text.starts_with('/leave ') {
		cid := msg.text.all_after('/leave ').i64()
		if cid != 0 {
			messages.leave_chat(client, cid)
		}
	}
	if msg.text.starts_with('/ban ') {
		uid := msg.text.all_after('/ban ').i64()
		if uid > 0 {
			messages.ban_member(client, msg.chat_id, uid)
		}
	}
	if msg.text.starts_with('/unban ') {
		uid := msg.text.all_after('/unban ').i64()
		if uid > 0 {
			messages.unban_member(client, msg.chat_id, uid)
		}
	}
	if msg.text.starts_with('/promote ') {
		uid := msg.text.all_after('/promote ').i64()
		if uid > 0 {
			messages.promote_admin(client, msg.chat_id, uid)
		}
	}
	if msg.text.starts_with('/demote ') {
		uid := msg.text.all_after('/demote ').i64()
		if uid > 0 {
			messages.demote_admin(client, msg.chat_id, uid)
		}
	}
	if msg.text.starts_with('/block ') {
		uid := msg.text.all_after('/block ').i64()
		if uid > 0 {
			messages.block_user(client, uid)
		}
	}
	if msg.text.starts_with('/unblock ') {
		uid := msg.text.all_after('/unblock ').i64()
		if uid > 0 {
			messages.unblock_user(client, uid)
		}
	}
}

fn main() {
	api_id := 123456
	api_hash := 'your_api_hash'

	client := tdlib.new_client() or {
		eprintln(err)
		return
	}

	tdlib.send_query(client, '{"@type":"setLogVerbosityLevel","new_verbosity_level":0}')
	os.system('clear')

	handlers.run(client, 1.0, api_id, api_hash, on_message, on_response) or { eprintln(err) }

	tdlib.client_destroy(client)
}