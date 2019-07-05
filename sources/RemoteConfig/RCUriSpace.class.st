Class {
	#name : #RCUriSpace,
	#superclass : #ZnRestUriSpace,
	#category : #RemoteConfig
}

{ #category : #public }
RCUriSpace >> match: request [
	(RCCall allSubclasses reject: #isAbstract)
		do: [ :callClass |
			(callClass forRequest: request) ifNotNil: [ :item |
				^ item ] ].
	^ nil
]
