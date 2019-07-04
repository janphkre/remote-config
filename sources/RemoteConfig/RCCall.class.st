Class {
	#name : #RCCall,
	#superclass : #ZnRestCall,
	#category : #RemoteConfig
}

{ #category : #accessing }
RCCall class >> basePath [
	^ '/api/', self version
]

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
	^ self basePath, self function 
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
			requestBody: (self requestBodyForMethod: method ) ].
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
	
	body := self requestBody.
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
RCCall class >> summary [
	^ ''
]

{ #category : #versions }
RCCall class >> version [
	^ 'v1'
]

{ #category : #private }
RCCall >> errorEntityFor: anRCError [
	^ ZnEntity 
		with:(NeoJSONWriter toString: anRCError)
		type: ZnMimeType applicationJson setCharSetUTF8
]

{ #category : #private }
RCCall >> errorResponseFor: anError [
  (anError class = KeyNotFound) ifTrue: [ ^ ZnResponse statusLine: ZnStatusLine notFound ].
	^ ZnResponse statusLine: ZnStatusLine internalServerError.
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
	^ (self errorResponseFor: anError) 
		entity: (self errorEntityFor: (RCError instanceFromError: anError))
		yourself
]

{ #category : #initialization }
RCCall >> initializeParameters [
	| operation |
	operation := self class operationForMethod: request method asLowercase.
	operation 
		initializeValuesOn: self
		fromRequest: self
]

{ #category : #'error handling' }
RCCall >> wrongMethod: aRequest [
	^ (ZnResponse statusLine: ZnStatusLine badRequest) 
		entity: (self errorEntityFor: (RCError instanceFromCode: 400 message: 'Unsupported method used.'))
		yourself
]
