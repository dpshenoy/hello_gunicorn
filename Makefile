.PHONY: help
help:
	@echo "+------------------+"
	@echo "| Makefile Targets |"
	@echo "+------------------+"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build docker image
	@echo ----------------------
	@echo - Building Flask app -
	@echo ----------------------
	docker-compose build && docker image prune -f

.PHONY: up
up: ## Start a container
	@echo "+----------------------------+"
	@echo "| Starting a Flask container |"
	@echo "+----------------------------+"
	docker-compose up

.PHONY: shell
shell: ## Open a bash shell on running Flask app container
	@echo ----------------------------------
	@echo - Entering Flask container shell -
	@echo ----------------------------------
	docker-compose exec app bash

.PHONY: down
down: ## Stop and remove container
	@echo -----------------------------------
	@echo - Stop and Remove Flask container -
	@echo -----------------------------------
	docker-compose down
