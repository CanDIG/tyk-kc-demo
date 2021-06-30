#!/usr/bin/env bash
set -euo pipefail

TOKEN1=$(./oidc/test_scripts/get_token_user1.sh | jq .access_token | tr -d \" )

# this should fail if more than 5 attempts are run in a minute

for i in {1..10}
do
    echo -n "${i}: "
    curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${TOKEN1}" http://tyk:8000/test-api/get
done
curl -H "Authorization: Bearer ${TOKEN1}" http://tyk:8000/test-api/get

echo ""
echo "Waiting one minute"
sleep 60
echo ""
curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer ${TOKEN1}" http://tyk:8000/test-api/get