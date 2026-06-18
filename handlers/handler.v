module handlers

import json
import tdlib
import structs
import os
import messages

struct BotAuthQuery {
	@type string @[json: '@type']
	token string
}

struct PhoneAuthQuery {
	@type        string @[json: '@type']
	phone_number string
}

struct CodeAuthQuery {
	@type string @[json: '@type']
	code  string
}

struct PasswordAuthQuery {
	@type    string @[json: '@type']
	password string
}

pub fn run(client voidptr, timeout f64, api_id int, api_hash string, bot_token string, on_message fn (voidptr, structs.TextMessage), on_response fn (voidptr, string, string)) ! {
	mut chats_loaded := false
	mut is_running := true

	for is_running {
		response := tdlib.receive(client, timeout)
		rtype := json.decode(structs.Type, response) or {
			eprintln('Decoding error: ${err.msg()}')
			continue
		}

		match rtype.@type {
			'updateAuthorizationState' {
				p := json.decode(structs.AuthorizationQuery, response) or { continue }
				handle_auth(client, api_id, api_hash, bot_token, p.authorization_state.@type)
				
				if p.authorization_state.@type == 'authorizationStateClosed' {
					is_running = false
				}
			}
			'updateConnectionState' {
				conn := json.decode(structs.Connection, response) or { continue }
				handle_connection(conn.state.@type)
				if conn.state.@type == 'connectionStateReady' && !chats_loaded && bot_token == '' {
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

fn handle_auth(client voidptr, api_id int, api_hash string, bot_token string, state string) {
	match state {
		'authorizationStateWaitTdlibParameters' {
			db_path := if bot_token.len > 0 { 'data/bot_data' } else { 'data/user_data' }
			par := structs.Parameters{
				use_test_dc: false
				database_directory: db_path
				files_directory: db_path + '/files'
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
			if bot_token.len > 0 {
				println('logging in as bot...')
				q := json.encode(BotAuthQuery{
					@type: 'checkAuthenticationBotToken'
					token: bot_token
				})
				tdlib.send_query(client, q)
			} else {
				phone := os.input('phone number: ')
				q := json.encode(PhoneAuthQuery{
					@type: 'setAuthenticationPhoneNumber'
					phone_number: phone
				})
				tdlib.send_query(client, q)
			}
		}
		'authorizationStateWaitCode' {
			code := os.input('auth code: ')
			q := json.encode(CodeAuthQuery{
				@type: 'checkAuthenticationCode'
				code: code
			})
			tdlib.send_query(client, q)
		}
		'authorizationStateWaitPassword' {
			pass := os.input('2fa password: ')
			q := json.encode(PasswordAuthQuery{
				@type: 'checkAuthenticationPassword'
				password: pass
			})
			tdlib.send_query(client, q)
		}
		'authorizationStateReady' {
			println('logged in.')
		}
		'authorizationStateClosed' {
			println('session closed.')
		}
		else {}
	}
}
