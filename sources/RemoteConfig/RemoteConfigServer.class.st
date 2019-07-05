Class {
	#name : #RemoteConfigServer,
	#superclass : #Object,
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
	
	server := ZnMultiThreadedServer  startDefaultOn: port.
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
