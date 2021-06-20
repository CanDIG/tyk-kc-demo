#!/bin/bash

source config.sh

curl -u ${CLIENT_LOGIN_ID}:${CLIENT_LOGIN_SECRET} \
     -X POST "${BASEURL}/protocol/openid-connect/token" \
     -d "grant_type=password&username=${USER2}&password=${USER2PWD}&redirect_uri=http://localhost:3000/auth/oidc"