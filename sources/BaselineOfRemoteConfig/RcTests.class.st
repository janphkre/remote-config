Class {
	#name : #RcTests,
	#superclass : #TestCase,
	#instVars : [
		'server',
		'client'
	],
	#category : #BaselineOfRemoteConfig
}

{ #category : #running }
RcTests >> setUp [
	super setUp.
	
	server := RemoteConfigServer versioned: 'vtest'.
	server start: 1700 + 10 atRandom.
	
	client := ZnClient new
		url: server localUrl;
		yourself.
	client request url addPathSegments: #(api vtest).

]

{ #category : #running }
RcTests >> tearDown [
	client close.
	server stop.
]

{ #category : #tests }
RcTests >> testGetConfigCall [
	| data result |
	data := Dictionary new
		at: 'default' put: 'test-default';
		at: 'xyz' put: 'test-xyz';
		yourself.

	RcConfigStore addConfigurationsFor: 'test-config' data: data.
	CdTokenStore default clearPermissions;
		for: 'test-token' grant: {
			CdPathMethodAccess for: #GET on: RcConfigCall function.
		}.
		
	client request url addPathSegments: #(config 'test-config').
	client headerAt: 'Authorization' put: 'test-token'.
	client get.
	result := client response.
	result code = 200 ifFalse: [
		Error signal: 'Result code is ', (result code) asString ].
	result contents = '"test-default"' ifFalse: [
		Error signal: 'Result is ', (result contents)].
	
	client headerAt: 'Accept-Language' put: 'xyz'.
	client get.
	result := client response.
	result code = 200 ifFalse: [
		Error signal: 'Result code is ', (result code) asString ].
	result contents = '"test-xyz"' ifFalse: [
		Error signal: 'Result is ', (result contents)].

]
