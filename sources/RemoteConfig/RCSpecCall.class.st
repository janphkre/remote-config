Class {
	#name : #RCSpecCall,
	#superclass : #RCCall,
	#category : #RemoteConfig
}

{ #category : #accessing }
RCSpecCall class >> descriptionGet [
	^ 'A call to get the OpenAPI specification for this server.'
]

{ #category : #accessing }
RCSpecCall class >> function [ 
	^ '/spec'
]

{ #category : #accessing }
RCSpecCall class >> summaryGet [
	^ 'Get OpenAPI specification.'
]

{ #category : #public }
RCSpecCall >> get [
	response := ZnResponse ok:(
		ZnEntity 
			with: RemoteConfigApi new specString 
			type: ZnMimeType applicationJson setCharSetUTF8)
]
