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
RCConfigCall class >> parameterConfigId [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'configId';
		in: #path;
		beString;
		required: true;
		description: 'The identifier of the configuration being requested.'
]

{ #category : #public }
RCConfigCall >> get [
  | data |
	configId ifNil: [
		KeyNotFound signal.
	].
  data := ConfigStore instanceFromIdentifier: (configId asSymbol).
	response := ZnResponse  ok: (ZnEntity 
    with: data
    type: ZnMimeType applicationJson setCharSetUTF8).
	^ self.
]
