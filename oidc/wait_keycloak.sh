#!/bin/bash
set -euo pipefail

if [ -x "$(command -v "expect")" ]
then
    ./oidc/expect_wait_keycloak.sh
else
    sleep 30
fi
