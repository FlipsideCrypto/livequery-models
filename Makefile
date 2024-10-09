SHELL := /bin/bash

deploy_evm_eth_sepolia:
	dbt run \
	-s livequery_models.deploy.evm.ethereum__sepolia \
	--vars '{UPDATE_UDFS_AND_SPS: true}' \
	--profiles-dir ~/.dbt \
	--profile livequery \
	--target dev