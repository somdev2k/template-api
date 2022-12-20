#!/bin/bash
set -Eeuo pipefail

# password for both key and keystore (following PKCS12)
PWD="$1"

# Mule app name
APP=template-api

create="../../../bin/create-keystore-with-server-keypair-and-export-pub-key-cert-and-client-truststore.sh"

$create "$APP-dev"  "$PWD"
$create "$APP-test" "$PWD"
$create "$APP"      "$PWD"

mkdir -p src/test/resources/certs
mv -i *.pem *-client-trust.p12 src/test/resources/certs/

mkdir -p src/main/resources/certs
mv -i *.p12 src/main/resources/certs/
