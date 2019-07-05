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
ConfigStore class >> instanceFromIdentifier: anIdentifier languages: languageIdentifiers [
| result |
	languageIdentifiers do: [ :language |
		result := configurations at: anIdentifier at: language ifAbsent: nil.
		result ifNotNil: [ ^ result ].
	].
	^ configurations at: anIdentifier at: #en.
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
		thenDo: [ :configFile |
			(((NeoJSONReader on: (configFile readStream))) parseMap) associations do: [ :pair |
				configurations at: configFile base asSymbol at: (pair key) put:
				  (NeoJSONWriter toString: (pair value)) ].
			].
]
