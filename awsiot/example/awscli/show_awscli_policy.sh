#!/bin/bash

# This script is used to show AWS IAM policy for AWS CLI.

set -eu

cur_dir=$(cd $(dirname $0); pwd)

function echo_info {
  echo -e "\e[36m$1\e[m"
}

function echo_warn {
  echo -e "\e[33m$1\e[m"
}

trap 'echo "Process was interrupted by signal."; exit 1' SIGINT

echo_info "\nStart showing AWS IAM policy for AWS CLI."

aws_account_id=$(aws sts get-caller-identity --query Account --output text)
echo_warn "\nYour AWS account id is ${aws_account_id}.\nAre you sure you want to continue? [y/n]"
read answer
if [ "$answer" != "y" ]; then
  echo "Aborted."
  exit 1
fi

sample_file_path="${cur_dir}/iam/policy/awscli_policy.sample.json"
policy_file_path="${cur_dir}/iam/policy/awscli_policy.json"
cp ${sample_file_path} ${policy_file_path}
sed -i "s/DUMMY_AWS_ACCOUNT_ID/${aws_account_id}/" ${policy_file_path}
cat ${policy_file_path} | jq

echo_info "\nFinish showing."
