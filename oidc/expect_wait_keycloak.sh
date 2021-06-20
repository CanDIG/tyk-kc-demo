#!/usr/bin/expect
set timeout 90
log_user 0

eval spawn docker-compose logs -f oidc
expect "Admin console listening"
