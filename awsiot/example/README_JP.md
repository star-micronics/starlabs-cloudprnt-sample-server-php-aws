- [English](README.md)

# 概要

AWS CLI を使用したスクリプトにより AWS IoT 環境を設定するサンプルです。

### 前提

- 以下のコマンドが使用できるようになっている必要があります
  - make
  - docker

- 作業ディレクトリ
  - example ディレクトリで作業する必要があります

- AWS
  - AWSアカウントの発行などが完了していて、AWS IoT を利用できる状態になっている必要があります

### AWS CLI 用の IAM ユーザーの作成

AWSマネジメントコンソールなどを使用して、AWS CLI 用の IAM ユーザーを作成し、その認証情報を後述の[環境変数の設定](#環境変数の設定)に設定できる状態にしてください。

### 環境変数の設定

ご自身の環境に合わせて `docker/.env` を編集してください。

- 存在しない場合は [docker/.env.sample](docker/.env.sample) をコピーして作成してください。
- [docker/.env.sample](docker/.env.sample)に定義されている環境変数は以下の通りです。

| 種別 | 環境変数名 | 説明 | 必須 |
| --- | --- | --- | --- |
| [AWS CLI 用に予約された環境変数](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) | AWS_ACCESS_KEY_ID | AWS CLI での認証用のアクセスキー | true |
|| AWS_SECRET_ACCESS_KEY | AWS CLI での認証用のシークレットアクセスキー | true |
|| AWS_SESSION_TOKEN | AWS CLI での認証用のセッショントークン（使用する場合） | false |
|| AWS_DEFAULT_REGION | AWS CLI で使用するリージョンのデフォルト | true |
| CloudPRNT 用に設定が必要な環境変数 | CP_AWS_IOT_REGION | CloudPRNT で使用する AWS IoT のリージョン<br/>※特に理由が無ければ`AWS_DEFAULT_REGION`と同じリージョンを指定して下さい | true |
|| CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME | CloudPRNT 用 AWS IoT のカスタムオーソライザー名 | true |
|| CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME | 上記のカスタムオーソライザー用の AWS Lambda の関数名 | true |
|| CP_AWS_LAMBDA_EXECUTION_ROLE_NAME | 上記の Lambda 関数実行用の AWS IAM ロール名 | true |
|| CP_AWS_LAMBDA_RUNTIME | [Lambda関数用のランタイム](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) | true |
|| CP_DEVICE_MAC | CloudPRNT 用 AWS IoT に接続するプリンターの MAC アドレス | true |

### AWS CLI 用　IAM ユーザーへのポリシーの適用

```sh
make show-policy
```

上記を実行すると、JSON形式のポリシーがコンソールに表示されます。また`awscli/iam/policy/awscli_policy.json`というパスにファイルとしても出力されるます。  
AWSマネジメントコンソールを使用するなどして、 AWS CLI 用のIAMユーザーに適用してください。

## 使用方法

### AWS IoT を設定する

```sh
make setup
```

- AWS IoT のカスタムオーソライザーを作成します
- AWS IAM, AWS Lambda, AWS IoT にリソースを作成します
- スクリプトの実行中にリソース作成に関する確認が発生します

### AWS IoT カスタムオーソライザーをテストする

```sh
make test
```

- 作成した AWS IoT カスタムオーソライザーをテストします
- スクリプトの実行中にカスタムオーソライザー認証用の username, password の入力が発生します

### AWS IoT のエンドポイント(ATS: Amazon Trust Services)を確認する

```sh
make describe
```

- AWS IoT のエンドポイントを確認します
