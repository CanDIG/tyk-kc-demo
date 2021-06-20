#!/bin/bash
set -euo pipefail

readonly token=${1:-"notoken"}
if [[ "${token}" == "notoken" ]]
then
    >&2 echo "Usage: $0 token"
    exit -1
fi

source config.sh
curl "${BASEURL}/protocol/openid-connect/userinfo" \
     -H "Authorization: Bearer ${token}" 