module messages

import json
import tdlib
import structs

fn escape(s string) string {
	return s.replace('\\', '\\\\')
		.replace('"', '\\"')
		.replace('\n', '\\n')
		.replace('\r', '\\r')
		.replace('\t', '\\t')
		.replace('\b', '\\b')
		.replace('\f', '\\f')
}

fn utf16_len(s string) int {
	mut count := 0
	for c in s.runes() {
		if c > 0xFFFF {
			count += 2
		} else {
			count += 1
		}
	}
	return count
}

fn build_entities(entities []structs.TextEntityInput) string {
	if entities.len == 0 {
		return '[]'
	}
	mut parts := []string{}
	for e in entities {
		if e.url.len > 0 {
			parts << '{"@type":"textEntity","offset":${e.offset},"length":${e.length},"type":{"@type":"${e.entity_type}","url":"${escape(e.url)}"}}'
		} else if e.language.len > 0 {
			parts << '{"@type":"textEntity","offset":${e.offset},"length":${e.length},"type":{"@type":"${e.entity_type}","language":"${escape(e.language)}"}}'
		} else {
			parts << '{"@type":"textEntity","offset":${e.offset},"length":${e.length},"type":{"@type":"${e.entity_type}"}}'
		}
	}
	return '[${parts.join(",")}]'
}

fn to_text_message(msg structs.Message) ?structs.TextMessage {
	mut text := ''
	mut entities := []structs.Entity{}

	if msg.content.@type == 'messageText' {
		text_data := msg.content.text or { return none }
		text = text_data.text
		entities = text_data.entities.clone()
	} else if msg.content.@type == 'messageContactRegistered' {
		text = '[Service: joined Telegram]'
	} else if msg.content.@type == 'messageChatAddMembers' {
		text = '[Service: added to chat]'
	} else if msg.content.@type == 'messageChatJoinByLink' {
		text = '[Service: joined by invite link]'
	} else if msg.content.@type == 'messagePinMessage' {
		text = '[Service: pinned a message]'
	} else if msg.content.@type == 'messageChatDeleteMember' {
		text = '[Service: left or removed from chat]'
	} else {
		return none
	}

	mut sender_type := ''
	mut sender_id := i64(0)
	if msg.sender_id.@type == 'messageSenderUser' {
		sender_type = 'user'
		sender_id = msg.sender_id.user_id
	} else if msg.sender_id.@type == 'messageSenderChat' {
		sender_type = 'chat'
		sender_id = msg.sender_id.chat_id
	}
	mut reply_id := i64(0)
	if reply := msg.reply_to {
		reply_id = reply.message_id
	}
	return structs.TextMessage{
		id: msg.id
		chat_id: msg.chat_id
		sender_type: sender_type
		sender_id: sender_id
		is_outgoing: msg.is_outgoing
		date: msg.date
		text: text
		entities: entities
		reply_to_id: reply_id
	}
}

pub fn parse(raw string) ?structs.TextMessage {
	update := json.decode(structs.UpdateNewMessage, raw) or { return none }
	return to_text_message(update.message)
}

pub fn parse_single(raw string) ?structs.TextMessage {
	msg := json.decode(structs.Message, raw) or { return none }
	return to_text_message(msg)
}

pub fn parse_response(raw string) []structs.TextMessage {
	resp := json.decode(structs.MessagesResponse, raw) or { return [] }
	mut result := []structs.TextMessage{}
	for msg in resp.messages {
		if t_msg := to_text_message(msg) {
			result << t_msg
		}
	}
	return result
}

pub fn parse_chat(raw string) ?structs.ChatInfo {
	return json.decode(structs.ChatInfo, raw) or { return none }
}

pub fn parse_link(raw string) ?structs.MessageLinkResponse {
	return json.decode(structs.MessageLinkResponse, raw) or { return none }
}

fn send_with_single_entity(client voidptr, chat_id i64, text string, entity_type string, extra_attrs string) {
	l := utf16_len(text)
	extra := if extra_attrs.len > 0 { ',${extra_attrs}' } else { '' }
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}","entities":[{"@type":"textEntity","offset":0,"length":${l},"type":{"@type":"${entity_type}"${extra}}}]}}}'
	tdlib.send_query(client, q)
}

