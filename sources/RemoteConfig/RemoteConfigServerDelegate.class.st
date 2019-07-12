Class {
	#name : #RemoteConfigServerDelegate,
	#superclass : #ZnJSONRestServerDelegate,
	#category : #RemoteConfig
}

{ #category : #'error handling' }
RemoteConfigServerDelegate >> errorResponse: request code: code message: message [
	^ (ZnResponse statusLine: (ZnStatusLine code: code))
	entity: (ZnEntity 
		with: (NeoJSONWriter toString: (Dictionary new
		  at: #code put: code;
		  at: #message put: message;
		  yourself))
		type: ZnMimeType applicationJson setCharSetUTF8).
]
