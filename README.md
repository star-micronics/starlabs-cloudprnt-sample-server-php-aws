- [日本語はこちら](README_JP.md)

# Star CloudPRNT Sample Server (PHP)

This repository is a sample Star CloudPRNT server.
- Implement CloudPRNT server and publish/subscribe MQTT messages using PHP.
- Use AWS IoT as an MQTT message broker.

## Document
Please refer [here](https://star-m.jp/products/s_print/sdk/StarCloudPRNT/manual/en/index.html) for Star CloudPRNT documentation.

Please refer [here](https://star-m.jp/products/s_print/sdk/StarCloudPRNT/manual/en/protocol-guide.html) for an overview of CloudPRNT protocol (Version MQTT, Version HTTP).

## Test Environment
This sample has been tested on Ubuntu 22.04 LTS.

## Environment construction procedure

### Requirements

- The following commands must be available
  - make
  - docker compose

- Working directory
  - Directory with this `README.md`.

- AWS
  - When using CloudPRNT Version MQTT with this sample, an AWS IoT environment is required. Refer to [awsiot/README](awsiot/README.md) for information on preparing for AWS IoT.

### Setting environment variables

When using CloudPRNT Version MQTT, please edit the following three .env files according to your environment.  

> [!NOTE]
> If you are using CloudPRNT Version HTTP, you do not need to do anything at this step.

#### 1. `docker/php/.env`
  - If the above file does not exist, please copy and place [docker/php/.env.sample](docker/php/.env.sample).
  - about `AWS_IOT_MQTT_HOST`
    - Please set the endpoint you checked in [`awsiot/README.md`, `Check your AWS IoT endpoints`](awsiot/README.md#1-check-your-aws-iot-endpoints) .
  - `AWS_IOT_MQTT_PORT` is fixed at `443`.

#### 2. `docker/php/httpServer/.env`
  - If the above file does not exist, please copy and place [docker/php/httpServer/.env.sample](docker/php/httpServer/.env.sample) .
  - About `AWS_IOT_MQTT_CLIENT_ID` `AWS_IOT_MQTT_USERNAME` `AWS_IOT_MQTT_PASSWORD`
    - Please set the above values so that they can pass the validation in the Lambda function for AWS IoT custom authentication.
      - For example, if you use [`Lambda function implementation example`](awsiot/example/awscli/lambda/iot_authorizer/index.mjs), please configure as follows.
        - `AWS_IOT_MQTT_CLIENT_ID` : `cloudPrntServer_01`
        - `AWS_IOT_MQTT_USERNAME`  : `cloudPrntServer_01`
        - `AWS_IOT_MQTT_PASSWORD`  : `test`

#### 3. `docker/php/mqttSubscriber/.env`
  - If the above file does not exist, please copy and place [docker/php/mqttSubscriber/.env.sample](docker/php/mqttSubscriber/.env.sample) .
  - About `AWS_IOT_MQTT_CLIENT_ID` `AWS_IOT_MQTT_USERNAME` `AWS_IOT_MQTT_PASSWORD`
    - Please set the above values so that they can pass the validation in the Lambda function for AWS IoT custom authentication.
      - For example, if you use [`Lambda function implementation example`](awsiot/example/awscli/lambda/iot_authorizer/index.mjs), please configure as follows.
        - `AWS_IOT_MQTT_SUB_CLIENT_ID` : `cloudPrntServer_02` (Client id for MQTT must be unique per connection)
        - `AWS_IOT_MQTT_SUB_USERNAME`  : `cloudPrntServer_02`
        - `AWS_IOT_MQTT_SUB_PASSWORD`  : `test`
        - `AWS_IOT_MQTT_PUB_CLIENT_ID` : `cloudPrntServer_03` (Client id for MQTT must be unique per connection)
        - `AWS_IOT_MQTT_PUB_USERNAME`  : `cloudPrntServer_03`
        - `AWS_IOT_MQTT_PUB_PASSWORD`  : `test`

### Setting cloudprnt-setting.json

Edit the json file below according to the CloudPRNT communication protocol you want to use.  
This json file is used as a server response to [Server setting information request (GET)](https://star-m.jp/products/s_print/sdk/StarCloudPRNT/manual/en/protocol-reference/http-method-reference/server-info-get/index.html).

#### 1. Starting with CloudPRNT Version HTTP
  - `src/php_queue/cloudprnt-setting_Sample/cloudprnt-setting_http.json` is used.

#### 2. Starting with CloudPRNT Version MQTT : Trigger POST
  - `src/php_queue/cloudprnt-setting_Sample/cloudprnt-setting_mqtt_triggerpost.json` is used.
    - about `settingForMQTT.mqttConnectionSetting.hostName`
      - Please set the endpoint you checked in [`awsiot/README.md`, `Check your AWS IoT endpoints`](awsiot/README.md#1-check-your-aws-iot-endpoints) .
    - about `settingForMQTT.mqttConnectionSetting.authenticationSetting`
      - Please set the following values so that they can pass the validation in the Lambda function for AWS IoT custom authentication.
        - For example, if you use [`Lambda function implementation example`](awsiot/example/awscli/lambda/iot_authorizer/index.mjs), please configure as follows.
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.clientId` : `{MAC}`
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.username` : `{MAC}`
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.password` : `test`

#### 3. Starting with CloudPRNT Version MQTT : Full MQTT / Pass URL
  - `src/php_queue/cloudprnt-setting_Sample/cloudprnt-setting_mqtt.json` is used.
    - about `settingForMQTT.mqttConnectionSetting.hostName`
      - Please set the endpoint you checked in [`awsiot/README.md`, `Check your AWS IoT endpoints`](awsiot/README.md#1-check-your-aws-iot-endpoints) .
    - about `settingForMQTT.mqttConnectionSetting.authenticationSetting`
      - Please set the following values so that they can pass the validation in the Lambda function for AWS IoT custom authentication.
        - For example, if you use [`Lambda function implementation example`](awsiot/example/awscli/lambda/iot_authorizer/index.mjs), please configure as follows.
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.clientId` : `{MAC}`
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.username` : `{MAC}`
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.password` : `test`

### Preparing the database

The database must be located at the path `src/php_queue/simplequeue.sqlite`.  
If it does not exist or you want to initialize it, copy and place `simplequeue.sqlite.sample`.

### start the server

#### With CloudPRNT Version HTTP

```bash
make up-http
```

#### With CloudPRNT Version MQTT : Trigger POST

```bash
make up-mqtt-tp
```

#### With CloudPRNT Version MQTT : Full MQTT / Pass URL

```bash
make up-mqtt
```

#### Other commands

- Container log standard output

```bash
make logs
```

- Stop the container

```bash
make down
```

### Access the management page
Once the server has started, you can access the management page by entering the following URL in your browser. 

http://`<cloud-prnt-server-ip-address>`:3802/php_queue/management.html

Please refer [here](https://star-m.jp/products/s_print/sdk/StarCloudPRNT/manual/en/test.html) for details.


## Copyright

Copyright 2023 Star Micronics Co., Ltd. All rights reserved.
