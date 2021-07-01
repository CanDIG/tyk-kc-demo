#!/usr/bin/env bash
set -euo pipefail

USER1_TOKEN1=$(./oidc/test_scripts/get_token_user1.sh | jq .access_token | tr -d \" )
USER1_TOKEN2=$(./oidc/test_scripts/get_token_user1.sh | jq .access_token | tr -d \" )
USER2_TOKEN1=$(./oidc/test_scripts/get_token_user2.sh | jq .access_token | tr -d \" )

if [ "$USER1_TOKEN1" == "$USER1_TOKEN2" ]
then
  echo "Tokens are the same"
else
  echo "Generated two different tokens"
fi

function api_call {
    local token=$1
    local prefix=${2:-""}
    local status_only=${3:-"false"}
    local endpoint="http://tyk:8000/test-api/get"

    echo -n "${prefix}"

    if [[ "$status_only" == "false" ]]
    then
        curl -H "Authorization: Bearer ${token}" "${endpoint}"
    else
        curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${token}" "${endpoint}"
    fi
}

# this should fail if more than 5 attempts are run in a minute

for i in {1..6}
do
    api_call ${USER1_TOKEN1} "User 1 Token 1 Request ${i}: " true
    api_call ${USER1_TOKEN2} "User 1 Token 2 Request ${i}: " true
    api_call ${USER2_TOKEN1} "User 2 Request ${i}: " true
done
api_call ${USER1_TOKEN1} "Full response User 1 Token 1: "
api_call ${USER1_TOKEN1} "Full response User 1 Token 2: "

echo ""
echo "Waiting one minute"
sleep 60
echo ""

api_call ${USER1_TOKEN1} "User 1 Token 1 Retry:" true
api_call ${USER1_TOKEN2} "User 1 Token 2 Retry: " true
api_call ${USER2_TOKEN1} "User 2 Retry: " true