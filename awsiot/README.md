- [日本語はこちら](README_JP.md)

# About

This is an explanation about preparing to use AWS IoT as an MQTT broker in CloudPRNT Version MQTT.

## How to connect to AWS IoT

Connect to AWS IoT with the following conditions.

- Protocol : MQTT
- Authentication : Custom authentication（Username, Password）
- ALPN protocol name : mqtt

[Protocols, port mappings, and authentication](https://docs.aws.amazon.com/iot/latest/developerguide/protocols.html#protocol-port-mapping)

## Preparing for AWS IoT

### 0. Requirements

- You must have completed issuing an AWS account and be able to use AWS IoT.
- The AWS CLI must be available on your work PC and you must be able to run it with the required privileges.

### 1. Check your AWS IoT endpoints

- Check the ATS (Amazon Trust Services) endpoint
- You can find it in the `Settings`` page of your AWS IoT Core console.
  - [AWS IoT device data and service endpoints](https://docs.aws.amazon.com/iot/latest/developerguide/iot-connect-devices.html#iot-connect-device-endpoints)
- You can also check it using the AWS CLI.
  - [aws iot describe-endpoint](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iot/describe-endpoint.html)

### 2. Implement custom authentication for AWS IoT

Implement custom authentication by referring to [Creating and managing custom authorizers](https://docs.aws.amazon.com/iot/latest/developerguide/config-custom-auth.html) .

#### 2-1. Notes for [Defining your Lambda function](https://docs.aws.amazon.com/iot/latest/developerguide/config-custom-auth.html#custom-auth-lambda)

This function performs validation for username/password authentication in MQTT connections from printer devices and CloudPRNT server, and returns the AWS policy.  
When implementing the CloudPRNT server, you need to implement it so that the printer device and CloudPRNT server can pass the validation with this Lambda function.

#### 2-2. Notes for [Creating an authorizer](https://docs.aws.amazon.com/iot/latest/developerguide/config-custom-auth.html#custom-auth-create-authorizer)

- In addition to using the AWS CLI described in the developer guide, you can also create one using `Security > Custom authorizers` in the AWS IoT Core console.
- Authorizer must be `Active`.
- Authorizer must disable `Token Validation`


#### 2-3. Notes for [Testing your authorizers](https://docs.aws.amazon.com/iot/latest/developerguide/config-custom-auth.html#custom-auth-testing)

- You can test your autorizer using [aws iot test-invoke-authorizer](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iot/test-invoke-authorizer.html) as described in the developer guide.

### 3. Set the custom authorizer created in Step 2 as the default authorizer

- Set the custom authorizer created in Step 2 as the default authorizer using the AWS CLI
  - [aws iot set-default-authorizer](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iot/set-default-authorizer.html)

## Example configuration for preparing AWS IoT

[example](example/README.md) is a sample of setting up an AWS IoT environment using a script using the AWS CLI.  
The correspondence with the steps described in [Preparing for AWS IoT](#preparing-for-aws-iot) is as follows.

| Step | Corresponding parts in the example |
| --- | --- |
| [1. Check your AWS IoT endpoints](#1-check-your-aws-iot-endpoints) | You can check with the [Check the AWS IoT endpoint (ATS: Amazon Trust Services)](example/README.md#check-the-aws-iot-endpoint-ats-amazon-trust-services) command. |
| [2-1. Notes for Defining your Lambda function](#2-1-notes-for-defining-your-lambda-function) | [Lambda function implementation example](example/awscli/lambda/iot_authorizer/index.mjs) |
|| Creating a Lambda function with the [Configure AWS IoT](example/README.md#configure-aws-iot) command. |
| [2-2. Notes for Creating an authorizer](#2-2-notes-for-creating-an-authorizer) | Creating an authorizer with the [Configure AWS IoT](example/README.md#configure-aws-iot) command. |
| [2-3. Notes for Testing your authorizers](#2-3-notes-for-testing-your-authorizers) | You can run the test with the command [Test AWS IoT custom authorizer](example/README.md#test-aws-iot-custom-authorizer) command. |
| [3. Set the custom authorizer created in Step 2 as the default authorizer](#3-set-the-custom-authorizer-created-in-step-2-as-the-default-authorizer) | Setting the default authorizer with the [Configure AWS IoT](example/README.md#configure-aws-iot) command. |
