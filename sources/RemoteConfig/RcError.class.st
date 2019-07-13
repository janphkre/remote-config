Class {
	#name : #RcError,
	#superclass : #Object,
	#instVars : [
		'code',
		'message'
	],
	#category : #RemoteConfig
}

{ #category : #'instance creation' }
RcError class >> instanceFromCode: anInteger message: aString [
	^ self new code: anInteger; message: aString; yourself.
]

{ #category : #'instance creation' }
RcError class >> instanceFromError: anError [
  self flag: 'TODO Find way to log / monitor errors'.
  anError inspect.
  anError class = KeyNotFound ifTrue: [ ^  self instanceFromCode: 404 message: 'The requested object was not found.' ].
  anError class = JSONError ifTrue: [ ^ self instanceFromCode: 400 message: (anError messageText) ].
  ^ self instanceFromCode: 500 message: 'An unknown error occured.'
]

{ #category : #accessing }
RcError class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: (RcError instanceVariables) ]

]

{ #category : #accessing }
RcError >> code [ 
	^ code
]

{ #category : #accessing }
RcError >> code: anInteger [ 
	code := anInteger
]

{ #category : #accessing }
RcError >> message [ 
	^ message
]

{ #category : #accessing }
RcError >> message: aString [
	message := aString.
]
