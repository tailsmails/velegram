module messages

import tdlib

pub fn send_to_user(client voidptr, user_id i64, text string) {
	q := '{"@type":"createPrivateChat","user_id":${user_id},"force":true}'
	tdlib.send_query(client, q)
}

pub fn send_to_user_after(client voidptr, chat_id i64, text string) {
	q := '{"@type":"sendMessage","chat_id":${chat_id},"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"${escape(text)}"}}}'
	tdlib.send_query(client, q)
}

pub fn send_to_username(client voidptr, username string, text string) {
	mut clean := username
	if clean.starts_with('@') {
		clean = clean[1..]
	}
	q := '{"@type":"searchPublicChat","username":"${escape(clean)}"}'
	tdlib.send_query(client, q)
}

pub fn block_user(client voidptr, user_id i64) {
	q := '{"@type":"setMessageSenderBlockList","sender_id":{"@type":"messageSenderUser","user_id":${user_id}},"block_list":{"@type":"blockListMain"}}'
	tdlib.send_query(client, q)
}

pub fn unblock_user(client voidptr, user_id i64) {
	q := '{"@type":"setMessageSenderBlockList","sender_id":{"@type":"messageSenderUser","user_id":${user_id}}}'
	tdlib.send_query(client, q)
}

pub fn block_chat(client voidptr, chat_id i64) {
	q := '{"@type":"setMessageSenderBlockList","sender_id":{"@type":"messageSenderChat","chat_id":${chat_id}},"block_list":{"@type":"blockListMain"}}'
	tdlib.send_query(client, q)
}

pub fn join_chat(client voidptr, chat_id i64) {
	q := '{"@type":"joinChat","chat_id":${chat_id}}'
	tdlib.send_query(client, q)
}

pub fn leave_chat(client voidptr, chat_id i64) {
	q := '{"@type":"leaveChat","chat_id":${chat_id}}'
	tdlib.send_query(client, q)
}

pub fn join_by_link(client voidptr, invite_link string) {
	q := '{"@type":"joinChatByInviteLink","invite_link":"${escape(invite_link)}"}'
	tdlib.send_query(client, q)
}

pub fn set_chat_title(client voidptr, chat_id i64, title string) {
	q := '{"@type":"setChatTitle","chat_id":${chat_id},"title":"${escape(title)}"}'
	tdlib.send_query(client, q)
}

pub fn set_chat_description(client voidptr, chat_id i64, description string) {
	q := '{"@type":"setChatDescription","chat_id":${chat_id},"description":"${escape(description)}"}'
	tdlib.send_query(client, q)
}

pub fn add_member(client voidptr, chat_id i64, user_id i64) {
	q := '{"@type":"addChatMember","chat_id":${chat_id},"user_id":${user_id}}'
	tdlib.send_query(client, q)
}

pub fn ban_member(client voidptr, chat_id i64, user_id i64) {
	q := '{"@type":"banChatMember","chat_id":${chat_id},"member_id":{"@type":"messageSenderUser","user_id":${user_id}}}'
	tdlib.send_query(client, q)
}

pub fn unban_member(client voidptr, chat_id i64, user_id i64) {
	q := '{"@type":"banChatMember","chat_id":${chat_id},"member_id":{"@type":"messageSenderUser","user_id":${user_id}},"banned_until_date":0}'
	tdlib.send_query(client, q)
}

pub fn promote_admin(client voidptr, chat_id i64, user_id i64) {
	q := '{"@type":"setChatMemberStatus","chat_id":${chat_id},"member_id":{"@type":"messageSenderUser","user_id":${user_id}},"status":{"@type":"chatMemberStatusAdministrator","can_be_edited":true,"rights":{"@type":"chatAdministratorRights","can_manage_chat":true,"can_change_info":true,"can_post_messages":true,"can_edit_messages":true,"can_delete_messages":true,"can_invite_users":true,"can_restrict_members":true,"can_pin_messages":true,"can_promote_members":false,"can_manage_video_chats":true}}}'
	tdlib.send_query(client, q)
}

pub fn demote_admin(client voidptr, chat_id i64, user_id i64) {
	q := '{"@type":"setChatMemberStatus","chat_id":${chat_id},"member_id":{"@type":"messageSenderUser","user_id":${user_id}},"status":{"@type":"chatMemberStatusMember"}}'
	tdlib.send_query(client, q)
}

pub fn restrict_member(client voidptr, chat_id i64, user_id i64, until_date int) {
	q := '{"@type":"setChatMemberStatus","chat_id":${chat_id},"member_id":{"@type":"messageSenderUser","user_id":${user_id}},"status":{"@type":"chatMemberStatusRestricted","is_member":true,"restricted_until_date":${until_date},"permissions":{"@type":"chatPermissions","can_send_basic_messages":false,"can_send_audios":false,"can_send_documents":false,"can_send_photos":false,"can_send_videos":false,"can_send_video_notes":false,"can_send_voice_notes":false,"can_send_polls":false,"can_send_other_messages":false,"can_add_link_previews":false,"can_change_info":false,"can_invite_users":false,"can_pin_messages":false,"can_create_topics":false}}}'
	tdlib.send_query(client, q)
}

pub fn unrestrict_member(client voidptr, chat_id i64, user_id i64) {
	q := '{"@type":"setChatMemberStatus","chat_id":${chat_id},"member_id":{"@type":"messageSenderUser","user_id":${user_id}},"status":{"@type":"chatMemberStatusMember"}}'
	tdlib.send_query(client, q)
}

pub fn mute_chat(client voidptr, chat_id i64) {
	q := '{"@type":"setChatNotificationSettings","chat_id":${chat_id},"notification_settings":{"@type":"chatNotificationSettings","use_default_mute_for":false,"mute_for":2147483647}}'
	tdlib.send_query(client, q)
}

pub fn unmute_chat(client voidptr, chat_id i64) {
	q := '{"@type":"setChatNotificationSettings","chat_id":${chat_id},"notification_settings":{"@type":"chatNotificationSettings","use_default_mute_for":true,"mute_for":0}}'
	tdlib.send_query(client, q)
}

pub fn archive_chat(client voidptr, chat_id i64) {
	q := '{"@type":"addChatToList","chat_id":${chat_id},"chat_list":{"@type":"chatListArchive"}}'
	tdlib.send_query(client, q)
}

pub fn unarchive_chat(client voidptr, chat_id i64) {
	q := '{"@type":"addChatToList","chat_id":${chat_id},"chat_list":{"@type":"chatListMain"}}'
	tdlib.send_query(client, q)
}

pub fn get_common_chats(client voidptr, user_id i64) {
	q := '{"@type":"getGroupsInCommon","user_id":${user_id},"offset_chat_id":0,"limit":100}'
	tdlib.send_query(client, q)
}

pub fn report_chat(client voidptr, chat_id i64, reason string) {
	q := '{"@type":"reportChat","chat_id":${chat_id},"reason":{"@type":"reportReasonSpam"},"text":"${escape(reason)}"}'
	tdlib.send_query(client, q)
}