Class {
	#name : #RcConfigCall,
	#superclass : #RcCall,
	#traits : 'CdTokenAuthTrait',
	#classTraits : 'CdTokenAuthTrait classTrait',
	#instVars : [
		'configId'
	],
	#category : #RemoteConfig
}

{ #category : #accessing }
RcConfigCall class >> descriptionGet [
	^ 'A configuration is identified by a user set string and the accept language header. When no language is specified or the specified language is not found, the default language is returned.'
]

{ #category : #accessing }
RcConfigCall class >> descriptionPost [
	^ 'A configuration is identified by a user set string and the accept language header. When creating new configurations a json must be supplied containing all supported languages. The language "default" should be supplied as the default language. All other languages should be added to the object as a two character specifier e.g. "en":{...},"de":{...}'
]

{ #category : #accessing }
RcConfigCall class >> function [
	^ { 'config' . '{configId}' }
]

{ #category : #accessing }
RcConfigCall class >> parameterConfigId [
	<openApiParameter: #( common )>
	^ (self openApiPathParameter: 'configId')
	  description: 'The identifier of the configuration being requested.'
]

{ #category : #accessing }
RcConfigCall class >> requestPost [
	<openApiRequestBody: #( post ) contentType: #( 'application/json' )>
	^ OAMediaTypeObject new
		schema: { 
			#default -> JSONSchemaAnyObject new. } asJSONSchema
]

{ #category : #accessing }
RcConfigCall class >> summaryGet [
	^ 'Get configurations as a json.'
]

{ #category : #accessing }
RcConfigCall class >> summaryPost [
	^ 'Create and change configurations as a json.'
]

{ #category : #public }
RcConfigCall >> get [
  | data acceptLanguages |
	configId ifNil: [ KeyNotFound signal ].
	acceptLanguages := ($, split: (request headers at: 'Accept-Language' ifAbsent: 'default'))
	  collect: [ :item | ($- split: item) first].
  data := RcConfigStore configFromIdentifier: configId languages: acceptLanguages.
	response := ZnResponse  ok: (ZnEntity 
    with: data
    type: ZnMimeType applicationJson setCharSetUTF8).
]

{ #category : #public }
RcConfigCall >> post [
	| data |
	data := self jsonRequest.
	(data includesKey: 'default') ifFalse: [ JSONError signal: 'Missing default configuration.'].
	
	RcConfigStore addConfigurationsFor: configId data: data.
	response := ZnResponse ok: (ZnEntity 
    with: '{}'
    type: ZnMimeType applicationJson setCharSetUTF8).
]
