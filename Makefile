SHELL := /bin/bash

rm_logs:
	@if [ -d logs ]; then \
		rm -r logs 2>/dev/null || echo "Warning: Could not remove logs directory"; \
	else \
		echo "Logs directory does not exist"; \
	fi

deploy_near_mainnet_lv: rm_logs
	dbt run \
	-s livequery_models.deploy.near.near__mainnet \
	--vars '{UPDATE_UDFS_AND_SPS: true}' \
	--profiles-dir ~/.dbt \
	--profile livequery \
	--target dev

compile_near_mainnet: rm_logs
	dbt compile \
	-s livequery_models.deploy.near.near__mainnet \
	--profiles-dir ~/.dbt \
	--profile livequery \
	--target dev
