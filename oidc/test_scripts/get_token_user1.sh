#!/bin/bash

source config.sh

curl -u ${CLIENT_LOGIN_ID}:${CLIENT_LOGIN_SECRET} \
     -X POST "${BASEURL}/protocol/openid-connect/token" \
     -d "grant_type=password&username=${USER1}&password=${USER1PWD}&redirect_uri=http://tyk:3000/auth/oidc"