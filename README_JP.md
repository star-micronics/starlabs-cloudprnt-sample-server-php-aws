- [English](README.md)

# Star CloudPRNT Sample Server (PHP)

このリポジトリは、Star CloudPRNTサーバーのサンプルです。

- CloudPRNTサーバーおよび、MQTTメッセージの発行/購読をPHPで実装します。
- MQTTメッセージブローカーとしてAWS IoTを利用します。

## ドキュメント
Star CloudPRNTのドキュメントは[こちら](https://star-m.jp/products/s_print/sdk/StarCloudPRNT/manual/ja/index.html)を参照ください。

CloudPRNTプロトコルの概要（Version HTTP, Version MQTT）については[こちら](https://star-m.jp/products/s_print/sdk/StarCloudPRNT/manual/ja/protocol-guide.html)を参照ください。

## 動作確認環境
本サンプルは、Ubuntu 22.04 LTSで動作確認を行なっています。

## 環境構築手順

### 前提

- 以下のコマンドが使用できるようになっている必要があります
  - make
  - docker compose

- 作業ディレクトリ
  - 本`README.md`のあるディレクトリ

- AWS
  - 本サンプルでCloudPRNT Version MQTTを使用する場合には AWS IoT 環境が必要です。AWS IoT の準備については[awsiot/README](awsiot/README_JP.md)をご覧ください。

### 環境変数の設定

CloudPRNT Version MQTTを利用する場合、ご自身の環境に合わせて以下の3つの .env を編集して下さい。

> [!NOTE]
> CloudPRNT Version HTTPを利用する場合、このステップでは何もする必要はありません。


#### 1. `docker/php/.env`
  - 存在しない場合は、 [docker/php/.env.sample](docker/php/.env.sample) をコピーして配置してください
  - `AWS_IOT_MQTT_HOST` について
    - [`awsiot/README.md` 内 `AWS IoT のエンドポイントを確認する`](awsiot/README_JP.md#1-aws-iot-のエンドポイントを確認する) で確認したエンドポイントを設定してください
  - `AWS_IOT_MQTT_PORT` は `443` 固定です

#### 2. `docker/php/httpServer/.env`
  - 存在しない場合は、 [docker/php/httpServer/.env.sample](docker/php/httpServer/.env.sample) をコピーして配置してください
  - `AWS_IOT_MQTT_PUB_CLIENT_ID` `AWS_IOT_MQTT_PUB_USERNAME` `AWS_IOT_MQTT_PUB_PASSWORD` について
    - これらの値は AWS IoT のカスタム認証用の Lambda 関数での検証をパスできるように設定してください
      - 例えば [`awsiot/README.md` の `Lambda関数の定義についての補足` 内の `Lambda関数の実装例`](awsiot/example/awscli/lambda/iot_authorizer/index.mjs) の場合、以下のように設定してください
        - `AWS_IOT_MQTT_PUB_CLIENT_ID` : `cloudPrntServer_01`
        - `AWS_IOT_MQTT_PUB_USERNAME`  : `cloudPrntServer_01`
        - `AWS_IOT_MQTT_PUB_PASSWORD`  : `test`

#### 3. `docker/php/mqttSubscriber/.env`
  - 存在しない場合は、 [docker/php/mqttSubscriber/.env.sample](docker/php/mqttSubscriber/.env.sample) をコピーして配置してください
  - `AWS_IOT_MQTT_PUB_CLIENT_ID` `AWS_IOT_MQTT_PUB_USERNAME` `AWS_IOT_MQTT_PUB_PASSWORD` について
    - これらの値は AWS IoT のカスタム認証用の Lambda 関数での検証をパスできるように設定してください
      - 例えば [`awsiot/README.md` の `Lambda関数の定義についての補足` 内の `Lambda関数の実装例`](awsiot/example/awscli/lambda/iot_authorizer/index.mjs) の場合、以下のように設定してください
        - `AWS_IOT_MQTT_SUB_CLIENT_ID` : `cloudPrntServer_02` (MQTT 用の client id は、接続単位でユニークである必要があります)
        - `AWS_IOT_MQTT_SUB_USERNAME`  : `cloudPrntServer_02`
        - `AWS_IOT_MQTT_SUB_PASSWORD`  : `test`
        - `AWS_IOT_MQTT_PUB_CLIENT_ID` : `cloudPrntServer_03` (MQTT 用の client id は、接続単位でユニークである必要があります)
        - `AWS_IOT_MQTT_PUB_USERNAME`  : `cloudPrntServer_03`
        - `AWS_IOT_MQTT_PUB_PASSWORD`  : `test`

### cloudprnt-setting.json の設定

利用したいCloudPRNT通信プロトコルに応じて、以下のjsonファイルを編集して下さい。  
このjsonファイルは、[サーバー設定情報取得リクエスト (GET)](https://star-m.jp/products/s_print/sdk/StarCloudPRNT/manual/ja/protocol-reference/http-method-reference/server-info-get/index.html)に対するサーバーレスポンスとして利用されます。

#### 1. CloudPRNT Version HTTP で起動する場合
  - `src/php_queue/cloudprnt-setting_Sample/cloudprnt-setting_http.json` が利用されます
  。
#### 2. CloudPRNT Version MQTT : Trigger POST で起動する場合
  - `src/php_queue/cloudprnt-setting_Sample/cloudprnt-setting_mqtt_triggerpost.json` が利用されます。
    - `settingForMQTT.mqttConnectionSetting.hostName` について
      - [`awsiot/README.md` 内 `AWS IoT のエンドポイントを確認する`](awsiot/README_JP.md#1-aws-iot-のエンドポイントを確認する) で確認したエンドポイントを設定してください
    - `settingForMQTT.mqttConnectionSetting.authenticationSetting` について
      - これらの値は AWS IoT のカスタム認証用の Lambda 関数での検証をパスできるように設定してください
        - 例えば [`awsiot/README.md` の `Lambda関数の定義についての補足` 内の `Lambda関数の実装例`](awsiot/example/awscli/lambda/iot_authorizer/index.mjs) の場合、以下のように設定してください
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.clientId` : `{MAC}`
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.username` : `{MAC}`
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.password` : `test`

#### 3. CloudPRNT Version MQTT : Full MQTT / Pass URL で起動する場合
  - `src/php_queue/cloudprnt-setting_Sample/cloudprnt-setting_mqtt.json` が利用されます。
    - `settingForMQTT.mqttConnectionSetting.hostName` について
      - [`awsiot/README.md` 内 `AWS IoT のエンドポイントを確認する`](awsiot/README_JP.md#1-aws-iot-のエンドポイントを確認する) で確認したエンドポイントを設定してください
    - `settingForMQTT.mqttConnectionSetting.authenticationSetting` について
      - これらの値は AWS IoT のカスタム認証用の Lambda 関数での検証をパスできるように設定してください
        - 例えば [`awsiot/README.md` の `Lambda関数の定義についての補足` 内の `Lambda関数の実装例`](awsiot/example/awscli/lambda/iot_authorizer/index.mjs) の場合、以下のように設定してください
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.clientId` : `{MAC}`
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.username` : `{MAC}`
          - `settingForMQTT.mqttConnectionSetting.authenticationSetting.password` : `test`

### データベースの準備

データベースは `src/php_queue/simplequeue.sqlite` という相対パスで配置されている必要があります。
存在しない場合や、初期化したい場合には、 `simplequeue.sqlite.sample` をコピーして配置してください。

### サーバー起動

#### CloudPRNT Version HTTP で起動する場合

```bash
make up-http
```

#### CloudPRNT Version MQTT : Trigger POST で起動する場合

```bash
make up-mqtt-tp
```

#### CloudPRNT Version MQTT : Full MQTT / Pass URL で起動する場合

```bash
make up-mqtt
```

#### その他のコマンド

- コンテナログ標準出力

```bash
make logs
```

- コンテナ停止

```bash
make down
```

### 管理画面アクセス
サーバー起動が行えたら、ブラウザーに以下のURLを入力することで、管理画面を表示することができます。  

http://`<cloud-prnt-server-ip-address>`:3802/php_queue/management.html

この画面の詳細は[こちら](https://star-m.jp/products/s_print/sdk/StarCloudPRNT/manual/ja/test.html)を参照ください。


## Copyright

Copyright 2023 Star Micronics Co., Ltd. All rights reserved.
