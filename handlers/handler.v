module handlers

import json
import tdlib
import structs
import os
import messages

pub fn run(client voidptr, timeout f64, api_id int, api_hash string, on_message fn (voidptr, structs.TextMessage), on_response fn (voidptr, string, string)) ! {
	mut chats_loaded := false

	for {
		response := tdlib.receive(client, timeout)
		rtype := json.decode(structs.Type, response) or { continue }

		match rtype.@type {
			'updateAuthorizationState' {
				p := json.decode(structs.AuthorizationQuery, response) or { continue }
				handle_auth(client, api_id, api_hash, p.authorization_state.@type)
			}
			'updateConnectionState' {
				conn := json.decode(structs.Connection, response) or { continue }
				handle_connection(conn.state.@type)
				if conn.state.@type == 'connectionStateReady' && !chats_loaded {
					messages.load_chats(client, 100)
					chats_loaded = true
				}
			}
			'updateNewMessage' {
				msg := messages.parse(response) or { continue }
				on_message(client, msg)
			}
			'messages' {
				on_response(client, 'messages', response)
			}
			'message' {
				on_response(client, 'message', response)
			}
			'chat' {
				on_response(client, 'chat', response)
			}
			'messageLink' {
				on_response(client, 'messageLink', response)
			}
			'messageThreadInfo' {
				on_response(client, 'messageThreadInfo', response)
			}
			'forumTopics' {
				on_response(client, 'forumTopics', response)
			}
			'user' {
				on_response(client, 'user', response)
			}
			'supergroup' {
				on_response(client, 'supergroup', response)
			}
			'chatMembers' {
				on_response(client, 'chatMembers', response)
			}
			'ok' {}
			'updateMessageSendSucceeded' {}
			'error' {
				on_response(client, 'error', response)
			}
			else {}
		}
	}
}

fn handle_connection(state string) {
	match state {
		'connectionStateWaitingForNetwork' { println('waiting for network...') }
		'connectionStateConnecting' { println('connecting...') }
		'connectionStateConnectingToProxy' { println('connecting to proxy...') }
		'connectionStateUpdating' { println('updating...') }
		'connectionStateReady' { println('connected.') }
		else {}
	}
}

fn handle_auth(client voidptr, api_id int, api_hash string, state string) {
	match state {
		'authorizationStateWaitTdlibParameters' {
			par := structs.Parameters{
				use_test_dc: false
				database_directory: 'data/td_data'
				files_directory: 'data/td_files'
				database_encryption_key: ''
				use_file_database: true
				use_chat_info_database: true
				use_message_database: true
				use_secret_chats: false
				api_id: api_id
				api_hash: api_hash
				system_language_code: 'en'
				device_model: 'Desktop'
				system_version: ''
				application_version: '0.1'
				enable_storage_optimizer: false
				ignore_file_names: false
			}
			tdlib.send_query(client, json.encode(par))
		}
		'authorizationStateWaitPhoneNumber' {
			phone := os.input('phone number: ')
			q := '{"@type":"setAuthenticationPhoneNumber","phone_number":"${phone}"}'
			tdlib.send_query(client, q)
		}
		'authorizationStateWaitCode' {
			code := os.input('auth code: ')
			q := '{"@type":"checkAuthenticationCode","code":"${code}"}'
			tdlib.send_query(client, q)
		}
		'authorizationStateWaitPassword' {
			pass := os.input('2fa password: ')
			q := '{"@type":"checkAuthenticationPassword","password":"${pass}"}'
			tdlib.send_query(client, q)
		}
		'authorizationStateReady' {
			println('logged in.')
		}
		else {}
	}
}