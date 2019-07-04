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
	
	serverDelegate := RemoteConfigApi delegate.
	
	server := ZnSingleThreadedServer startDefaultOn: port.
	server debugMode: true.
	server delegate: serverDelegate.
]
