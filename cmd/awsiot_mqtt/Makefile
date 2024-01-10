.PHONY: build help
.DEFAULT_GOAL := help

OUT = awsiot_mqtt
build: ## go build
	go build -trimpath -ldflags "-w -s" -mod=readonly -v -o ${OUT} .

help: ## Show options
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'