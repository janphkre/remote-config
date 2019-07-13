Class {
	#name : #RcUriSpace,
	#superclass : #ZnRestUriSpace,
	#instVars : [
		'basePath'
	],
	#category : #RemoteConfig
}

{ #category : #'instance creation' }
RcUriSpace class >> versioned: versionString [
	^ (self new) version: versionString; yourself.
]

{ #category : #accessing }
RcUriSpace >> basePath [
	^ basePath
]

{ #category : #public }
RcUriSpace >> match: request [
	|requestSegments baseSegments |
	requestSegments := request uri segments.
	baseSegments := self basePath.
	baseSegments withIndexDo: [ :baseSegment :index | 
		(baseSegment = (requestSegments at: index)) ifFalse: [ ^ nil ] ].
	
	requestSegments removeFirst: (baseSegments size).
	request uri segments: requestSegments.
	
	(RcCall allSubclasses reject: #isAbstract)
		do: [ :callClass |
			(callClass forRequest: request) ifNotNil: [ :item |
				^ item ] ].
	^ nil
]

{ #category : #versions }
RcUriSpace >> version: aString [
	basePath :=  { 'api'. aString }
]
