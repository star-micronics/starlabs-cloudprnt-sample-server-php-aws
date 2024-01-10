- [English](README.md)

# 概要

CloudPRNT Version MQTTにおいて、AWS IoTをMQTTブローカーとして利用するための準備に関する説明です。

## AWS IoTへの接続方法

AWS IoTに対し、以下の条件で接続を行います。

- プロトコル : MQTT
- 認証 : カスタム認証（ユーザーネーム、パスワード認証）
- ALPNプロトコル : mqtt

[参考: Protocols, port mappings, and authentication](https://docs.aws.amazon.com/iot/latest/developerguide/protocols.html#protocol-port-mapping)

## AWS IoT の準備

### 0. 前提

- AWSアカウントの発行などが完了していて、AWS IoT を利用できる状態になっている必要があります
- [AWS CLI](https://aws.amazon.com/cli/?nc1=h_ls) が作業用PCで使用可能になっており、必要な権限のもとで AWS CLI を実行できる必要があります

### 1. AWS IoT のエンドポイントを確認する

- ATS(Amazon Trust Services)のエンドポイントを確認します
- AWS IoT Core コンソールの `Settings(設定)` ページで確認します
  - [AWS IoT デバイスデータとサービスエンドポイント](https://docs.aws.amazon.com/iot/latest/developerguide/iot-connect-devices.html#iot-connect-device-endpoints)
- AWS CLI を使用して確認することも可能です
  - [aws iot describe-endpoint](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iot/describe-endpoint.html)

### 2. AWS IoT のカスタム認証を実装する

[カスタムオーソライザーの作成と管理](https://docs.aws.amazon.com/iot/latest/developerguide/config-custom-auth.html) を参考に、カスタム認証を実装します。

#### 2-1. [Lambda関数の定義](https://docs.aws.amazon.com/iot/latest/developerguide/config-custom-auth.html#custom-auth-lambda) についての補足

この関数では、プリンターデバイスやCloudPRNTサーバーからのMQTT接続における、ユーザー名・パスワード認証のための検証を行い、AWSのポリシーを返却します。  
CloudPRNTサーバー実装時には、プリンターデバイスやCloudPRNTサーバーが、このLambda関数での検証をパスできるように実装する必要があります。

#### 2-2. [オーソライザーを作成する](https://docs.aws.amazon.com/iot/latest/developerguide/config-custom-auth.html#custom-auth-create-authorizer) についての補足

- 開発者ガイドに記載の AWS CLI を使用する方法の他、AWS IoT Core コンソールの `セキュリティ > カスタムオーソライザー` でも作成可能です。
- オーソライザーは
  - `アクティブ（有効化）` にする必要があります
  - `トークンの検証（署名）を無効` にする必要があります

#### 2-3. [オーソライザーのテスト](https://docs.aws.amazon.com/iot/latest/developerguide/config-custom-auth.html#custom-auth-testing) についての補足

- 開発者ガイドに記載されているように [aws iot test-invoke-authorizer](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iot/test-invoke-authorizer.html) を使用してのテストが可能です

### 3. 2で作成したカスタムオーソライザーをデフォルトのオーソライザーに設定する

- AWS CLI を使用して、2で作成したカスタムオーソライザーをデフォルトのオーソライザーに設定します
  - [aws iot set-default-authorizer](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iot/set-default-authorizer.html)

## AWS IoT の準備のための設定例

AWS CLI を使用したスクリプトを用いて AWS IoT 環境を設定する実装例を [example](example/README_JP.md) に準備しています。
<br/>[AWS IoT の準備](#aws-iot-の準備)に記述した手順との対応は以下の通りです

| 手順 | 実装例の中での対応箇所 |
| --- | --- |
| [1. AWS IoT のエンドポイントを確認する](#1-aws-iot-のエンドポイントを確認する) | [AWS IoT のエンドポイント(ATS: Amazon Trust Services)を確認する](example/README_JP.md#aws-iot-のエンドポイントats-amazon-trust-servicesを確認する)のコマンドで確認できます |
| [2-1. Lambda関数の定義についての補足](#2-1-lambda関数の定義-についての補足) | [Lambda関数の実装例](example/awscli/lambda/iot_authorizer/index.mjs)を準備しています |
|| [AWS IoT を設定する](example/README_JP.md#aws-iot-を設定する)のコマンドでLambda関数を作成しています |
| [2-2. オーソライザーを作成するについての補足](#2-2-オーソライザーを作成する-についての補足) | [AWS IoT を設定する](example/README_JP.md#aws-iot-を設定する)のコマンドでオーソライザーを作成しています |
| [2-3. オーソライザーのテストについての補足](#2-3-オーソライザーのテスト-についての補足) | [AWS IoT カスタムオーソライザーをテストする](example/README_JP.md#aws-iot-カスタムオーソライザーをテストする)のコマンドでテストを実行できます |
| [3. 2で作成したカスタムオーソライザーをデフォルトのオーソライザーに設定する](#3-2で作成したカスタムオーソライザーをデフォルトのオーソライザーに設定する) | [AWS IoT を設定する](example/README_JP.md#aws-iot-を設定する)のコマンドでデフォルトのオーソライザーを設定しています |
