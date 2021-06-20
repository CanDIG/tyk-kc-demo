#!/bin/bash
#set -euo pipefail

readonly token=${1:-"notoken"}
if [[ "${token}" == "notoken" ]]
then
    >&2 echo "Usage: $0 token"
    exit -1
fi

source config.sh
curl -f -u ${CLIENT_LOGIN_ID}:${CLIENT_LOGIN_SECRET} \
     "${BASEURL}/protocol/openid-connect/token/introspect" \
     -d "token=${token}"