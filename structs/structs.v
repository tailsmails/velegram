module structs

pub struct Type {
pub:
	@type string @[default: 'none'; json: '@type']
}

pub struct AuthorizationState {
pub:
	@type string @[json: '@type']
}

pub struct AuthorizationQuery {
pub:
	@type string @[json: '@type']
	authorization_state AuthorizationState
}

pub struct ConnectionState {
pub:
	@type string @[json: '@type']
}

pub struct Connection {
pub:
	@type string @[json: '@type']
	state ConnectionState
}

pub struct FormattedText {
pub:
	text string @[json: 'text']
	entities []Entity @[json: 'entities']
}

pub struct Entity {
pub:
	@type  string @[json: '@type']
	offset int    @[json: 'offset']
	length int    @[json: 'length']
}

pub struct SenderId {
pub:
	@type   string @[json: '@type']
	user_id i64    @[json: 'user_id']
	chat_id i64    @[json: 'chat_id']
}

pub struct MessageContent {
pub:
	@type string         @[json: '@type']
	text  ?FormattedText @[json: 'text']
}

pub struct MessageReplyTo {
pub:
	@type      string @[json: '@type']
	chat_id    i64    @[json: 'chat_id']
	message_id i64    @[json: 'message_id']
}

pub struct Message {
pub:
	@type       string          @[json: '@type']
	id          i64             @[json: 'id']
	chat_id     i64             @[json: 'chat_id']
	sender_id   SenderId        @[json: 'sender_id']
	is_outgoing bool            @[json: 'is_outgoing']
	date        int             @[json: 'date']
	content     MessageContent  @[json: 'content']
	reply_to    ?MessageReplyTo @[json: 'reply_to']
}

pub struct UpdateNewMessage {
pub:
	@type   string  @[json: '@type']
	message Message @[json: 'message']
}

pub struct TextEntityInput {
pub:
	offset      int
	length      int
	entity_type string
	url         string
	language    string
}

pub struct TextMessage {
pub:
	id          i64
	chat_id     i64
	sender_type string
	sender_id   i64
	is_outgoing bool
	date        int
	text        string
	entities    []Entity
	reply_to_id i64
}

@[params]
pub struct Parameters {
pub:
	@type                    string = 'setTdlibParameters' @[json: '@type']
	use_test_dc              bool
	database_directory       string
	files_directory          string
	database_encryption_key  string
	use_file_database        bool
	use_chat_info_database   bool
	use_message_database     bool
	use_secret_chats         bool
	api_id                   int
	api_hash                 string
	system_language_code     string
	device_model             string
	system_version           string
	application_version      string
	enable_storage_optimizer bool
	ignore_file_names        bool
}

pub struct MessageThreadInfo {
pub:
	@type             string @[json: '@type']
	chat_id           i64    @[json: 'chat_id']
	message_thread_id i64    @[json: 'message_thread_id']
}

pub struct ForumTopic {
pub:
	@type             string @[json: '@type']
	message_thread_id i64    @[json: 'message_thread_id']
	name              string @[json: 'name']
	is_closed         bool   @[json: 'is_closed']
	is_pinned         bool   @[json: 'is_pinned']
}

pub struct ForumTopicsResponse {
pub:
	@type  string       @[json: '@type']
	topics []ForumTopic @[json: 'topics']
}

pub struct ChatMemberStatus {
pub:
	@type string @[json: '@type']
}

pub struct ChatMemberId {
pub:
	@type   string @[json: '@type']
	user_id i64    @[json: 'user_id']
}

pub struct ChatMember {
pub:
	@type     string           @[json: '@type']
	member_id ChatMemberId     @[json: 'member_id']
	status    ChatMemberStatus @[json: 'status']
}

pub struct ChatMembersResponse {
pub:
	@type        string       @[json: '@type']
	total_count  int          @[json: 'total_count']
	members      []ChatMember @[json: 'members']
}

pub struct UserInfo {
pub:
	@type        string @[json: '@type']
	id           i64    @[json: 'id']
	first_name   string @[json: 'first_name']
	last_name    string @[json: 'last_name']
	username     string @[json: 'usernames']
	phone_number string @[json: 'phone_number']
	is_premium   bool   @[json: 'is_premium']
}

pub struct SupergroupInfo {
pub:
	@type        string @[json: '@type']
	id           i64    @[json: 'id']
	username     string @[json: 'usernames']
	member_count int    @[json: 'member_count']
	is_channel   bool   @[json: 'is_channel']
	is_forum     bool   @[json: 'is_forum']
}

pub struct MessagesResponse {
pub:
	@type       string    @[json: '@type']
	total_count int       @[json: 'total_count']
	messages    []Message @[json: 'messages']
}

pub struct ChatInfo {
pub:
	@type string @[json: '@type']
	id    i64    @[json: 'id']
	title string @[json: 'title']
}

pub struct MessageLinkResponse {
pub:
	@type string @[json: '@type']
	link  string @[json: 'link']
}