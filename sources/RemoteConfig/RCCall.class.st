Class {
	#name : #RCCall,
	#superclass : #ZnRestCall,
	#classInstVars : [
		'basePath'
	],
	#category : #RemoteConfig
}

{ #category : #accessing }
RCCall class >> description [
	^ ''
]

{ #category : #accessing }
RCCall class >> function [
	^ self subclassResponsibility 
]

{ #category : #accessing }
RCCall class >> httpMethods [
	^ #( get )
]

{ #category : #public }
RCCall class >> implementedMethods [
	^ self httpMethods select: [ :method | self includesSelector: method asSymbol ]
]

{ #category : #testing }
RCCall class >> isAbstract [ 
 ^ self = RCCall
]

{ #category : #public }
RCCall class >> match: request [
	| callPath requestPath |
	requestPath := $/ split: request uri path.
	callPath := $/ split: self path allButFirst.
	(requestPath size = callPath size) ifFalse: [ 
		^ false ].
	requestPath with: callPath do: [ :requestPathSegment : callPathSegment |
		(callPathSegment first = ${)
			ifFalse: [ 
				(callPathSegment  = requestPathSegment )
					ifFalse: [ ^ false ] ] ].
	^ true
]

{ #category : #accessing }
RCCall class >> objectsForPragmas: aCollection [
	^ aCollection
		collect: [:each | each method valueWithReceiver: self arguments: #() ]
]

{ #category : #accessing }
RCCall class >> openApiPragmasNamed: aSymbol [
	^ Pragma 
		allNamed: aSymbol
		from: self class 
		to: RCCall class.
]

{ #category : #accessing }
RCCall class >> operationForMethod: aString [ 
	^ self pathItem perform: aString asSymbol.
]

{ #category : #accessing }
RCCall class >> parametersForMethod: aSymbol [
	^ self objectsForPragmas: ( self pragmas: #openApiParameter: includingMethod: aSymbol )
]

{ #category : #accessing }
RCCall class >> path [ 
	^ (RemoteConfigApi basePath), self function 
]

{ #category : #accessing }
RCCall class >> pathItem [
	| item |
	item := OAPathItem new.
	self implementedMethods do: [ :method |
		(item operationAt: method)
			summary: self summary;
			description: self description;
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
RCCall class >> requestBody [
	^ OARequestBody new
]

{ #category : #accessing }
RCCall class >> requestBodyForMethod: aSymbol [

	| body pragmas |
	pragmas := (self pragmas: #openApiRequestBody:contentType: includingMethod: aSymbol)
		ifEmpty: [ ^ nil ].
	
	body := OARequestBody new.
	pragmas do: [ :pragma | | mediaObject |
		mediaObject := pragma method valueWithReceiver: self arguments: #().
		pragma arguments second do: [ :contentType | 
			body
				contentAt: contentType 
				put: mediaObject ] ].
	^ body
]

{ #category : #public }
RCCall class >> responseError [
	<openApiResponse: #(get) status: #(500) contentType: #('application/json')>
	^ OAMediaTypeObject new
		schema: (RCError instanceVariables) asJSONSchema.
]

{ #category : #public }
RCCall class >> responseOk [
	<openApiResponse: #(get) status: #(200) contentType: #('application/json')>
	^ OAMediaTypeObject new
		schema: { } asJSONSchema.
]

{ #category : #accessing }
RCCall class >> responsesForMethod: aSymbol [
	| body pragmas |
	pragmas := (self pragmas: #openApiResponse:status:contentType: includingMethod: aSymbol)
		ifEmpty: [ ^ nil ].
	
	body := ZnResponse new.
	pragmas do: [ :pragma | | mediaObject |
		pragma arguments second do: [ :statusCode | 
			body statusLine: (ZnStatusLine code: statusCode) ].
		mediaObject := pragma method valueWithReceiver: self arguments: #().
		pragma arguments third do: [ :contentType | 
			body entity: (ZnEntity with: mediaObject type: contentType) ] ].
	^ body
]

{ #category : #accessing }
RCCall class >> summary [
	^ ''
]

{ #category : #private }
RCCall >> errorEntityFor: anRCError [
	^ ZnEntity 
		with:(NeoJSONWriter toString: anRCError)
		type: ZnMimeType applicationJson setCharSetUTF8
]

{ #category : #private }
RCCall >> errorResponseFor: aRCError [
	^ ZnResponse statusLine: (ZnStatusLine code: (aRCError code)).
]

{ #category : #accessing }
RCCall >> execute [
	"execution of the api call"
	^ (self respondsTo: self method)	
		ifTrue: [ 
			[ 
			self initializeParameters.
			self perform: self method.
			response]
				on: Exception 
				do: [ :err | self handleError: err ] ] 
		ifFalse: [ self wrongMethod: request ]
]

{ #category : #accessing }
RCCall >> handleError: anError [
 | mappedError |
	mappedError := (RCError instanceFromError: anError).
	^ (self errorResponseFor: mappedError) 
		entity: (self errorEntityFor: mappedError)
		yourself
]

{ #category : #initialization }
RCCall >> initializeParameters [
	| operation |
	self flag: 'TODO: MAKE THIS MORE EFFICIENT: PARAMETER LOAD SHOULD NOT REQUIRE OPEANAPI INFLATION'.
	operation := self class operationForMethod: request method asLowercase.
	operation 
		initializeValuesOn: self
		fromRequest: self
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
	^ (ZnResponse statusLine: ZnStatusLine badRequest) 
		entity: (self errorEntityFor: (RCError instanceFromCode: 400 message: 'Unsupported method used.'))
		yourself
]
