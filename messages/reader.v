module messages

import json
import tdlib
import structs

pub fn wait_for(client voidptr, timeout f64, expected string, max_tries int) ?string {
	for _ in 0 .. max_tries {
		response := tdlib.receive(client, timeout)
		if response.len == 0 {
			continue
		}
		rtype := json.decode(structs.Type, response) or { continue }
		if rtype.@type == expected {
			return response
		}
	}
	return none
}

pub fn fetch_history(client voidptr, chat_id i64, limit int) []structs.TextMessage {
	open_chat(client, chat_id)
	get_history(client, chat_id, 0, limit)
	raw := wait_for(client, 2.0, 'messages', 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_history_topic(client voidptr, chat_id i64, topic_id i64, limit int) []structs.TextMessage {
	open_chat(client, chat_id)
	q := '{"@type":"getMessageThreadHistory","chat_id":${chat_id},"message_id":${topic_id * 1048576},"from_message_id":0,"offset":0,"limit":${limit}}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'messages', 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_message(client voidptr, chat_id i64, message_id i64) ?structs.TextMessage {
	open_chat(client, chat_id)
	get(client, chat_id, message_id)
	raw := wait_for(client, 2.0, 'message', 50) or { return none }
	return parse_single(raw)
}

pub fn fetch_message_raw(client voidptr, chat_id i64, raw_message_id i64) ?structs.TextMessage {
	open_chat(client, chat_id)
	get_raw(client, chat_id, raw_message_id)
	raw := wait_for(client, 2.0, 'message', 50) or { return none }
	return parse_single(raw)
}

pub fn fetch_search(client voidptr, chat_id i64, query string, limit int) []structs.TextMessage {
	open_chat(client, chat_id)
	search(client, chat_id, query, limit)
	raw := wait_for(client, 2.0, 'messages', 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_search_global(client voidptr, query string, limit int) []structs.TextMessage {
	search_global(client, query, limit)
	raw := wait_for(client, 2.0, 'messages', 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_chat_info(client voidptr, chat_id i64) ?structs.ChatInfo {
	q := '{"@type":"getChat","chat_id":${chat_id}}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'chat', 50) or { return none }
	return parse_chat(raw)
}

pub fn fetch_chat_by_username(client voidptr, username string) ?structs.ChatInfo {
	resolve_chat(client, username)
	raw := wait_for(client, 2.0, 'chat', 50) or { return none }
	return parse_chat(raw)
}

pub fn fetch_link(client voidptr, chat_id i64, message_id i64) ?structs.MessageLinkResponse {
	real_id := message_id * 1048576
	q := '{"@type":"getMessageLink","chat_id":${chat_id},"message_id":${real_id}}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'messageLink', 50) or { return none }
	return parse_link(raw)
}

pub fn fetch_comments(client voidptr, chat_id i64, message_id i64, limit int) []structs.TextMessage {
	real_id := message_id * 1048576
	q := '{"@type":"getMessageThread","chat_id":${chat_id},"message_id":${real_id}}'
	tdlib.send_query(client, q)
	thread_raw := wait_for(client, 2.0, 'messageThreadInfo', 50) or { return [] }
	thread_info := json.decode(structs.MessageThreadInfo, thread_raw) or { return [] }
	q2 := '{"@type":"getMessageThreadHistory","chat_id":${thread_info.chat_id},"message_id":${real_id},"from_message_id":0,"offset":0,"limit":${limit}}'
	tdlib.send_query(client, q2)
	raw := wait_for(client, 2.0, 'messages', 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_topics(client voidptr, chat_id i64, limit int) []structs.ForumTopic {
	q := '{"@type":"getForumTopics","chat_id":${chat_id},"query":"","offset_date":0,"offset_message_id":0,"offset_message_thread_id":0,"limit":${limit}}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'forumTopics', 50) or { return [] }
	return parse_topics(raw)
}

pub fn fetch_user_info(client voidptr, user_id i64) ?structs.UserInfo {
	q := '{"@type":"getUser","user_id":${user_id}}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'user', 50) or { return none }
	return json.decode(structs.UserInfo, raw) or { return none }
}

pub fn fetch_private_chat(client voidptr, user_id i64) ?structs.ChatInfo {
	q := '{"@type":"createPrivateChat","user_id":${user_id},"force":true}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'chat', 50) or { return none }
	return parse_chat(raw)
}

pub fn fetch_supergroup_info(client voidptr, chat_id i64) ?structs.SupergroupInfo {
	sg_id := -1000000000000 - chat_id
	q := '{"@type":"getSupergroup","supergroup_id":${sg_id}}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'supergroup', 50) or { return none }
	return json.decode(structs.SupergroupInfo, raw) or { return none }
}

pub fn fetch_supergroup_members(client voidptr, chat_id i64, limit int) []structs.ChatMember {
	sg_id := -1000000000000 - chat_id
	q := '{"@type":"getSupergroupMembers","supergroup_id":${sg_id},"filter":{"@type":"supergroupMembersFilterRecent"},"offset":0,"limit":${limit}}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'chatMembers', 50) or { return [] }
	return parse_members(raw)
}

pub fn fetch_me(client voidptr) ?structs.UserInfo {
	get_me(client)
	raw := wait_for(client, 2.0, 'user', 50) or { return none }
	return json.decode(structs.UserInfo, raw) or { return none }
}

pub fn fetch_invite_link_info(client voidptr, invite_link string) ?string {
	q := '{"@type":"getChatInviteLinkInfo","invite_link":"${escape(invite_link)}"}'
	tdlib.send_query(client, q)
	return wait_for(client, 2.0, 'chatInviteLinkInfo', 50)
}

pub fn fetch_chat_members_search(client voidptr, chat_id i64, query string, limit int) []structs.ChatMember {
	q := '{"@type":"searchChatMembers","chat_id":${chat_id},"query":"${escape(query)}","limit":${limit},"filter":{"@type":"chatMembersFilterMembers"}}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, 'chatMembers', 50) or { return [] }
	return parse_members(raw)
}

pub fn fetch_sticker_set(client voidptr, name string) ?string {
	q := '{"@type":"getStickerSet","name":"${escape(name)}"}'
	tdlib.send_query(client, q)
	return wait_for(client, 2.0, 'stickerSet', 50)
}

pub fn fetch_contacts(client voidptr) ?string {
	get_contacts(client)
	return wait_for(client, 2.0, 'users', 50)
}
