Class {
	#name : #RCCall,
	#superclass : #ZnRestCall,
	#traits : 'CdRejectingAuthTrait + CdTokenStoreTrait',
	#classTraits : 'CdRejectingAuthTrait classTrait + CdTokenStoreTrait classTrait',
	#classInstVars : [
		'basePath'
	],
	#category : #RemoteConfig
}

{ #category : #accessing }
RCCall class >> description: aSymbol [
^ self perform: (#description, aSymbol)
]

{ #category : #public }
RCCall class >> forRequest: request [
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
RCCall class >> function [
	^ self subclassResponsibility 
]

{ #category : #accessing }
RCCall class >> implementedMethods [
	^ self usedHttpVerbs select: [ :method | self includesSelector: method asSymbol ]
]

{ #category : #testing }
RCCall class >> isAbstract [ 
 ^ self = RCCall
]

{ #category : #'instance creation' }
RCCall class >> new: aDict [
	| result |
	result := self new.
	aDict associations do: [ :pair |
		result instVarNamed: (pair key) put: (pair value)].
	^ result.
]

{ #category : #accessing }
RCCall class >> objectsForPragmas: aCollection [
	^ aCollection
		collect: [:each | each method valueWithReceiver: self arguments: #() ]
]

{ #category : #public }
RCCall class >> openApiPathParameter: aString [
^ OAParameter new
		name: aString;
		in: #path;
		beString;
		required: true.
		
]

{ #category : #accessing }
RCCall class >> openApiPragmasNamed: aSymbol [
	^ Pragma 
		allNamed: aSymbol
		from: self class 
		to: RCCall class.
]

{ #category : #accessing }
RCCall class >> parametersForMethod: aSymbol [
	^ self objectsForPragmas: ( self pragmas: #openApiParameter: includingMethod: aSymbol )
]

{ #category : #accessing }
RCCall class >> path [
	^ String
		streamContents: [ :s | 
			s nextPut: $/.
			RemoteConfigApi basePath asStringOn: s delimiter: '/'.
			s nextPut: $/.
			self function asStringOn: s delimiter: '/' ]
]

{ #category : #accessing }
RCCall class >> pathItem [
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
RCCall class >> pragmas: pragmaName includingMethod: aSymbol [
	^ (self openApiPragmasNamed: pragmaName) 
		select: [ :each | 
			each arguments first includesAny: { aSymbol . #common } ]
]

{ #category : #accessing }
RCCall class >> requestBodyForMethod: aSymbol [

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
RCCall class >> summary: aSymbol [
^ self perform: (#summary, aSymbol)
]

{ #category : #private }
RCCall class >> usedHttpVerbs [
	^ #( #get #post )
]

{ #category : #accessing }
RCCall >> execute [
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
RCCall >> handleError: anError [
	anError inspect.
	^ delegate errorResponse: nil code: (anError znErrorCode) message: (anError znErrorMessage).
]

{ #category : #accessing }
RCCall >> jsonRequest [
	^ (self request contentType matches: ZnMimeType applicationJson)
		ifTrue: [
			NeoJSONReader fromString: self request contents ]
		ifFalse: [
			JSONError signal: 'JSON content expected.' ]
]

{ #category : #'error handling' }
RCCall >> wrongMethod: aRequest [
	^ delegate errorResponse: aRequest code: 400 message: 'Unsupported method used.'
]
