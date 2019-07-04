Class {
	#name : #RCUriSpace,
	#superclass : #ZnRestUriSpace,
	#category : #RemoteConfig
}

{ #category : #public }
RCUriSpace >> match: request [
	(RCCall allSubclasses reject: #isAbstract)
		do: [ :callClass |
			(callClass match: request) ifTrue: [ 
				^ callClass new ] ].
	^ nil
]
