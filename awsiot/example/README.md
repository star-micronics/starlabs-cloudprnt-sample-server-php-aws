- [日本語はこちら](README_JP.md)

# About

This is a sample of setting up an AWS IoT environment with a script using the AWS CLI.

### Requirements

- The following commands must be available
  - make
  - docker

- Working directory
  - `awsiot/example`

- AWS
  - You must have completed issuing an AWS account and be able to use AWS IoT.

### Creating an IAM User for the AWS CLI

Create an IAM user for the AWS CLI using the AWS Management Console, etc., and make sure that its credentials can be set in [Setting environment variables](#setting-environment-variables) described below.

### Setting environment variables

Edit `docker/.env` according to your environment.

- If the above file does not exist, please copy and place [docker/.env.sample](docker/.env.sample).
- The environment variables defined in [docker/.env.sample](docker/.env.sample) are as follows.

| Type | Variable name | Description | Required |
| --- | --- | --- | --- |
| [Environment variables to configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) | AWS_ACCESS_KEY_ID | Access keys for authentication with the AWS CLI | true |
|| AWS_SECRET_ACCESS_KEY | Secret access key for authentication  | true |
|| AWS_SESSION_TOKEN | Session token for authentication (if required) | false |
|| AWS_DEFAULT_REGION | Default region | true |
| Environment variables to configure CloudPRNT | CP_AWS_IOT_REGION | AWS IoT Regions Used with CloudPRNT<br/>* If there is no particular reason, please specify the same region as `AWS_DEFAULT_REGION`. | true |
|| CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME | Custom authorizer name for AWS IoT for CloudPRNT | true |
|| CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME | AWS Lambda function name for the above custom authorizer | true |
|| CP_AWS_LAMBDA_EXECUTION_ROLE_NAME | AWS IAM role name for executing the above Lambda function | true |
|| CP_AWS_LAMBDA_RUNTIME | [Lambda runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) | true |
|| CP_DEVICE_MAC | MAC address of the printer connecting to AWS IoT<br>* Please specify lowercase letters | true |

### Applying policies to IAM users for AWS CLI

```sh
make show-policy
```

After running the above, a JSON formatted policy will be displayed in the console. It is also output as a file to the path `awscli/iam/policy/awscli_policy.json`.  
Apply it to the IAM user for the AWS CLI, for example using the AWS Management Console.

## How to use

### Configure AWS IoT

```sh
make setup
```

- Create a custom authorizer for AWS IoT
- Create resources in AWS IAM, AWS Lambda, and AWS IoT
- Confirmation regarding resource creation occurs during script execution

### Test AWS IoT custom authorizer

```sh
make test
```

- Test the AWS IoT custom authorizer you created
- Username and password input for custom authorizer authentication will be required during script execution

### Check the AWS IoT endpoint (ATS: Amazon Trust Services)

```sh
make describe
```

- Check your AWS IoT endpoints