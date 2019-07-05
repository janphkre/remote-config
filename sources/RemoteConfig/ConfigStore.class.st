Class {
	#name : #ConfigStore,
	#superclass : #Object,
	#classInstVars : [
		'configurations'
	],
	#category : #RemoteConfig
}

{ #category : #public }
ConfigStore class >> addConfigurationsFor: anIdentifier data: aDict [
	(self configurationsFolder resolveString: (anIdentifier, '.json')) writeStreamDo: [ :aStream |
		 (NeoJSONWriter on: aStream) writeMap: aDict. ].
	self loadConfigurationsFor: anIdentifier data: aDict.
]

{ #category : #public }
ConfigStore class >> configFromIdentifier: anIdentifier languages: languageIdentifiers [
| result |
	languageIdentifiers do: [ :language |
		result := configurations at: anIdentifier at: language ifAbsent: nil.
		result ifNotNil: [ ^ result ].
	].
	^ configurations at: anIdentifier at: 'default'.
]

{ #category : #private }
ConfigStore class >> configurationsFolder [
  ^ 'configurations' asFileReference
]

{ #category : #'class initialization' }
ConfigStore class >> initialize [
	Smalltalk addToStartUpList: self; addToShutDownList: self.
]

{ #category : #private }
ConfigStore class >> loadConfigurationsFor: anIdentifier data: aDict [
  aDict associations do: [ :pair |
				configurations at: anIdentifier at: (pair key) put:
				  (NeoJSONWriter toString: (pair value)) ].
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
	self configurationsFolder allChildren
	  select: [ :each | each basename endsWith: '.json' ]
		thenDo: [ :configFile |
			self loadConfigurationsFor: configFile base data: (((NeoJSONReader on: configFile readStream)) parseMap). ].
]
