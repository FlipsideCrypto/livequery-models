.PHONY: tag
MAX_COUNT ?= 1

tag:
	@git add .
	@git commit -m "Bump version to $(version)"
	@git tag -a v$(version) -m "version $(version)"
	@git push origin v$(version)

get_latest_tags:
	@echo "Latest $(MAX_COUNT) tags:"
	@echo $$(tput setaf 2) `git describe --tags $(git rev-list --tags --max-count=$(MAX_COUNT))` $$(tput sgr0)