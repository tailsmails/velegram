# Velegram

A V language wrapper for [TDLib](https://github.com/tdlib/td) (Telegram Database Library).

Velegram provides a structured, type-safe API interface to communicate with TDLib, allowing you to develop both userbots and bot accounts in the V language.

---

## Requirements

* **V Language** (latest stable version)
* **TDLib** compiled and installed on your system (shared library `libtdjson` must be accessible)
* Telegram API credentials (`api_id` and `api_hash`) from [my.telegram.org](https://my.telegram.org)

---

## Architecture Overview

Velegram handles communication with TDLib through two main execution models:

1. **Asynchronous (Fire-and-Forget):** Most sending and action commands (e.g., `send`, `reply`, `delete`) send a query to TDLib and return immediately. The results or errors are received asynchronously through the main event loop in your `on_response` callback.
2. **Synchronous (Request-Response matching):** Functions prefixed with `fetch_` (defined in `reader.v`) use TDLib's `@extra` field tracking. They send a query, block the thread up to a specified timeout, filter out unrelated incoming updates, match the corresponding response ID, and return the parsed V struct directly.

---

## Quick Start

Create a `main.v` file and configure your credentials:

```v
module main

import tdlib
import handlers
import structs
import messages

fn on_message(client voidptr, msg structs.TextMessage) {
	if msg.is_outgoing {
		return
	}
	println('[New Message] ${msg.sender_id}: ${msg.text}')
	
	if msg.text == '/ping' {
		messages.reply(client, msg.chat_id, msg.id, 'pong')
	}
}

fn on_response(client voidptr, resp_type string, raw string) {
	// Handles asynchronous responses from TDLib
}

fn main() {
	api_id := 123456
	api_hash := 'your_api_hash'
	bot_token := 'your_bot_token' // Leave empty for user-account login

	client := tdlib.new_client() or {
		eprintln(err)
		return
	}

	handlers.run(client, 1.0, api_id, api_hash, bot_token, on_message, on_response) or {
		eprintln(err)
	}

	tdlib.client_destroy(client)
}
```

---

## API Documentation

### Message Sending

| Function | Description |
| :--- | :--- |
| `messages.send` | Sends a plain text message |
| `messages.send_bold` | Sends text formatted in bold |
| `messages.send_italic` | Sends text formatted in italic |
| `messages.send_underline` | Sends text formatted with an underline |
| `messages.send_strike` | Sends text formatted with a strikethrough |
| `messages.send_code` | Sends inline monospace code |
| `messages.send_code_block` | Sends a code block with language syntax highlighting |
| `messages.send_spoiler` | Sends spoiler-tagged hidden text |
| `messages.send_quote` | Sends a blockquote block |
| `messages.send_link_text` | Sends text with an embedded hyperlink |
| `messages.send_formatted` | Sends text with a custom list of text entities |
| `messages.send_silent` | Sends a message without triggering a push notification |
| `messages.send_scheduled` | Schedules a message to be sent at a specific Unix timestamp |
| `messages.send_once_online` | Sends a message the next time the recipient comes online |
| `messages.send_no_preview` | Sends a text message with disabled link previews |

### Media & Files

| Function | Description |
| :--- | :--- |
| `messages.send_photo` | Sends a local photo with a caption |
| `messages.send_document` | Sends a local document/file with a caption |
| `messages.send_voice` | Sends a local .ogg voice message with duration and caption |
| `messages.send_video` | Sends a local video file with a caption |
| `messages.send_sticker` | Sends a local sticker file (.webp / .tgs) |
| `messages.send_location` | Sends geographical coordinates |
| `messages.send_contact` | Sends a contact card |
| `messages.send_venue` | Sends a specific venue/location details |
| `messages.download_file` | Initiates downloading a file from Telegram servers |

### Replies & Actions

| Function | Description |
| :--- | :--- |
| `messages.reply` | Replies to a specific message |
| `messages.reply_formatted` | Replies with custom text entities |
| `messages.reply_silent` | Replies without sending sound notifications |
| `messages.reply_bold` | Replies with bold text |
| `messages.add_reaction` | Adds an emoji reaction to a message |
| `messages.remove_reaction` | Removes an emoji reaction from a message |

### Edit / Delete / Forward

| Function | Description |
| :--- | :--- |
| `messages.edit` | Edits the text of an existing message |
| `messages.edit_formatted` | Edits message text and applies custom entities |
| `messages.edit_bold` | Edits message text to bold |
| `messages.delete_one` | Deletes a single message |
| `messages.delete` | Deletes a list of messages |
| `messages.forward_one` | Forwards a single message to another chat |
| `messages.forward` | Forwards multiple messages to another chat |
| `messages.forward_silent` | Forwards messages silently |
| `messages.forward_copy` | Sends a copy of messages without forwarding attribution |
| `messages.copy_one` | Copies a single message to a target chat |

### Chat & Account Management

| Function | Description |
| :--- | :--- |
| `messages.resolve_chat` | Resolves a public username (e.g. `@channel`) |
| `messages.open_chat` | Notifies TDLib that a chat is being opened |
| `messages.close_chat` | Notifies TDLib that a chat is being closed |
| `messages.load_chats` | Pre-loads your Telegram chat list |
| `messages.join_chat` | Joins a group/channel by its ID |
| `messages.leave_chat` | Leaves a group/channel |
| `messages.join_by_link` | Joins a private chat using an invite link |
| `messages.set_chat_title` | Updates chat title |
| `messages.set_chat_description` | Updates chat description |
| `messages.mute_chat` | Mutes notifications of a chat indefinitely |
| `messages.unmute_chat` | Unmutes notifications of a chat |
| `messages.archive_chat` | Moves a chat to the archived folder |
| `messages.unarchive_chat` | Restores an archived chat to the main list |
| `messages.get_common_chats` | Gets common groups with a specific user |
| `messages.report_chat` | Reports a chat for spam or abuse |

### Member Moderation & Contacts

| Function | Description |
| :--- | :--- |
| `messages.add_member` | Adds a user to a group chat |
| `messages.ban_member` | Bans and removes a user from a chat |
| `messages.unban_member` | Lifts a ban on a user in a chat |
| `messages.promote_admin` | Promotes a member to an administrator with full rights |
| `messages.demote_admin` | Demotes an administrator back to a regular member |
| `messages.restrict_member` | Restricts a user's permissions until a specific date |
| `messages.unrestrict_member` | Restores a restricted user's normal permissions |
| `messages.block_user` | Adds a user to your personal block list |
| `messages.unblock_user` | Removes a user from your block list |
| `messages.block_chat` | Blocks a chat's sender |
| `messages.add_contact` | Imports a new contact |
| `messages.delete_contact` | Removes an existing contact |
| `messages.get_contacts` | Fetches your personal contact list |

### Forums & Topics

| Function | Description |
| :--- | :--- |
| `messages.send_to_topic` | Sends a message to a specific topic ID |
| `messages.reply_in_topic` | Replies to a message inside a topic |
| `messages.send_comment` | Fetches a discussion thread for channel comments |
| `messages.send_comment_text` | Sends a comment directly to a discussion thread |
| `messages.create_topic` | Creates a new forum topic |
| `messages.edit_topic` | Renames an existing topic |
| `messages.close_topic` | Closes a topic (disables sending messages) |
| `messages.open_topic` | Reopens a closed topic |
| `messages.delete_topic` | Deletes a topic and all its messages |
| `messages.pin_topic` | Pins a topic to the top of the forum |
| `messages.unpin_topic` | Unpins a topic |

### Synchronous Fetching (Via `@extra` Tracking)

These functions wait for TDLib's sequential events, match the unique transaction ID (`@extra`), and return parsed structs or optional types synchronously:

| Function | Return Type | Description |
| :--- | :--- | :--- |
| `messages.fetch_history` | `[]structs.TextMessage` | Fetches chat history |
| `messages.fetch_history_topic` | `[]structs.TextMessage` | Fetches history from a forum topic |
| `messages.fetch_message` | `?structs.TextMessage` | Fetches a single parsed message |
| `messages.fetch_message_raw` | `?structs.TextMessage` | Fetches a single message without opening chat |
| `messages.fetch_search` | `[]structs.TextMessage` | Searches messages inside a specific chat |
| `messages.fetch_search_global` | `[]structs.TextMessage` | Searches messages globally |
| `messages.fetch_chat_info` | `?structs.ChatInfo` | Fetches general details about a chat |
| `messages.fetch_chat_by_username`| `?structs.ChatInfo` | Resolves username and fetches chat details |
| `messages.fetch_link` | `?structs.MessageLinkResponse`| Gets an HTTPS public link of a message |
| `messages.fetch_comments` | `[]structs.TextMessage` | Fetches comments of a channel post |
| `messages.fetch_topics` | `[]structs.ForumTopic` | Fetches a list of topics in a forum |
| `messages.fetch_user_info` | `?structs.UserInfo` | Fetches a user's profile information |
| `messages.fetch_private_chat` | `?structs.ChatInfo` | Creates a private chat and returns its info |
| `messages.fetch_supergroup_info` | `?structs.SupergroupInfo` | Fetches full information of a supergroup |
| `messages.fetch_supergroup_members`| `[]structs.ChatMember` | Fetches recent members of a supergroup |
| `messages.fetch_me` | `?structs.UserInfo` | Fetches the current logged-in account info |
| `messages.fetch_invite_link_info` | `?string` | Resolves chat invitation link details |
| `messages.fetch_chat_members_search`| `[]structs.ChatMember` | Searches chat members based on a query |
| `messages.fetch_sticker_set` | `?string` | Fetches information about a sticker set |
| `messages.fetch_contacts` | `?string` | Fetches and returns contacts raw response |

---

## Testing Commands

When running the project with `main.v`, you can send these commands in any chat to test the library's features:

```text
/ping              replies with "pong"
/delete            deletes the sent command message
/silent            sends a silent test message
/nopreview         sends link without rich preview
/typing            displays "typing" chat action
/bold              sends text in bold
/italic            sends text in italic
/underline         sends text with underline
/strike            sends text with strikethrough
/code              sends inline monospace text
/codeblock         sends formatted code block
/spoiler           sends hidden spoiler text
/quote             sends blocked quote text
/link              sends text hyperlink
/scheduled         sends a scheduled message (+1 min)
/draft             sets active draft in current chat
/cleardraft        clears current draft
/read              marks current message as read
/history           requests last 20 messages (async)
/mute              mutes notifications for current chat
/unmute            unmutes notifications for current chat
/archive           archives current chat
/unarchive         restores chat from archive
/info              retrieves and displays current chat details
/sginfo            retrieves supergroup info
/members           retrieves first 50 supergroup members
/topics            retrieves first 50 forum topics
/getlink           gets HTTP link of replied message
/forward           forwards replied message
/copy              copies replied message without author
/pin               pins replied message
/unpin             unpins replied message
/unpinall          unpins all pinned messages in chat
/photo             sends local photo (requires data/test.jpg)
/doc               sends local PDF (requires data/test.pdf)
/voice             sends local voice file (requires data/test.ogg)
/video             sends local video file (requires data/test.mp4)
/sticker           sends local WebP sticker (requires data/test.webp)
/location          sends test coordinates
/contact           sends dummy contact card
/venue             sends test venue details
/react             adds 👍 reaction to replied message
/unreact           removes 👍 reaction from replied message
/fetch             synchronously fetches and displays replied message text
/fetchchat         synchronously fetches current chat title
/createtopic [N]   creates a forum topic named N
/closetopic [ID]   closes forum topic with ID
/opentopic [ID]    reopens forum topic with ID
/download [ID]     downloads file by its local ID
/history [C] [N]   fetches last N messages from chat ID C
/resolve [U]       resolves public username U
/getmsg [C] [M]    reads specific message M from chat C
/search [Q]        searches Q in current chat
/gsearch [Q]       searches Q globally
/user [ID]         reads profile of user ID
/send [C] [T]      sends text T to chat ID C
/sendto [U] [T]    resolves username U and sends text T
/topic [ID] [T]    sends text T to topic ID
/join [U/L]        joins chat via username U or invite link L
/leave [C]         leaves chat with ID C
/ban [ID]          bans user ID from current chat
/unban [ID]        unbans user ID in current chat
/promote [ID]      promotes user ID to administrator
/demote [ID]       demotes admin user ID
/block [ID]        adds user ID to personal blocklist
/unblock [ID]      removes user ID from blocklist
```

---

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
