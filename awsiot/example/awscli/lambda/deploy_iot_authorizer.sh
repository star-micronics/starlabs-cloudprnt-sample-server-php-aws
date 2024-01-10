#!/bin/bash

set -u

cur_dir=$(cd $(dirname $0); pwd)

aws_account_id=$1

function echo_warn {
  echo -e "\e[33m$1\e[m"
}

function replace_dummy_vars_in_func {
  func_file_path=$1

  sed -i "s/DUMMY_AWS_ACCOUNT_ID/${aws_account_id}/" ${func_file_path}
  sed -i "s/DUMMY_AWS_REGION/${CP_AWS_IOT_REGION}/" ${func_file_path}
  sed -i "s/DUMMY_MAC_ADDRESS/${CP_DEVICE_MAC}/" ${func_file_path}
}

function update_func {
  echo -e "\nUpdating function ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME} ..."

  zip_path=$1

  update_func_result=$(aws lambda update-function-code\
    --region ${CP_AWS_IOT_REGION}\
    --function-name ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME}\
    --zip-file fileb://${zip_path} 2>&1)
  result_code=$?

  if [[ "${result_code}" -ne 0 ]]; then
    echo -e "Failed to update function. ${update_func_result}"
    exit 1
  fi

  echo ${update_func_result} | jq
  echo "Function ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME} is updated."
}

should_try=1

function create_or_update_func {
  echo -e "\nCreating function ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME} ..."

  cd ${cur_dir}/iot_authorizer

  func_file_path='index.mjs'
  replace_dummy_vars_in_func ${func_file_path}

  zip_path="${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME}.zip"
  zip ${zip_path} ${func_file_path}

  # Lambda function region must be same as IoT region.
  create_func_result=$(aws lambda create-function\
    --region ${CP_AWS_IOT_REGION}\
    --function-name ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME}\
    --runtime ${CP_AWS_LAMBDA_RUNTIME}\
    --role arn:aws:iam::${aws_account_id}:role/${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME}\
    --handler index.handler\
    --zip-file fileb://${zip_path} 2>&1)
  result_code=$?

  if [[ "${result_code}" -eq 0 ]]; then
    echo ${create_func_result} | jq
    echo "Function ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME} is created."
  elif [[ "${create_func_result}" =~ "An error occurred (ResourceConflictException)" ]]; then
    echo_warn "${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME} already exists.\nDo you want to update it? [y/n]"
    read answer
    if [ "$answer" == "y" ]; then
      update_func ${zip_path}
    fi
  elif [[ "${create_func_result}" =~ "An error occurred (InvalidParameterValueException)" ]]; then
    echo_warn "InvalidParameterValueException occurred. This error may be resolved by retrying.\nDo you want to retry? [y/n]"
    read answer
    if [ "$answer" != "y" ]; then
      echo -e "Failed to create function. ${create_func_result}"
      exit 1
    fi
    should_try=1
    return
  else
    echo -e "Failed to create function. ${create_func_result}"
    exit 1
  fi

  cd ${cur_dir}
}

cd ${cur_dir}
while [[ "${should_try}" -eq 1 ]]; do
  should_try=0
  create_or_update_func
done
