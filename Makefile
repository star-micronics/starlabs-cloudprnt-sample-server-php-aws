.DEFAULT_GOAL := help

.PHONY: build
CPUTIL_BINARY_DL_URL_BASE = https://star-m.jp/products/s_print/sdk/StarDocumentMarkup/cputil/
CPUTIL_BINARY_NAME = cputil-linux-x64_v112.tar.gz
GROUP_ID = $(shell id -g)
GROUP_NAME = $(shell id -gn)
USER_ID = $(shell id -u)
USER_NAME = $(shell id -un)
build: ## Build containers. If you want to change default user and group, you can override them like this: make build GROUP_ID=0 GROUP_NAME='root' USER_ID=0 USER_NAME='root'
	docker compose build\
 --build-arg CPUTIL_BINARY_DL_URL_BASE=${CPUTIL_BINARY_DL_URL_BASE}\
 --build-arg CPUTIL_BINARY_NAME=${CPUTIL_BINARY_NAME}\
 --build-arg GROUP_ID=${GROUP_ID}\
 --build-arg GROUP_NAME=${GROUP_NAME}\
 --build-arg USER_ID=${USER_ID}\
 --build-arg USER_NAME=${USER_NAME}\
 php

.PHONY: up-http
up-http: ## Up containers for version http
	make build
	docker compose run --rm php cp cloudprnt-setting_Sample/cloudprnt-setting_http.json cloudprnt-setting.json
	docker compose up -d php

.PHONY: up-mqtt-tp
up-mqtt-tp: ## Up containers for version mqtt trigger post
	make build
	docker compose run --rm php cp cloudprnt-setting_Sample/cloudprnt-setting_mqtt_triggerpost.json cloudprnt-setting.json
	docker compose up -d php

.PHONY: up-mqtt
up-mqtt: ## Up containers for version mqtt full / pass url
	make build
	docker compose run --rm php cp cloudprnt-setting_Sample/cloudprnt-setting_mqtt.json cloudprnt-setting.json
	docker compose up -d php subscriber

.PHONY: ps
ps: ## Show container status
	docker compose ps

.PHONY: logs
LOGGING_SERVICE = php subscriber
logs: ## Show container logs
	docker compose logs -f ${LOGGING_SERVICE}

.PHONY: down
down: ## Down containers
	docker compose down

.PHONY: help
help: ## Show options
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
