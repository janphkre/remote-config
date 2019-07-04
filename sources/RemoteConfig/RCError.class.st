Class {
	#name : #RCError,
	#superclass : #Object,
	#instVars : [
		'code',
		'message'
	],
	#category : #RemoteConfig
}

{ #category : #'instance creation' }
RCError class >> instanceFromCode: anInteger message: aString [
	^ self new code: anInteger; message: aString; yourself.
]

{ #category : #'instance creation' }
RCError class >> instanceFromError: anError [
  self flag: 'TODO Find way to log / monitor errors'.
  anError inspect.
  anError class = KeyNotFound ifTrue: [ ^  self instanceFromCode: 404 message: 'The requested object was not found.' ].
  ^ self instanceFromCode: 500 message: 'An unknown error occured.'
]

{ #category : #accessing }
RCError class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: (RCError instanceVariables) ]

]

{ #category : #accessing }
RCError >> code [ 
	^ code
]

{ #category : #accessing }
RCError >> code: anInteger [ 
	code := anInteger
]

{ #category : #accessing }
RCError >> message [ 
	^ message
]

{ #category : #accessing }
RCError >> message: aString [
	message := aString.
]
