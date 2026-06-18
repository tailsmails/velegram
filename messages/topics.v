module messages

import tdlib
import structs
import json

pub fn send_to_topic(client voidptr, chat_id i64, topic_id i64, text string) {
	real_topic := topic_id * 1048576
	q := '{"@type":"sendMessage","chat_id":${chat_id},"message_thread_id":${real_topic},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn reply_in_topic(client voidptr, chat_id i64, topic_id i64, message_id i64, text string) {
	real_topic := topic_id * 1048576
	q := '{"@type":"sendMessage","chat_id":${chat_id},"message_thread_id":${real_topic},"reply_to":{"@type":"inputMessageReplyToMessage","message_id":${message_id}},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_comment(client voidptr, chat_id i64, post_id i64, text string) {
	real_id := post_id * 1048576
	q := '{"@type":"getMessageThread","chat_id":${chat_id},"message_id":${real_id}}'
	tdlib.send_query(client, q)
}

pub fn send_comment_text(client voidptr, discussion_chat_id i64, thread_id i64, text string) {
	q := '{"@type":"sendMessage","chat_id":${discussion_chat_id},"message_thread_id":${thread_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn create_topic(client voidptr, chat_id i64, name string) {
	q := '{"@type":"createForumTopic","chat_id":${chat_id},"name":"${escape(name)}","icon":{"@type":"forumTopicIcon","color":7322096}}'
	tdlib.send_query(client, q)
}

pub fn edit_topic(client voidptr, chat_id i64, topic_id i64, new_name string) {
	real_topic := topic_id * 1048576
	q := '{"@type":"editForumTopic","chat_id":${chat_id},"message_thread_id":${real_topic},"name":"${escape(new_name)}"}'
	tdlib.send_query(client, q)
}

pub fn close_topic(client voidptr, chat_id i64, topic_id i64) {
	real_topic := topic_id * 1048576
	q := '{"@type":"toggleForumTopicIsClosed","chat_id":${chat_id},"message_thread_id":${real_topic},"is_closed":true}'
	tdlib.send_query(client, q)
}

pub fn open_topic(client voidptr, chat_id i64, topic_id i64) {
	real_topic := topic_id * 1048576
	q := '{"@type":"toggleForumTopicIsClosed","chat_id":${chat_id},"message_thread_id":${real_topic},"is_closed":false}'
	tdlib.send_query(client, q)
}

pub fn delete_topic(client voidptr, chat_id i64, topic_id i64) {
	real_topic := topic_id * 1048576
	q := '{"@type":"deleteForumTopic","chat_id":${chat_id},"message_thread_id":${real_topic}}'
	tdlib.send_query(client, q)
}

pub fn pin_topic(client voidptr, chat_id i64, topic_id i64) {
	real_topic := topic_id * 1048576
	q := '{"@type":"toggleForumTopicIsPinned","chat_id":${chat_id},"message_thread_id":${real_topic},"is_pinned":true}'
	tdlib.send_query(client, q)
}

pub fn unpin_topic(client voidptr, chat_id i64, topic_id i64) {
	real_topic := topic_id * 1048576
	q := '{"@type":"toggleForumTopicIsPinned","chat_id":${chat_id},"message_thread_id":${real_topic},"is_pinned":false}'
	tdlib.send_query(client, q)
}

pub fn parse_topics(raw string) []structs.ForumTopic {
	resp := json.decode(structs.ForumTopicsResponse, raw) or { return [] }
	return resp.topics
}

pub fn parse_members(raw string) []structs.ChatMember {
	resp := json.decode(structs.ChatMembersResponse, raw) or { return [] }
	return resp.members
}

pub fn display_topics(topics []structs.ForumTopic) {
	if topics.len == 0 {
		println('[ no topics ]')
		return
	}
	println('--- ${topics.len} topics ---')
	for t in topics {
		mut status := 'open'
		if t.is_closed {
			status = 'closed'
		}
		println('[${t.message_thread_id}] ${t.name} (${status})')
	}
	println('---')
}

pub fn display_members(members []structs.ChatMember) {
	if members.len == 0 {
		println('[ no members ]')
		return
	}
	println('--- ${members.len} members ---')
	for m in members {
		println('[${m.member_id.user_id}] ${m.status.@type}')
	}
	println('---')
}

pub fn display_user(user structs.UserInfo) {
	println('--- user ---')
	println('id: ${user.id}')
	println('first_name: ${user.first_name}')
	println('last_name: ${user.last_name}')
	println('username: ${user.username}')
	println('phone: ${user.phone_number}')
	println('is_premium: ${user.is_premium}')
	println('---')
}

pub fn display_supergroup(sg structs.SupergroupInfo) {
	println('--- supergroup ---')
	println('id: ${sg.id}')
	println('username: ${sg.username}')
	println('member_count: ${sg.member_count}')
	println('is_channel: ${sg.is_channel}')
	println('is_forum: ${sg.is_forum}')
	println('---')
}
