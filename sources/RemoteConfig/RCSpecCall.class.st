Class {
	#name : #RCSpecCall,
	#superclass : #RCCall,
	#category : #RemoteConfig
}

{ #category : #accessing }
RCSpecCall class >> function [ 
	^ '/spec'
]

{ #category : #accessing }
RCSpecCall class >> summary [
	^ 'A call to get the OpenAPI specification for this server.'
]

{ #category : #public }
RCSpecCall >> get [
	response := ZnResponse ok:(
		ZnEntity 
			with: RemoteConfigApi new specString 
			type: ZnMimeType applicationJson setCharSetUTF8)
]
