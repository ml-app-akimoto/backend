#!/bin/bash -eu
#
# Description:
#   deploy to gcp
#   see how to connect gcp 
#
# Usage:
#   bash scripts/deploy.sh

THIS_FILE_NAME='deploy.sh'

function print_error() {
    RED='\033[1;31m'    # 1-Bold attribute
    NC='\033[0m'
    echo -e "${bold}${RED}ERROR${normal}${NC}: $1"    
}

if [ -e "${THIS_FILE_NAME}" ]; then
    print_error 'You are in the wrong directory.'
    echo -e "Please run\n"
    echo "  $ cd .."
    echo "  $ bash scripts/${THIS_FILE_NAME}"
    exit 1
fi

source .env

# print error and exit if the PROJECT_ID is undefined
if [ -z "${PROJECT_ID}" ]; then
    print_error 'PROJECT_ID NOT found in .env file.'
    exit 1
fi

# print error and exit if the SERVICE_NAME is undefined
if [ -z "${SERVICE_NAME}" ]; then
    print_error 'SERVICE_NAME NOT found in .env file.'
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
