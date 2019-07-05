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
	^ 'Return the configuration for a specific identifier. The configuration is a json.'
]

{ #category : #accessing }
RCConfigCall class >> function [
	^ '/config/{configId}'
]

{ #category : #accessing }
RCConfigCall class >> httpMethods [
	^ #( post )
]

{ #category : #accessing }
RCConfigCall class >> parameterConfigId [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'configId';
		in: #path;
		beString;
		required: true;
		description: 'The identifier of the configuration being requested.'
]

{ #category : #'accessing-testing' }
RCConfigCall >> configId: aString. [
  configId := aString.
]

{ #category : #public }
RCConfigCall >> get [
  | data acceptLanguages |
	configId ifNil: [
		KeyNotFound signal.
	].
	acceptLanguages := ($, split: (request headers at: 'Accept-Language' ifAbsent: 'en'))
	  collect: [ :item | ($- split: item) first].
  data := ConfigStore instanceFromIdentifier: configId languages: acceptLanguages.
	response := ZnResponse  ok: (ZnEntity 
    with: data
    type: ZnMimeType applicationJson setCharSetUTF8).
]
