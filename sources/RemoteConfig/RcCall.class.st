Class {
	#name : #RcCall,
	#superclass : #ZnRestCall,
	#traits : 'CdRejectingAuthTrait + CdTokenStoreTrait',
	#classTraits : 'CdRejectingAuthTrait classTrait + CdTokenStoreTrait classTrait',
	#classInstVars : [
		'basePath'
	],
	#category : #RemoteConfig
}

{ #category : #accessing }
RcCall class >> description: aSymbol [
^ self perform: (#description, aSymbol)
]

{ #category : #public }
RcCall class >> forRequest: request [
	| callPath requestPath parameters |
	requestPath := request uri segments.
	callPath := self function.
	(requestPath size = callPath size) ifFalse: [ 
		^ nil ].
	parameters := Dictionary new.
	requestPath with: callPath do: [ :requestPathSegment : callPathSegment |
		(callPathSegment first = ${)
			ifFalse: [ 
				(callPathSegment  = requestPathSegment )
					ifFalse: [ ^ nil ] ]
			ifTrue: [ parameters at: (callPathSegment copyFrom: 2 to: callPathSegment size - 1) put: requestPathSegment ] ].
	^ self new: parameters.
]

{ #category : #accessing }
RcCall class >> function [
	^ self subclassResponsibility 
]

{ #category : #accessing }
RcCall class >> implementedMethods [
	^ self usedHttpVerbs select: [ :method | self includesSelector: method asSymbol ]
]

{ #category : #testing }
RcCall class >> isAbstract [ 
 ^ self = RcCall
]

{ #category : #'instance creation' }
RcCall class >> new: aDict [
	| result |
	result := self new.
	aDict associations do: [ :pair |
		result instVarNamed: (pair key) put: (pair value)].
	^ result.
]

{ #category : #accessing }
RcCall class >> objectsForPragmas: aCollection [
	^ aCollection
		collect: [:each | each method valueWithReceiver: self arguments: #() ]
]

{ #category : #public }
RcCall class >> openApiPathParameter: aString [
^ OAParameter new
		name: aString;
		in: #path;
		beString;
		required: true.
		
]

{ #category : #accessing }
RcCall class >> openApiPragmasNamed: aSymbol [
	^ Pragma 
		allNamed: aSymbol
		from: self class 
		to: RcCall class.
]

{ #category : #accessing }
RcCall class >> parametersForMethod: aSymbol [
	^ self objectsForPragmas: ( self pragmas: #openApiParameter: includingMethod: aSymbol )
]

{ #category : #accessing }
RcCall class >> path [
	^ String
		streamContents: [ :s | 
			s nextPut: $/.
			RemoteConfigApi basePath asStringOn: s delimiter: '/'.
			s nextPut: $/.
			self function asStringOn: s delimiter: '/' ]
]

{ #category : #accessing }
RcCall class >> pathItem [
	| item |
	item := OAPathItem new.
	self implementedMethods do: [ :method | | capitalizedMethod |
		capitalizedMethod := method capitalized.
		(item operationAt: method)
			summary: (self summary: capitalizedMethod);
			description: (self description: capitalizedMethod);
			parameters: (self parametersForMethod: method);
			requestBody: (self requestBodyForMethod: method) ].
	^ item

]

{ #category : #accessing }
RcCall class >> pragmas: pragmaName includingMethod: aSymbol [
	^ (self openApiPragmasNamed: pragmaName) 
		select: [ :each | 
			each arguments first includesAny: { aSymbol . #common } ]
]

{ #category : #accessing }
RcCall class >> requestBodyForMethod: aSymbol [

	| body pragmas |
	pragmas := (self pragmas: #openApiRequestBody:contentType: includingMethod: aSymbol)
		ifEmpty: [ ^ nil ].
	
	body := OARequestBody new.
	body required: true.
	pragmas do: [ :pragma | | mediaObject |
		mediaObject := pragma method valueWithReceiver: self arguments: #().
		pragma arguments second do: [ :contentType | 
			body
				contentAt: contentType 
				put: mediaObject ] ].
	^ body
]

{ #category : #accessing }
RcCall class >> summary: aSymbol [
^ self perform: (#summary, aSymbol)
]

{ #category : #acccessing }
RcCall class >> tokenDelegate [
	^ CdTokenStore default.
]

{ #category : #private }
RcCall class >> usedHttpVerbs [
	^ #( #get #post )
]

{ #category : #accessing }
RcCall >> execute [
	"execution of the api call"
	^ [ self authorize: request.
		(self respondsTo: self method)	
		ifTrue: [ 
			self perform: self method.
			response ] 
		ifFalse: [ self wrongMethod: request ]
		] on: Exception 
		do: [ :err | self handleError: err ]
]

{ #category : #'error handling' }
RcCall >> handleError: anError [
	anError inspect.
	^ delegate errorResponse: nil code: (anError znErrorCode) message: (anError znErrorMessage).
]

{ #category : #accessing }
RcCall >> jsonRequest [
	^ (self request contentType matches: ZnMimeType applicationJson)
		ifTrue: [
			NeoJSONReader fromString: self request contents ]
		ifFalse: [
			JSONError signal: 'JSON content expected.' ]
]

{ #category : #'error handling' }
RcCall >> wrongMethod: aRequest [
	^ delegate errorResponse: aRequest code: 400 message: 'Unsupported method used.'
]
