Class {
	#name : #RcSpecCall,
	#superclass : #RcCall,
	#traits : 'CdWildcardAuthTrait',
	#classTraits : 'CdWildcardAuthTrait classTrait',
	#category : #RemoteConfig
}

{ #category : #accessing }
RcSpecCall class >> descriptionGet [
	^ 'A call to get the OpenAPI specification for this server.'
]

{ #category : #accessing }
RcSpecCall class >> function [ 
	^ { 'spec' }
]

{ #category : #accessing }
RcSpecCall class >> summaryGet [
	^ 'Get OpenAPI specification.'
]

{ #category : #public }
RcSpecCall >> get [
	response := ZnResponse ok:(
		ZnEntity 
			with: RemoteConfigApi new specString 
			type: ZnMimeType applicationJson setCharSetUTF8)
]
