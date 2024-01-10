.DEFAULT_GOAL := help

.PHONY: build
DOCKER_IMAGE_NAME = cloud-prnt-server/awsiot-example-awscli:1.0.0
DOCKER_PLATFORM = linux/amd64 # linux/arm64 for arm based machines
AWS_CLI_INSTALLER_NAME = awscli-exe-linux-x86_64.zip # awscli-exe-linux-aarch64.zip for arm based machines
GROUP_ID = $(shell id -g)
GROUP_NAME = $(shell id -gn)
USER_ID = $(shell id -u)
USER_NAME = $(shell id -un)
build: ## Build containers. If you want to change default user and group, you can override them like this: make build GROUP_ID=0 GROUP_NAME='root' USER_ID=0 USER_NAME='root'
	docker build\
 --platform ${DOCKER_PLATFORM}\
 -f ./docker/Dockerfile\
 --build-arg AWS_CLI_INSTALLER_NAME=${AWS_CLI_INSTALLER_NAME}\
 --build-arg GROUP_ID=${GROUP_ID}\
 --build-arg GROUP_NAME=${GROUP_NAME}\
 --build-arg USER_ID=${USER_ID}\
 --build-arg USER_NAME=${USER_NAME}\
 -t ${DOCKER_IMAGE_NAME}\
 .

.PHONY: run
RUN_CMD = /bin/bash
RUN_OPTS =
run: ## Run container
	make build
	docker run --rm -it --env-file ./docker/.env --platform ${DOCKER_PLATFORM} ${RUN_OPTS} ${DOCKER_IMAGE_NAME} ${RUN_CMD}

.PHONY: show-policy
show-policy: ## Run container to create and show JSON formatted AWS IAM policy to use this example
	make run RUN_CMD="./awscli/show_awscli_policy.sh" RUN_OPTS="--volume ./awscli/iam/policy/:/awsiot/awscli/iam/policy/"

.PHONY: setup
setup: ## Run container to configure AWS IoT custom authorizer
	make run RUN_CMD="./awscli/configure_iot_authorizer.sh"

.PHONY: test
test: ## Run container to test AWS IoT custom authorizer
	make run RUN_CMD="./awscli/test_iot_authorizer.sh"

.PHONY: describe
describe: ## Run container to describe AWS IoT custom authorizer
	make run RUN_CMD="./awscli/describe_iot_endpoint.sh"

.PHONY: help
help: ## Show options
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'