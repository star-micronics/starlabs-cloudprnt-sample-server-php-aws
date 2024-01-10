#!/bin/bash

# This script is used to describe AWS IoT endpoint with AWS CLI.

set -eu

cur_dir=$(cd $(dirname $0); pwd)

function echo_info {
  echo -e "\e[36m$1\e[m"
}

trap 'echo "Process was interrupted by signal."; exit 1' SIGINT

echo_info "\nStart describing AWS IoT endpoint."

cd ${cur_dir} && ./iot/describe_endpoint.sh

echo_info '\nFinish describing.'
