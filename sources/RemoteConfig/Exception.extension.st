Extension { #name : #Exception }

{ #category : #'*RemoteConfig' }
Exception >> znErrorCode [
	^ 500
]

{ #category : #'*RemoteConfig' }
Exception >> znErrorMessage [ 
	^ 'An unknown error occured.'
]
