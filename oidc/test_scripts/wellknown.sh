#!/bin/bash
set -euo pipefail

source config.sh
curl "${BASEURL}/.well-known/openid-configuration"