#!/usr/bin/env bash
# Start up keycloak and config for new user & client
#
set -euo pipefail

source /opt/jboss/config.sh
readonly KC_PATH=/opt/jboss/keycloak/bin

echo "# Connecting to keycloak..."
${KC_PATH}/kcadm.sh config credentials --server http://oidc:8080/auth --realm master --user ${ADMIN} --password ${ADMINPWD}

echo "# Looking up user1"
ID1=$( ${KC_PATH}/kcadm.sh get users -r mockrealm -q username=user1 --fields id --format csv | tr -d \")

echo "# Adding trusted_researcher attribute"
${KC_PATH}/kcadm.sh update users/${ID1} -r mockrealm -s "attributes.trusted_researcher=true"

echo "# Looking up user2"
ID2=$( ${KC_PATH}/kcadm.sh get users -r mockrealm -q username=user2 --fields id --format csv | tr -d \")

echo "# Adding trusted_researcher attribute"
${KC_PATH}/kcadm.sh update users/${ID2} -r mockrealm -s "attributes.trusted_researcher=false"

echo "# Looking up login client"
CID=$( ${KC_PATH}/kcadm.sh get clients -r mockrealm -q clientId=${CLIENT_LOGIN_ID} --fields id --format csv | tr -d \")

echo "# Adding trusted_user mapper"
${KC_PATH}/kcadm.sh create clients/$CID/protocol-mappers/models \
     -r ${REALM} -s name=trusted -s protocol=openid-connect \
     -s protocolMapper=oidc-usermodel-attribute-mapper \
     -s consentRequired=false \
     -s 'config."id.token.claim"=true' \
     -s 'config."access.token.claim"=true' \
     -s 'config."userinfo.token.claim"=true' \
     -s 'config."claim.name"=trusted_researcher' \
     -s 'config."user.attribute"=trusted_researcher' \
     -s 'config."jsonType.label"=boolean' \
     -s 'config."multivalued"=false'