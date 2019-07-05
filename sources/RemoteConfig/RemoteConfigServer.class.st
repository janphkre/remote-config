Class {
	#name : #RemoteConfigServer,
	#superclass : #OpenAPI,
	#instVars : [
		'serverDelegate',
		'server'
	],
	#category : #RemoteConfig
}

{ #category : #accessing }
RemoteConfigServer >> start: port [
	
	RemoteConfigApi version: 'v1'.
	serverDelegate := RemoteConfigApi delegate.
	
	server := ZnSingleThreadedServer startDefaultOn: port.
	server debugMode: true.
	server delegate: serverDelegate.
]

{ #category : #accessing }
RemoteConfigServer >> stop [
  server ifNil: [ ^ self ].
  server stop.
  server := nil.
  serverDelegate := nil.
	
]
