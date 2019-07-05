Class {
	#name : #RemoteConfigApi,
	#superclass : #OpenAPI,
	#classInstVars : [
		'basePath'
	],
	#category : #RemoteConfig
}

{ #category : #accessing }
RemoteConfigApi class >> basePath [
	^ basePath
]

{ #category : #options }
RemoteConfigApi class >> delegate [
	^ (RemoteConfigServerDelegate new
			uriSpace: (RCUriSpace new))
]

{ #category : #accessing }
RemoteConfigApi class >> rootCallClass [
	^ RCCall
]

{ #category : #versions }
RemoteConfigApi class >> version: aString [
	basePath := '/api/', aString
]

{ #category : #accessing }
RemoteConfigApi >> openapi [
	 ^ '3.0.2'
]
