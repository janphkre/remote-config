Class {
	#name : #BaselineOfRemoteConfig,
	#superclass : #BaselineOf,
	#category : #BaselineOfRemoteConfig
}

{ #category : #baselines }
BaselineOfRemoteConfig >> baseline: spec [
	<baseline>
	spec
		for: #pharo
		do:
			[ 
			spec baseline: 'ZincHTTPComponents' with: [
						spec
							loads: #('core');
							repository: 'github://zweidenker/zinc/repository' ].
				spec baseline: 'OpenAPI' with: [
						spec
							loads: #('core');
							repository: 'github://zweidenker/OpenAPI/source' ];
					project: 'OpenAPI-Core' copyFrom: 'OpenAPI' with: [ 
						 spec loads: 'Core'].
			
			spec package: 'RemoteConfig'.
			spec package: 'RemoteConfig-Tests' with:[spec requires: #('core')].

			spec
				group: 'core' with: #('RemoteConfig');
				group: 'tests' with: #('RemoteConfig-Tests');
				group: 'default' with: #('core')
			]
]