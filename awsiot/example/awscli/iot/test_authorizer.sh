#!/bin/bash

set -u

function echo_warn {
  echo -e "\e[33m$1\e[m"
}

echo -e "\nTesting authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} ..."

echo_warn 'Please input username for iot authorizer authentication:'
read username
echo_warn 'Please input password for iot authorizer authentication:'
read password

encoded_password=$(echo -n $password | base64)
test_result=$(aws iot test-invoke-authorizer\
  --region ${CP_AWS_IOT_REGION}\
  --authorizer-name ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME}\
  --mqtt-context "{\"username\":\"${username}\",\"password\":\"${encoded_password}\"}" 2>&1)
result_code=$?

if [[ "${result_code}" -ne 0 ]]; then
  echo -e "Failed to test authorizer. ${test_result}"
  exit 1
fi

echo ${test_result} | jq

echo -e "\nAuthorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} is tested."
