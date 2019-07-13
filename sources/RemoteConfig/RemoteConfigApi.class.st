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
			uriSpace: (RcUriSpace new))
]

{ #category : #accessing }
RemoteConfigApi class >> rootCallClass [
	^ RcCall
]

{ #category : #versions }
RemoteConfigApi class >> version: aString [
	basePath :=  { 'api'. aString }
]

{ #category : #accessing }
RemoteConfigApi >> openapi [
	 ^ '3.0.2'
]
