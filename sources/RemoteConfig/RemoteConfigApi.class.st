Class {
	#name : #RemoteConfigApi,
	#superclass : #OpenAPI,
	#category : #RemoteConfig
}

{ #category : #options }
RemoteConfigApi class >> delegate [
	^ (RemoteConfigServerDelegate new
			uriSpace: (RCUriSpace new))
]

{ #category : #accessing }
RemoteConfigApi class >> rootCallClass [
	^ RCCall
]

{ #category : #accessing }
RemoteConfigApi >> openapi [
	 ^ '3.0.2'
]
