SHELL := /bin/bash

dbt-console: 
	docker-compose run dbt_console

.PHONY: dbt-console

rm_logs:
	@if [ -d logs ]; then \
		rm -r logs 2>/dev/null || echo "Warning: Could not remove logs directory"; \
	else \
		echo "Logs directory does not exist"; \
	fi


deploy_core: rm_logs
	dbt run --select livequery_models.deploy.core._live \
	--vars '{UPDATE_UDFS_AND_SPS: true}' \
	--profiles-dir ~/.dbt \
	--profile livequery \
	--target dev

