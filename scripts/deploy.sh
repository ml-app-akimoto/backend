#!/bin/bash -eu
#
# Description:
#   deploy to gcp
#   Following variables are necessary in .env file
#       - PROJECT_ID
#       - SERVICE_NAME
#
# Usage:
#   bash scripts/deploy.sh

THIS_FILE_NAME=$(basename "$0")
ENV_FILE_NAME=".env"
NEED_FILE="Dockerfile"

function print_error() {
    echo ""
    ERROR='\033[1;31m'
    NORMAL='\033[0m'
    echo -e "${ERROR}ERROR${NORMAL}: $1"
    echo ""  
}

if [ ! -e "${NEED_FILE}" ]; then
    print_error 'You are in the wrong directory.'
    echo "Please run:"
    echo "  $ cd /PATH_TO/${NEED_FILE}"
    echo ""
    exit 1
fi

if [ ! -e "${ENV_FILE_NAME}" ]; then
    print_error 'Maybe you are in the wrong directory.'
    echo "Please check whether ${ENV_FILE_NAME} file exists"
    echo "in the current directory"
    echo ""
    exit 1
fi
source "${ENV_FILE_NAME}"

# print error and exit if the PROJECT_ID is undefined
if [ -z "${PROJECT_ID}" ]; then
    print_error "PROJECT_ID is NOT defined in ${ENV_FILE_NAME} file."
    exit 1
fi

# print error and exit if the SERVICE_NAME is undefined
if [ -z "${SERVICE_NAME}" ]; then
    print_error "SERVICE_NAME is NOT defined in ${ENV_FILE_NAME} file."
    exit 1
fi

# print error and exit if gcloud cli is not installed
man gcloud >/dev/null
result="$?"
if [ "${result}" ]; then
    print_error ""
    echo "command not found: gcloud"
    echo ""
    echo "Please see:"
    echo "  https://cloud.google.com/sdk/docs/install#other_installation_options"
    exit 1
fi

gcloud builds submit --tag gcr.io/${PROJECT_ID}/${SERVICE_NAME}

BUILD_COMMAND="gcloud run deploy --image gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
SERVICE=${SERVICE_NAME}
REGION_CODE=3   # Tokyo region: asia-northeast1
UNAUTHENTICATED_ACCESS="y"
# send answers for build command
expect -c "
    set timeout 109
    spawn ${BUILD_COMMAND}
    expect \"Service name (${SERVICE}):\"
    send \"${SERVICE}\n\"
    expect \"your numeric choice:\"
    send \"${REGION_CODE}\n\"
    expect \"$\"
    exit 0
"
# Maybe you need this 2 lines in expect command
## expect \"Allow unauthenticated\"
## send \"${UNAUTHENTICATED_ACCESS}\n\"
