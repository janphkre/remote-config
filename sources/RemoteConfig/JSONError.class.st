Class {
	#name : #JSONError,
	#superclass : #Error,
	#category : #RemoteConfig
}

{ #category : #accessing }
JSONError >> znErrorCode [
	^ 400
]

{ #category : #accessing }
JSONError >> znErrorMessage [ 
	^ self messageText
]