pub fn send(client voidptr, chat_id i64, text string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_bold(client voidptr, chat_id i64, text string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypeBold', '')
}

pub fn send_italic(client voidptr, chat_id i64, text string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypeItalic', '')
}

pub fn send_underline(client voidptr, chat_id i64, text string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypeUnderline', '')
}

pub fn send_strike(client voidptr, chat_id i64, text string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypeStrikethrough', '')
}

pub fn send_code(client voidptr, chat_id i64, text string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypeCode', '')
}

pub fn send_code_block(client voidptr, chat_id i64, text string, language string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypePre', '"language":"${escape(language)}"')
}

pub fn send_spoiler(client voidptr, chat_id i64, text string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypeSpoiler', '')
}

pub fn send_quote(client voidptr, chat_id i64, text string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypeBlockQuote', '')
}

pub fn send_link_text(client voidptr, chat_id i64, text string, url string) {
	send_with_single_entity(client, chat_id, text, 'textEntityTypeTextUrl', '"url":"${escape(url)}"')
}

pub fn send_formatted(client voidptr, chat_id i64, text string, entities []structs.TextEntityInput) {
	ent := build_entities(entities)
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}","entities":${ent}}}}'
	tdlib.send_query(client, q)
}

pub fn send_silent(client voidptr, chat_id i64, text string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"options":{"@type":"messageSendOptions","disable_notification":true},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_scheduled(client voidptr, chat_id i64, text string, send_date int) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"options":{"@type":"messageSendOptions","scheduling_state":{"@type":"messageSchedulingStateSendAtDate","send_date":${send_date}}},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_once_online(client voidptr, chat_id i64, text string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"options":{"@type":"messageSendOptions","scheduling_state":{"@type":"messageSchedulingStateSendWhenOnline"}},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_no_preview(client voidptr, chat_id i64, text string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"},"link_preview_options":{"@type":"linkPreviewOptions","is_disabled":true}}}'
	tdlib.send_query(client, q)
}

pub fn send_photo(client voidptr, chat_id i64, file_path string, caption string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessagePhoto","photo":{"@type":"inputFileLocal","path":"${escape(file_path)}"},"caption":{"@type":"formattedText","text":"${escape(caption)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_document(client voidptr, chat_id i64, file_path string, caption string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageDocument","document":{"@type":"inputFileLocal","path":"${escape(file_path)}"},"caption":{"@type":"formattedText","text":"${escape(caption)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_voice(client voidptr, chat_id i64, file_path string, duration int, caption string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageVoice","voice":{"@type":"inputFileLocal","path":"${escape(file_path)}"},"duration":${duration},"caption":{"@type":"formattedText","text":"${escape(caption)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_video(client voidptr, chat_id i64, file_path string, caption string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageVideo","video":{"@type":"inputFileLocal","path":"${escape(file_path)}"},"caption":{"@type":"formattedText","text":"${escape(caption)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_sticker(client voidptr, chat_id i64, file_path string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageSticker","sticker":{"@type":"inputFileLocal","path":"${escape(file_path)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_location(client voidptr, chat_id i64, latitude f64, longitude f64) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageLocation","location":{"@type":"location","latitude":${latitude},"longitude":${longitude},"horizontal_accuracy":0.0}}}'
	tdlib.send_query(client, q)
}

pub fn send_contact(client voidptr, chat_id i64, phone_number string, first_name string, last_name string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageContact","contact":{"@type":"contact","phone_number":"${escape(phone_number)}","first_name":"${escape(first_name)}","last_name":"${escape(last_name)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_venue(client voidptr, chat_id i64, latitude f64, longitude f64, title string, address string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageVenue","venue":{"@type":"venue","location":{"@type":"location","latitude":${latitude},"longitude":${longitude},"horizontal_accuracy":0.0},"title":"${escape(title)}","address":"${escape(address)}","provider":"","id":""}}}'
	tdlib.send_query(client, q)
}

pub fn reply(client voidptr, chat_id i64, message_id i64, text string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"reply_to":{"@type":"inputMessageReplyToMessage","message_id":${message_id}},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn reply_formatted(client voidptr, chat_id i64, message_id i64, text string, entities []structs.TextEntityInput) {
	ent := build_entities(entities)
	q := '{"@type":"sendMessage","chat_id":${chat_id},"reply_to":{"@type":"inputMessageReplyToMessage","message_id":${message_id}},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}","entities":${ent}}}}'
	tdlib.send_query(client, q)
}

pub fn reply_silent(client voidptr, chat_id i64, message_id i64, text string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"reply_to":{"@type":"inputMessageReplyToMessage","message_id":${message_id}},"options":{"@type":"messageSendOptions","disable_notification":true},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn reply_bold(client voidptr, chat_id i64, message_id i64, text string) {
	l := utf16_len(text)
	q := '{"@type":"sendMessage","chat_id":${chat_id},"reply_to":{"@type":"inputMessageReplyToMessage","message_id":${message_id}},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}","entities":[{"@type":"textEntity","offset":0,"length":${l},"type":{"@type":"textEntityTypeBold"}}]}}}'
	tdlib.send_query(client, q)
}

pub fn edit(client voidptr, chat_id i64, message_id i64, new_text string) {
	q := '{"@type":"editMessageText","chat_id":${chat_id},"message_id":${message_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(new_text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn edit_formatted(client voidptr, chat_id i64, message_id i64, new_text string, entities []structs.TextEntityInput) {
	ent := build_entities(entities)
	q := '{"@type":"editMessageText","chat_id":${chat_id},"message_id":${message_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(new_text)}","entities":${ent}}}}'
	tdlib.send_query(client, q)
}

pub fn edit_bold(client voidptr, chat_id i64, message_id i64, text string) {
	l := utf16_len(text)
	q := '{"@type":"editMessageText","chat_id":${chat_id},"message_id":${message_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}","entities":[{"@type":"textEntity","offset":0,"length":${l},"type":{"@type":"textEntityTypeBold"}}]}}}'
	tdlib.send_query(client, q)
}

pub fn delete(client voidptr, chat_id i64, message_ids []i64, for_everyone bool) {
	ids := message_ids.map(it.str()).join(',')
	q := '{"@type":"deleteMessages","chat_id":${chat_id},"message_ids":[${ids}],"revoke":${for_everyone}}'
	tdlib.send_query(client, q)
}

pub fn delete_one(client voidptr, chat_id i64, message_id i64, for_everyone bool) {
	delete(client, chat_id, [message_id], for_everyone)
}

pub fn forward(client voidptr, to_chat i64, from_chat i64, message_ids []i64) {
	ids := message_ids.map(it.str()).join(',')
	q := '{"@type":"forwardMessages","chat_id":${to_chat},"from_chat_id":${from_chat},"message_ids":[${ids}]}'
	tdlib.send_query(client, q)
}

pub fn forward_one(client voidptr, to_chat i64, from_chat i64, message_id i64) {
	forward(client, to_chat, from_chat, [message_id])
}

pub fn forward_silent(client voidptr, to_chat i64, from_chat i64, message_ids []i64) {
	ids := message_ids.map(it.str()).join(',')
	q := '{"@type":"forwardMessages","chat_id":${to_chat},"from_chat_id":${from_chat},"message_ids":[${ids}],"options":{"@type":"messageSendOptions","disable_notification":true}}'
	tdlib.send_query(client, q)
}

pub fn forward_copy(client voidptr, to_chat i64, from_chat i64, message_ids []i64) {
	ids := message_ids.map(it.str()).join(',')
	q := '{"@type":"forwardMessages","chat_id":${to_chat},"from_chat_id":${from_chat},"message_ids":[${ids}],"send_copy":true}'
	tdlib.send_query(client, q)
}

pub fn copy_one(client voidptr, to_chat i64, from_chat i64, message_id i64) {
	forward_copy(client, to_chat, from_chat, [message_id])
}

pub fn pin(client voidptr, chat_id i64, message_id i64, silent bool) {
	q := '{"@type":"pinChatMessage","chat_id":${chat_id},"message_id":${message_id},"disable_notification":${silent},"only_for_self":false}'
	tdlib.send_query(client, q)
}

pub fn pin_self(client voidptr, chat_id i64, message_id i64) {
	q := '{"@type":"pinChatMessage","chat_id":${chat_id},"message_id":${message_id},"disable_notification":true,"only_for_self":true}'
	tdlib.send_query(client, q)
}

pub fn unpin(client voidptr, chat_id i64, message_id i64) {
	q := '{"@type":"unpinChatMessage","chat_id":${chat_id},"message_id":${message_id}}'
	tdlib.send_query(client, q)
}

pub fn unpin_all(client voidptr, chat_id i64) {
	q := '{"@type":"unpinAllChatMessages","chat_id":${chat_id}}'
	tdlib.send_query(client, q)
}

pub fn search(client voidptr, chat_id i64, query string, limit int) {
	q := '{"@type":"searchChatMessages","chat_id":${chat_id},"query":"${escape(query)}","from_message_id":0,"offset":0,"limit":${limit}}'
	tdlib.send_query(client, q)
}

pub fn search_global(client voidptr, query string, limit int) {
	q := '{"@type":"searchMessages","query":"${escape(query)}","offset":"","limit":${limit}}'
	tdlib.send_query(client, q)
}

pub fn mark_read(client voidptr, chat_id i64, message_id i64) {
	q := '{"@type":"viewMessages","chat_id":${chat_id},"message_ids":[${message_id}],"force_read":true}'
	tdlib.send_query(client, q)
}

pub fn get_history(client voidptr, chat_id i64, from_message_id i64, limit int) {
	q := '{"@type":"getChatHistory","chat_id":${chat_id},"from_message_id":${from_message_id},"offset":0,"limit":${limit},"only_local":false}'
	tdlib.send_query(client, q)
}

pub fn get_link(client voidptr, chat_id i64, message_id i64) {
	q := '{"@type":"getMessageLink","chat_id":${chat_id},"message_id":${message_id}}'
	tdlib.send_query(client, q)
}

pub fn resolve_chat(client voidptr, username string) {
	mut clean := username
	if clean.starts_with('@') {
		clean = clean[1..]
	}
	q := '{"@type":"searchPublicChat","username":"${escape(clean)}"}'
	tdlib.send_query(client, q)
}

pub fn load_chats(client voidptr, limit int) {
	q := '{"@type":"loadChats","chat_list":{"@type":"chatListMain"},"limit":${limit}}'
	tdlib.send_query(client, q)
}

pub fn typing(client voidptr, chat_id i64) {
	q := '{"@type":"sendChatAction","chat_id":${chat_id},"action":{"@type":"chatActionTyping"}}'
	tdlib.send_query(client, q)
}

pub fn typing_cancel(client voidptr, chat_id i64) {
	q := '{"@type":"sendChatAction","chat_id":${chat_id},"action":{"@type":"chatActionCancel"}}'
	tdlib.send_query(client, q)
}

pub fn set_draft(client voidptr, chat_id i64, text string) {
	q := '{"@type":"setChatDraftMessage","chat_id":${chat_id},"draft_message":{"@type":"draftMessage","input_message_text":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}}'
	tdlib.send_query(client, q)
}

pub fn clear_draft(client voidptr, chat_id i64) {
	q := '{"@type":"setChatDraftMessage","chat_id":${chat_id}}'
	tdlib.send_query(client, q)
}

pub fn display_messages(msgs []structs.TextMessage) {
	if msgs.len == 0 {
		println('[ no text messages ]')
		return
	}
	println('--- ${msgs.len} messages ---')
	for m in msgs {
		mut direction := '<'
		if m.is_outgoing {
			direction = '>'
		}
		mut reply_info := ''
		if m.reply_to_id > 0 {
			reply_info = ' [reply:${m.reply_to_id}]'
		}
		println('[${m.id}] ${m.sender_type}:${m.sender_id} ${direction} ${m.text}${reply_info}')
	}
	println('---')
}

pub fn open_chat(client voidptr, chat_id i64) {
	q := '{"@type":"openChat","chat_id":${chat_id}}'
	tdlib.send_query(client, q)
}

pub fn close_chat(client voidptr, chat_id i64) {
	q := '{"@type":"closeChat","chat_id":${chat_id}}'
	tdlib.send_query(client, q)
}

pub fn get(client voidptr, chat_id i64, message_id i64) {
	q := '{"@type":"getMessage","chat_id":${chat_id},"message_id":${message_id}}'
	tdlib.send_query(client, q)
}

pub fn get_raw(client voidptr, chat_id i64, raw_message_id i64) {
	q := '{"@type":"getMessage","chat_id":${chat_id},"message_id":${raw_message_id}}'
	tdlib.send_query(client, q)
}

pub fn get_many(client voidptr, chat_id i64, message_ids []i64) {
	ids := message_ids.map(it.str()).join(',')
	q := '{"@type":"getMessages","chat_id":${chat_id},"message_ids":[${ids}]}'
	tdlib.send_query(client, q)
}

pub fn kick_member(client voidptr, chat_id i64, user_id i64) {
	q := '{"@type":"setChatMemberStatus","chat_id":${chat_id},"member_id":{"@type":"messageSenderUser","user_id":${user_id}},"status":{"@type":"chatMemberStatusBanned","banned_until_date":0}}'
	tdlib.send_query(client, q)
}

pub fn add_reaction(client voidptr, chat_id i64, message_id i64, emoji string) {
	q := '{"@type":"addMessageReaction","chat_id":${chat_id},"message_id":${message_id},"reaction_type":{"@type":"reactionTypeEmoji","emoji":"${escape(emoji)}"},"is_big":false,"update_recent_reactions":true}'
	tdlib.send_query(client, q)
}

pub fn remove_reaction(client voidptr, chat_id i64, message_id i64, emoji string) {
	q := '{"@type":"removeMessageReaction","chat_id":${chat_id},"message_id":${message_id},"reaction_type":{"@type":"reactionTypeEmoji","emoji":"${escape(emoji)}"}}'
	tdlib.send_query(client, q)
}

pub fn get_me(client voidptr) {
	q := '{"@type":"getMe"}'
	tdlib.send_query(client, q)
}

pub fn get_user(client voidptr, user_id i64) {
	q := '{"@type":"getUser","user_id":${user_id}}'
	tdlib.send_query(client, q)
}

pub fn join_by_username(client voidptr, username string) {
	mut clean := username
	if clean.starts_with('@') {
		clean = clean[1..]
	}
	q := '{"@type":"searchPublicChat","username":"${escape(clean)}"}'
	tdlib.send_query(client, q)
}

pub fn answer_callback_query(client voidptr, callback_query_id u64, text string, show_alert bool) {
	q := '{"@type":"answerCallbackQuery","callback_query_id":${callback_query_id},"text":"${escape(text)}","show_alert":${show_alert}}'
	tdlib.send_query(client, q)
}

pub fn download_file(client voidptr, file_id int, priority int) {
	q := '{"@type":"downloadFile","file_id":${file_id},"priority":${priority},"offset":0,"limit":0,"synchronous":false}'
	tdlib.send_query(client, q)
}

pub fn get_chat_member(client voidptr, chat_id i64, user_id i64) {
	q := '{"@type":"getChatMember","chat_id":${chat_id},"member_id":{"@type":"messageSenderUser","user_id":${user_id}}}'
	tdlib.send_query(client, q)
}

pub fn display_chat(info structs.ChatInfo) {
	println('--- chat ---')
	println('id: ${info.id}')
	println('title: ${info.title}')
	println('---')
}

pub fn display_link(link structs.MessageLinkResponse) {
	println('--- link ---')
	println('${link.link}')
	println('---')
}

pub fn add_contact(client voidptr, phone_number string, first_name string, last_name string) {
	q := '{"@type":"importContacts","contacts":[{"@type":"contact","phone_number":"${escape(phone_number)}","first_name":"${escape(first_name)}","last_name":"${escape(last_name)}"}]}'
	tdlib.send_query(client, q)
}

pub fn delete_contact(client voidptr, user_id i64) {
	q := '{"@type":"removeContacts","user_ids":[${user_id}]}'
	tdlib.send_query(client, q)
}

pub fn get_contacts(client voidptr) {
	q := '{"@type":"getContacts"}'
	tdlib.send_query(client, q)
}
