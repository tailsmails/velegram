module messages

import json
import tdlib
import structs
import time

struct ResponseWithExtra {
	@type string @[json: '@type']
	extra string @[json: '@extra']
}

pub fn wait_for(client voidptr, timeout f64, expected_extra string, max_tries int) ?string {
	for _ in 0 .. max_tries {
		response := tdlib.receive(client, timeout)
		if response.len == 0 {
			continue
		}
		resp := json.decode(ResponseWithExtra, response) or { continue }
		if resp.extra == expected_extra {
			return response
		}
	}
	return none
}

pub fn fetch_history(client voidptr, chat_id i64, limit int) []structs.TextMessage {
	open_chat(client, chat_id)
	extra := time.now().unix_nano().str()
	q := '{"@type":"getChatHistory","chat_id":${chat_id},"from_message_id":0,"offset":0,"limit":${limit},"only_local":false,"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_history_topic(client voidptr, chat_id i64, topic_id i64, limit int) []structs.TextMessage {
	open_chat(client, chat_id)
	real_topic := topic_id * 1048576
	extra := time.now().unix_nano().str()
	q := '{"@type":"getMessageThreadHistory","chat_id":${chat_id},"message_id":${real_topic},"from_message_id":0,"offset":0,"limit":${limit},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_message(client voidptr, chat_id i64, message_id i64) ?structs.TextMessage {
	open_chat(client, chat_id)
	extra := time.now().unix_nano().str()
	q := '{"@type":"getMessage","chat_id":${chat_id},"message_id":${message_id},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return parse_single(raw)
}

pub fn fetch_message_raw(client voidptr, chat_id i64, raw_message_id i64) ?structs.TextMessage {
	open_chat(client, chat_id)
	extra := time.now().unix_nano().str()
	q := '{"@type":"getMessage","chat_id":${chat_id},"message_id":${raw_message_id},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return parse_single(raw)
}

pub fn fetch_search(client voidptr, chat_id i64, query string, limit int) []structs.TextMessage {
	open_chat(client, chat_id)
	extra := time.now().unix_nano().str()
	q := '{"@type":"searchChatMessages","chat_id":${chat_id},"query":"${escape(query)}","from_message_id":0,"offset":0,"limit":${limit},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_search_global(client voidptr, query string, limit int) []structs.TextMessage {
	extra := time.now().unix_nano().str()
	q := '{"@type":"searchMessages","query":"${escape(query)}","offset":"","limit":${limit},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_chat_info(client voidptr, chat_id i64) ?structs.ChatInfo {
	extra := time.now().unix_nano().str()
	q := '{"@type":"getChat","chat_id":${chat_id},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return parse_chat(raw)
}

pub fn fetch_chat_by_username(client voidptr, username string) ?structs.ChatInfo {
	mut clean := username
	if clean.starts_with('@') {
		clean = clean[1..]
	}
	extra := time.now().unix_nano().str()
	q := '{"@type":"searchPublicChat","username":"${escape(clean)}","@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return parse_chat(raw)
}

pub fn fetch_link(client voidptr, chat_id i64, message_id i64) ?structs.MessageLinkResponse {
	real_id := message_id * 1048576
	extra := time.now().unix_nano().str()
	q := '{"@type":"getMessageLink","chat_id":${chat_id},"message_id":${real_id},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return parse_link(raw)
}

pub fn fetch_comments(client voidptr, chat_id i64, message_id i64, limit int) []structs.TextMessage {
	real_id := message_id * 1048576
	extra_thread := time.now().unix_nano().str() + '_thread'
	q := '{"@type":"getMessageThread","chat_id":${chat_id},"message_id":${real_id},"@extra":"${extra_thread}"}'
	tdlib.send_query(client, q)
	thread_raw := wait_for(client, 2.0, extra_thread, 50) or { return [] }
	thread_info := json.decode(structs.MessageThreadInfo, thread_raw) or { return [] }

	extra_history := time.now().unix_nano().str() + '_history'
	q2 := '{"@type":"getMessageThreadHistory","chat_id":${thread_info.chat_id},"message_id":${real_id},"from_message_id":0,"offset":0,"limit":${limit},"@extra":"${extra_history}"}'
	tdlib.send_query(client, q2)
	raw := wait_for(client, 2.0, extra_history, 50) or { return [] }
	return parse_response(raw)
}

pub fn fetch_topics(client voidptr, chat_id i64, limit int) []structs.ForumTopic {
	extra := time.now().unix_nano().str()
	q := '{"@type":"getForumTopics","chat_id":${chat_id},"query":"","offset_date":0,"offset_message_id":0,"offset_message_thread_id":0,"limit":${limit},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return [] }
	return parse_topics(raw)
}

pub fn fetch_user_info(client voidptr, user_id i64) ?structs.UserInfo {
	extra := time.now().unix_nano().str()
	q := '{"@type":"getUser","user_id":${user_id},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return json.decode(structs.UserInfo, raw) or { return none }
}

pub fn fetch_private_chat(client voidptr, user_id i64) ?structs.ChatInfo {
	extra := time.now().unix_nano().str()
	q := '{"@type":"createPrivateChat","user_id":${user_id},"force":true,"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return parse_chat(raw)
}

pub fn fetch_supergroup_info(client voidptr, chat_id i64) ?structs.SupergroupInfo {
	sg_id := -1000000000000 - chat_id
	extra := time.now().unix_nano().str()
	q := '{"@type":"getSupergroup","supergroup_id":${sg_id},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return json.decode(structs.SupergroupInfo, raw) or { return none }
}

pub fn fetch_supergroup_members(client voidptr, chat_id i64, limit int) []structs.ChatMember {
	sg_id := -1000000000000 - chat_id
	extra := time.now().unix_nano().str()
	q := '{"@type":"getSupergroupMembers","supergroup_id":${sg_id},"filter":{"@type":"supergroupMembersFilterRecent"},"offset":0,"limit":${limit},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return [] }
	return parse_members(raw)
}

pub fn fetch_me(client voidptr) ?structs.UserInfo {
	extra := time.now().unix_nano().str()
	q := '{"@type":"getMe","@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return none }
	return json.decode(structs.UserInfo, raw) or { return none }
}

pub fn fetch_invite_link_info(client voidptr, invite_link string) ?string {
	extra := time.now().unix_nano().str()
	q := '{"@type":"getChatInviteLinkInfo","invite_link":"${escape(invite_link)}","@extra":"${extra}"}'
	tdlib.send_query(client, q)
	return wait_for(client, 2.0, extra, 50)
}

pub fn fetch_chat_members_search(client voidptr, chat_id i64, query string, limit int) []structs.ChatMember {
	extra := time.now().unix_nano().str()
	q := '{"@type":"searchChatMembers","chat_id":${chat_id},"query":"${escape(query)}","limit":${limit},"filter":{"@type":"chatMembersFilterMembers"},"@extra":"${extra}"}'
	tdlib.send_query(client, q)
	raw := wait_for(client, 2.0, extra, 50) or { return [] }
	return parse_members(raw)
}

pub fn fetch_sticker_set(client voidptr, name string) ?string {
	extra := time.now().unix_nano().str()
	q := '{"@type":"getStickerSet","name":"${escape(name)}","@extra":"${extra}"}'
	tdlib.send_query(client, q)
	return wait_for(client, 2.0, extra, 50)
}

pub fn fetch_contacts(client voidptr) ?string {
	extra := time.now().unix_nano().str()
	q := '{"@type":"getContacts","@extra":"${extra}"}'
	tdlib.send_query(client, q)
	return wait_for(client, 2.0, extra, 50)
}
