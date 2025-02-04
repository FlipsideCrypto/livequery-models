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
	--vars '{LQ_UPDATE_UDFS_AND_SPS: true, UPDATE_UDFS_AND_SPS: false}' \
	--profiles-dir ~/.dbt \
	--profile livequery \
	--target dev


deploy_overrides: rm_logs
	dbt run \
	-s tag:override \
	--vars '{LQ_UPDATE_UDFS_AND_SPS: true}' \
	--profiles-dir ~/.dbt \
	--profile livequery \
	--target dev