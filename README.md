# Velegram

A V language wrapper for [TDLib](https://github.com/tdlib/td) (Telegram Database Library).

---

## Requirements

- [V](https://vlang.io)
- [TDLib](https://github.com/tdlib/td) compiled and installed
- Telegram API credentials from [my.telegram.org](https://my.telegram.org)

---

## Quick Start

```v
import messages

fn on_message(client voidptr, msg structs.TextMessage) {
    if !msg.is_outgoing {
        println(msg.text)
        messages.reply(client, msg.chat_id, msg.id, 'got it')
    }
}
```

---

## Features

### Send

| Function | Description |
|----------|-------------|
| `messages.send` | plain text |
| `messages.send_bold` | bold |
| `messages.send_italic` | italic |
| `messages.send_underline` | underline |
| `messages.send_strike` | strikethrough |
| `messages.send_code` | inline code |
| `messages.send_code_block` | code block with language |
| `messages.send_spoiler` | spoiler |
| `messages.send_quote` | block quote |
| `messages.send_link_text` | hyperlink text |
| `messages.send_formatted` | custom entities |
| `messages.send_silent` | no notification |
| `messages.send_scheduled` | scheduled |
| `messages.send_once_online` | send when user is online |
| `messages.send_no_preview` | no link preview |

### Reply

| Function | Description |
|----------|-------------|
| `messages.reply` | reply text |
| `messages.reply_formatted` | reply with entities |
| `messages.reply_silent` | reply silently |
| `messages.reply_bold` | reply bold |

### Edit / Delete

| Function | Description |
|----------|-------------|
| `messages.edit` | edit text |
| `messages.edit_formatted` | edit with entities |
| `messages.edit_bold` | edit bold |
| `messages.delete_one` | delete single message |
| `messages.delete` | delete multiple messages |

### Forward / Copy

| Function | Description |
|----------|-------------|
| `messages.forward_one` | forward single |
| `messages.forward` | forward multiple |
| `messages.forward_silent` | forward silently |
| `messages.forward_copy` | forward without source |
| `messages.copy_one` | copy single |

### Pin

| Function | Description |
|----------|-------------|
| `messages.pin` | pin message |
| `messages.pin_self` | pin only for yourself |
| `messages.unpin` | unpin message |
| `messages.unpin_all` | unpin all |

### Read

| Function | Description |
|----------|-------------|
| `messages.get` | get message by id |
| `messages.get_many` | get multiple messages |
| `messages.get_history` | chat history |
| `messages.get_link` | get message link |
| `messages.search` | search in chat |
| `messages.search_global` | search everywhere |
| `messages.fetch_history` | fetch and return parsed messages |
| `messages.fetch_message` | fetch single parsed message |
| `messages.fetch_search` | fetch and return search results |
| `messages.fetch_comments` | fetch post comments |

### Chat

| Function | Description |
|----------|-------------|
| `messages.resolve_chat` | resolve username to chat |
| `messages.open_chat` | open chat |
| `messages.load_chats` | load chat list |
| `messages.join_chat` | join chat |
| `messages.leave_chat` | leave chat |
| `messages.join_by_link` | join by invite link |
| `messages.set_chat_title` | change title |
| `messages.set_chat_description` | change description |
| `messages.mute_chat` | mute |
| `messages.unmute_chat` | unmute |
| `messages.archive_chat` | archive |
| `messages.unarchive_chat` | unarchive |

### Members

| Function | Description |
|----------|-------------|
| `messages.add_member` | add member |
| `messages.ban_member` | ban |
| `messages.unban_member` | unban |
| `messages.promote_admin` | promote to admin |
| `messages.demote_admin` | demote admin |
| `messages.restrict_member` | restrict |
| `messages.unrestrict_member` | unrestrict |
| `messages.block_user` | block user |
| `messages.unblock_user` | unblock user |

### Topics

| Function | Description |
|----------|-------------|
| `messages.send_to_topic` | send to forum topic |
| `messages.reply_in_topic` | reply in topic |
| `messages.create_topic` | create topic |
| `messages.edit_topic` | rename topic |
| `messages.close_topic` | close topic |
| `messages.open_topic` | reopen topic |
| `messages.delete_topic` | delete topic |
| `messages.pin_topic` | pin topic |
| `messages.unpin_topic` | unpin topic |

### Other

| Function | Description |
|----------|-------------|
| `messages.typing` | show typing status |
| `messages.typing_cancel` | cancel typing |
| `messages.set_draft` | set draft |
| `messages.clear_draft` | clear draft |
| `messages.mark_read` | mark as read |

---

## Test Commands

Send these in any Telegram chat while running:

```
/ping              edit to pong
/bold              send bold text
/italic            send italic
/code              inline code
/codeblock         code block
/spoiler           spoiler text
/quote             block quote
/link              hyperlink
/silent            silent message
/nopreview         no link preview
/scheduled         send after 1 min
/typing            show typing
/draft             set draft
/history           last 20 messages
/history CID N     N messages from chat
/resolve @user     get chat_id
/getmsg CID MID    read specific message
/search KEY        search in chat
/send CID TEXT     send to another chat
/sendto @user TEXT send by username
/topic TID TEXT    send to topic
/info              chat info
/members           member list
/topics            forum topics
/user UID          user info
/forward           forward (reply)
/copy              copy (reply)
/pin               pin (reply)
/unpin             unpin (reply)
/join @user        join chat
/leave CID         leave chat
/ban UID           ban member
/promote UID       promote admin
/block UID         block user
/delete            delete message
```

---

## License
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)