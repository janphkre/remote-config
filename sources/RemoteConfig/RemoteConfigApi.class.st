Class {
	#name : #RemoteConfigApi,
	#superclass : #OpenAPI,
	#classInstVars : [
		'basePath'
	],
	#category : #RemoteConfig
}

{ #category : #options }
RemoteConfigApi class >> delegate: versionString [
	^ (RemoteConfigServerDelegate new
			uriSpace: (RcUriSpace versioned: versionString))
]

{ #category : #accessing }
RemoteConfigApi class >> rootCallClass [
	^ RcCall
]

{ #category : #accessing }
RemoteConfigApi >> openapi [
	 ^ '3.0.2'
]
