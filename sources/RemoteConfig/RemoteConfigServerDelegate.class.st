Class {
	#name : #RemoteConfigServerDelegate,
	#superclass : #ZnJSONRestServerDelegate,
	#category : #RemoteConfig
}

{ #category : #'error handling' }
RemoteConfigServerDelegate >> errorResponse: request code: code message: message [
	| statusLine data |
	statusLine := ZnStatusLine code: code.
	data := RCError instanceFromCode: code message: message.
	^ ZnResponse new
		statusLine: statusLine;
		headers: ZnHeaders defaultResponseHeaders;
		entity: (ZnEntity with: (self toJson: data) type: ZnMimeType applicationJson);
		yourself
]
