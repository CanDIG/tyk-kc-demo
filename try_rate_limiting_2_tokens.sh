#!/usr/bin/env bash
set -euo pipefail

TOKEN1=$(./oidc/test_scripts/get_token_user1.sh | jq .access_token | tr -d \" )
TOKEN2=$(./oidc/test_scripts/get_token_user1.sh | jq .access_token | tr -d \" )
TOKEN3=$(./oidc/test_scripts/get_token_user2.sh | jq .access_token | tr -d \" )

if [ "$TOKEN1" == "$TOKEN2" ]
then
  echo "Tokens are the same"
else
  echo "Generated two different tokens"
fi

# this should fail if more than 5 attempts are run in a minute

for i in {1..10}
do
    echo -n "User 1 Token 1 Request ${i}: "
    curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${TOKEN1}" http://tyk:8000/test-api/get
    echo -n "Uesr 2 Token 2 Request ${i}: "
    curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${TOKEN2}" http://tyk:8000/test-api/get
    echo -n "User 2 Request ${i}: "
    curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${TOKEN3}" http://tyk:8000/test-api/get
done
curl -H "Authorization: Bearer ${TOKEN1}" http://tyk:8000/test-api/get
curl -H "Authorization: Bearer ${TOKEN2}" http://tyk:8000/test-api/get

echo ""
echo "Waiting one minute"
sleep 60
echo ""
echo -n "User 1 Token 1: "
curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${TOKEN1}" http://tyk:8000/test-api/get
echo -n "User 1 Token 2: "
curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${TOKEN2}" http://tyk:8000/test-api/get
echo -n "User 2: "
curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${TOKEN3}" http://tyk:8000/test-api/get