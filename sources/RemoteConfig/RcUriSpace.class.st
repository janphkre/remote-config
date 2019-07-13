Class {
	#name : #RcUriSpace,
	#superclass : #ZnRestUriSpace,
	#category : #RemoteConfig
}

{ #category : #public }
RcUriSpace >> match: request [
	|requestSegments baseSegments |
	requestSegments := request uri segments.
	baseSegments := RemoteConfigApi basePath.
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
