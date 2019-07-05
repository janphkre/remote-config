Class {
	#name : #RCConfigCall,
	#superclass : #RCCall,
	#instVars : [
		'configId'
	],
	#category : #RemoteConfig
}

{ #category : #accessing }
RCConfigCall class >> description [ 
	^ 'A configuration is identified by a user set string and the accept language header. When creating new configurations a json must be supplied containing all supported languages. The language "default" should be supplied as the default language.'
]

{ #category : #accessing }
RCConfigCall class >> function [
	^ '/config/{configId}'
]

{ #category : #accessing }
RCConfigCall class >> parameterConfigId [
	<openApiParameter: #( common )>
	^ (self openApiPathParameter: 'configId')
	  description: 'The identifier of the configuration being requested.'
]

{ #category : #accessing }
RCConfigCall class >> summary [ 
	^ 'Resource for getting and setting configurations as a json.'
]

{ #category : #public }
RCConfigCall >> get [
  | data acceptLanguages |
	configId ifNil: [
		KeyNotFound signal.
	].
	acceptLanguages := ($, split: (request headers at: 'Accept-Language' ifAbsent: 'default'))
	  collect: [ :item | ($- split: item) first].
  data := ConfigStore configFromIdentifier: configId languages: acceptLanguages.
	response := ZnResponse  ok: (ZnEntity 
    with: data
    type: ZnMimeType applicationJson setCharSetUTF8).
]

{ #category : #public }
RCConfigCall >> post [
	| data |
	data := self jsonRequest.
	(data includesKey: 'default') ifFalse: [ JSONError signal: 'Missing default configuration.'].
	
	ConfigStore addConfigurationsFor: configId data: data.
	response := ZnResponse ok: (ZnEntity 
    with: '{}'
    type: ZnMimeType applicationJson setCharSetUTF8).
]
