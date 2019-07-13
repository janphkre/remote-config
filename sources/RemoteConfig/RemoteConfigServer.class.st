Class {
	#name : #RemoteConfigServer,
	#superclass : #Object,
	#instVars : [
		'serverDelegate',
		'server',
		'versionString'
	],
	#category : #RemoteConfig
}

{ #category : #'instance creation' }
RemoteConfigServer class >> versioned: versionString [
	^ (self new) version: versionString; yourself.
]

{ #category : #public }
RemoteConfigServer >> loadTokens [
	| tokenMap |
		tokenMap := NeoJSONReader on: (self tokensFile readStream) parseMap.
		tokenMap associations do: [ :pair | CdTokenStore default for: (pair key) grant: (CdAccess from: (pair value))].
	
]

{ #category : #accessing }
RemoteConfigServer >> localUrl [
	^ server localUrl
]

{ #category : #public }
RemoteConfigServer >> start: port [
	
	serverDelegate := RemoteConfigApi delegate: versionString.
	
	server := ZnMultiThreadedServer  startDefaultOn: port.
	server debugMode: true.
	server delegate: serverDelegate.
]

{ #category : #public }
RemoteConfigServer >> stop [
  server ifNil: [ ^ self ].
  server stop.
  server := nil.
  serverDelegate := nil.
	
]

{ #category : #public }
RemoteConfigServer >> storeTokens [
	| tokenDictionary |
	tokenDictionary := (CdTokenStore default permissions) collect: [ :permissions | 
		permissions collect: [ :permission | permission to: Dictionary new ]].
	self tokensFile writeStreamDo: [ :aStream |
		 (NeoJSONWriter on: aStream) prettyPrint: true; writeMap: tokenDictionary ].
]

{ #category : #private }
RemoteConfigServer >> tokensFile [
	^ 'data/authorization/tokens.json' asFileReference
]

{ #category : #versions }
RemoteConfigServer >> version [
	^ versionString.
]

{ #category : #versions }
RemoteConfigServer >> version: aString [
	versionString := aString.
]
