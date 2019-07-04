Class {
	#name : #ConfigStore,
	#superclass : #Object,
	#classInstVars : [
		'configurations'
	],
	#category : #RemoteConfig
}

{ #category : #'class initialization' }
ConfigStore class >> initialize [
	Smalltalk addToStartUpList: self; addToShutDownList: self.
]

{ #category : #'instance creation' }
ConfigStore class >> instanceFromIdentifier: anIdentifier [
	^ configurations at: anIdentifier.
]

{ #category : #'system startup' }
ConfigStore class >> shutDown: quitting [
	quitting ifFalse: [ ^ self ].
	configurations := nil.
]

{ #category : #'system startup' }
ConfigStore class >> startUp: isImageStarting [
	isImageStarting ifFalse: [ ^ self ].
	configurations := Dictionary new.
	'configurations' asFileReference allChildren
	  select: [ :each | each basename endsWith: '.json' ]
		thenDo: [ :item |
			configurations at: item base asSymbol put: item readStream upToEnd ].
]
