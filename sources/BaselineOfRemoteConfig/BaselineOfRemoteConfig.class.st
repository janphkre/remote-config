Class {
	#name : #BaselineOfRemoteConfig,
	#superclass : #BaselineOf,
	#category : #BaselineOfRemoteConfig
}

{ #category : #baselines }
BaselineOfRemoteConfig >> baseline: spec [
	<baseline>
	spec
		for: #common
		do:
			[ 
			spec baseline: 'ZincHTTPComponents' with: [
						spec
							loads: #('REST');
							repository: 'github://zweidenker/zinc/repository' ].
			spec baseline: 'OpenAPI' with: [
						spec
							loads: #('REST');
							repository: 'github://zweidenker/OpenAPI/source' ];
					project: 'OpenAPI-Core' copyFrom: 'OpenAPI' with: [ 
						 spec loads: 'Core'].
			spec baseline: 'cadmium' with: [
						spec
							loads: #('default');
							repository: 'github://janphkre/cadmium/src' ].
			spec package: 'RemoteConfig' with:[spec requires: #('ZincHTTPComponents' 'OpenAPI-Core')].
			spec package: 'RemoteConfig-Tests' with:[spec requires: #('core')].

			spec
				group: 'core' with: #('RemoteConfig');
				group: 'tests' with: #('RemoteConfig-Tests');
				group: 'default' with: #('core')
			]
]
