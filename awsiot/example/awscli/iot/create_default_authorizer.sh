#!/bin/bash

set -u

cur_dir=$(cd $(dirname $0); pwd)

aws_account_id=$1

function echo_warn {
  echo -e "\e[33m$1\e[m"
}

function update_authorizer {
  echo -e "\nUpdating authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} ..."

  update_authorizer_result=$(aws iot update-authorizer\
    --region ${CP_AWS_IOT_REGION}\
    --authorizer-name ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME}\
    --authorizer-function-arn arn:aws:lambda:${CP_AWS_IOT_REGION}:${aws_account_id}:function:${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME}\
    --status ACTIVE 2>&1)
  result_code=$?

  if [[ "${result_code}" -ne 0 ]]; then
    echo -e "Failed to update authorizer. ${update_authorizer_result}"
    exit 1
  fi

  echo ${update_authorizer_result} | jq
  echo "Authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} is updated."
}

function create_authorizer {
  echo -e "\nCreating authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} ..."

  create_authorizer_result=$(aws iot create-authorizer\
    --region ${CP_AWS_IOT_REGION}\
    --authorizer-name ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME}\
    --authorizer-function-arn arn:aws:lambda:${CP_AWS_IOT_REGION}:${aws_account_id}:function:${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME}\
    --signing-disabled\
    --status ACTIVE 2>&1)
  result_code=$?

  if [[ "${result_code}" -eq 0 ]]; then
    echo ${create_authorizer_result} | jq
    echo "Authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} is created."
  elif [[ "${create_authorizer_result}" =~ "An error occurred (ResourceAlreadyExistsException)" ]]; then
    echo_warn "${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} already exists.\nDo you want to update it? [y/n]"
    read answer
    if [ "$answer" == "y" ]; then
      update_authorizer
    fi
  else
    echo -e "Failed to create authorizer. ${create_authorizer_result}"
    exit 1
  fi
}

function add_permission {
  echo -e "\nAdding permission to call lambda ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME} in authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} ..."

  add_permission_result=$(aws lambda add-permission\
    --region ${CP_AWS_IOT_REGION}\
    --function-name ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME}\
    --statement-id ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME}\
    --action lambda:InvokeFunction\
    --principal iot.amazonaws.com\
    --source-arn arn:aws:iot:${CP_AWS_IOT_REGION}:${aws_account_id}:authorizer/${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} 2>&1)
  result_code=$?

  if [[ "${result_code}" -eq 0 ]]; then
    echo ${add_permission_result} | jq
    echo "Permission to call lambda ${CP_AWS_LAMBDA_AUTHORIZER_FUNC_NAME} in authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} is added."
  elif [[ "${add_permission_result}" =~ "An error occurred (ResourceConflictException)" ]]; then
    echo "Permission already exists."
  else
    echo -e "Failed to add permission. ${add_permission_result}"
    exit 1
  fi
}

function set_default_authorizer {
  echo -e "\nSetting authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} as default ..."

  set_default_authorizer_result=$(aws iot set-default-authorizer\
    --region ${CP_AWS_IOT_REGION}\
    --authorizer-name ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} 2>&1)
  result_code=$?

  if [[ "${result_code}" -eq 0 ]]; then
    echo ${set_default_authorizer_result} | jq
    echo "authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} is set as default."
  elif [[ "${set_default_authorizer_result}" =~ "An error occurred (ResourceAlreadyExistsException)" ]]; then
    echo "authorizer ${CP_AWS_IOT_CUSTOM_AUTHORIZER_NAME} is already set as default."
  else
    echo -e "Failed to set default authorizer. ${set_default_authorizer_result}"
    exit 1
  fi
}

cd ${cur_dir}
create_authorizer
add_permission
set_default_authorizer
