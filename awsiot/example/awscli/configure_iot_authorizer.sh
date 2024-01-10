#!/bin/bash

# This script is used to configure AWS IoT authorizer with AWS CLI.

set -eu

cur_dir=$(cd $(dirname $0); pwd)

function echo_info {
  echo -e "\e[36m$1\e[m"
}

function echo_warn {
  echo -e "\e[33m$1\e[m"
}

trap 'echo "Process was interrupted by signal."; exit 1' SIGINT

echo_info "\nStart configuring AWS IoT authorizer."

aws_account_id=$(aws sts get-caller-identity --query Account --output text)
echo_warn "\nYour AWS account id is ${aws_account_id}.\nAre you sure you want to continue? [y/n]"
read answer
if [ "$answer" != "y" ]; then
  echo "Aborted."
  exit 1
fi

echo_warn "\nA role to execute AWS Lambda function will be created in your AWS IAM.\nDo you want to continue? [y/n]"
read answer
if [ "$answer" != "y" ]; then
  echo "Aborted."
  exit 1
fi
cd ${cur_dir} && ./iam/create_lambda_execution_role.sh
echo "Finish creating role ${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME}."

echo_warn "\nA function for AWS IoT custom authorizer will be created in your AWS Lambda.\nDo you want to continue? [y/n]"
read answer
if [ "$answer" != "y" ]; then
  echo "Aborted."
  exit 1
fi
cd ${cur_dir} && ./lambda/deploy_iot_authorizer.sh ${aws_account_id}
echo "Finish creating function ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME}."

echo_warn "\nA custom authorizer which invokes AWS Lambda ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME} will be created as default authorizer in your AWS IoT.\nDo you want to continue? [y/n]"
read answer
if [ "$answer" != "y" ]; then
  echo "Aborted."
  exit 1
fi
cd ${cur_dir} && ./iot/create_default_authorizer.sh ${aws_account_id}
echo "Finish creating authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} as default."

echo_info "\nFinish configuring."
