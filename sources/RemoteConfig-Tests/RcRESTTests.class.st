Class {
	#name : #RcRESTTests,
	#superclass : #TestCase,
	#instVars : [
		'server',
		'client',
		'result'
	],
	#category : #'RemoteConfig-Tests'
}

{ #category : #running }
RcRESTTests >> setUp [
	super setUp.
	server := RemoteConfigServer versioned: 'vTest'.
	server start: 1800 + 10 atRandom.
	client := ZnClient new
		url: server localUrl;
		yourself.
	client request url addPathSegments: #( api #vTest ).
	
	RcConfigStore startUp: true.
]

{ #category : #running }
RcRESTTests >> tearDown [
	client close.
	server stop
]

{ #category : #tests }
RcRESTTests >> testGetConfigCall [
	| data |
	data := Dictionary new
		at: 'xyz' put: 'test-xyz';
		at: 'default' put: 'test-default';
		yourself.
		
	RcConfigStore addConfigurationsFor: 'test-id' asSymbol data: data.
	
	CdTokenStore default clearPermissions;
		for: 'test-token' grant: {
			CdPathMethodAccess for: #GET on: RcConfigCall function.
		}.
	
	client request url addPathSegments: #( config 'test-id' ).
	client headerAt: 'Authorization' put: 'test-token';
		headerAt: 'Accept-Language' put: 'xyz';
		get.
	
	result := client response.
	
	result code = 200
		ifFalse: [ Error signal: 'Result code is ', (result code asString) ].
	result contents = '"test-xyz"'
		ifFalse: [ Error signal: 'Content is ', (result contents) ].

]

{ #category : #tests }
RcRESTTests >> testGetConfigCallDefault [
	| data |
	data := Dictionary new
		at: 'xyz' put: 'test-xyz';
		at: 'default' put: 'test-default';
		yourself.
		
	RcConfigStore addConfigurationsFor: 'test-id' asSymbol data: data.
	
	CdTokenStore default clearPermissions;
		for: 'test-token' grant: {
			CdPathMethodAccess for: #GET on: RcConfigCall function.
		}.
	
	client request url addPathSegments: #( config 'test-id' ).
	client headerAt: 'Authorization' put: 'test-token';
		get.
	
	result := client response.

	result code = 200
		ifFalse: [ Error signal: 'Result code is ', (result code asString) ].
	result contents = '"test-default"'
		ifFalse: [ Error signal: 'Content is ', (result contents) ].

]
