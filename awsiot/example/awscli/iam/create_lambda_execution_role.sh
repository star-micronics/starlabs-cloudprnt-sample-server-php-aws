#!/bin/bash

set -u

cur_dir=$(cd $(dirname $0); pwd)

function create_role {
  echo -e "\nCreating role ${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME} ..."

  create_role_result=$(aws iam create-role\
    --role-name ${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME}\
    --assume-role-policy-document file://policy/lambda_execution_role_trust_policy.json 2>&1)
  # see: https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-returncodes.html
  result_code=$?

  if [[ "${result_code}" -eq 0 ]]; then
    echo ${create_role_result} | jq
    echo "Role ${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME} is created."
  elif [[ "${create_role_result}" =~ "An error occurred (EntityAlreadyExists)" ]]; then
    echo "${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME} already exists."
  else
    echo -e "Failed to create role. ${create_role_result}"
    exit 1
  fi
}

function attach_policy {
  policy_name='AWSLambdaBasicExecutionRole'

  echo -e "\nAttaching policy ${policy_name} to ${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME} ..."

  attach_policy_result=$(aws iam attach-role-policy\
    --role-name ${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME}\
    --policy-arn arn:aws:iam::aws:policy/service-role/${policy_name} 2>&1)
  result_code=$?

  if [[ "${result_code}" -ne 0 ]]; then
    echo -e "Failed to attach policy. ${attach_policy_result}"
    exit 1
  fi

  echo ${attach_policy_result} | jq
  echo "Policy ${policy_name} is attached to ${CP_AWS_LAMBDA_EXECUTION_ROLE_NAME}."
}

cd ${cur_dir}
create_role
attach_policy
