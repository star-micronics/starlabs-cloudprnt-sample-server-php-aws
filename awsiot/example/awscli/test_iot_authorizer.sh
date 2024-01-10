#!/bin/bash

# This script is used to test AWS IoT authorizer with AWS CLI.

set -eu

cur_dir=$(cd $(dirname $0); pwd)

function echo_info {
  echo -e "\e[36m$1\e[m"
}

trap 'echo "Process was interrupted by signal."; exit 1' SIGINT

echo_info "\nStart testing AWS IoT custom authorizer '${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME}' which invokes AWS Lambda '${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME}'."

cd ${cur_dir} && ./iot/test_authorizer.sh

echo_info '\nFinish testing.'
