.DEFAULT_GOAL := help
.PHONY: help format start build-docker run-docker gemlock

help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%-20s\033[0m %s\n", $$1, $$2}'

start: ## Start the script
	bundle exec ruby main.rb

build-docker: ## Build the docker image and name it mapleroyals-vote-reminder
	docker rm mapleroyals-vote-reminder || true
	docker build -t mapleroyals-vote-reminder .

run-docker: build-docker  ## Run the Docker container
	docker run -it --name mapleroyals-vote-reminder --env-file ./.env mapleroyals-vote-reminder

gemlock: ## Generate a Gemfile.lock
	docker run --rm -v ${CURDIR}:/usr/src/app -w /usr/src/app ruby:2.7 bundle install
