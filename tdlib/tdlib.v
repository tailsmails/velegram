module tdlib
import structs
import json

#flag -ltdjson
#flag -ltdjson_static
#flag -ltdclient
#flag -ltdcore
#flag -ltdapi
#include <td/telegram/td_json_client.h>

fn C.td_json_client_create() voidptr
fn C.td_json_client_destroy(client voidptr)
fn C.td_json_client_send(client voidptr, query &char)
fn C.td_json_client_receive(client voidptr, timeout f64) &char

pub fn new_client() !voidptr {
	client := C.td_json_client_create()
	if !isnil(client) {
		return client
	}
	return error('creating client failed')
}

pub fn send_query(client voidptr, query string) {
	C.td_json_client_send(client, query.str)
}

pub fn receive(client voidptr, timeout f64) string {
	res := C.td_json_client_receive(client, timeout)
	if !isnil(res) {
		result := unsafe { res.vstring() }
		return result
	}
	typ := structs.Type {
		@type: 'empty'
	}
	return json.encode(typ)
}

pub fn client_destroy(client voidptr) {
	C.td_json_client_destroy(client)
}
