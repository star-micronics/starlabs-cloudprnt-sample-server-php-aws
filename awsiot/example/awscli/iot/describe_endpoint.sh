#!/bin/bash

set -u

echo -e "\nDescribing endpoint ..."

descrube_result=$(aws iot describe-endpoint\
  --region ${CP_AWS_IOT_REGION}\
  --endpoint-type IoT:Data-ATS 2>&1)
result_code=$?

if [ $result_code -ne 0 ]; then
  echo -e "\nFailed to describe endpoint. ${descrube_result}"
  exit 1
fi

echo ${descrube_result} | jq

echo -e "\nEndpoint is described."
