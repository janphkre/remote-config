Extension { #name : #KeyNotFound }

{ #category : #'*RemoteConfig' }
KeyNotFound >> znErrorCode [
	^ 404
]

{ #category : #'*RemoteConfig' }
KeyNotFound >> znErrorMessage [
	^ 'The requested object was not found.'
]
