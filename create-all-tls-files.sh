#!/bin/bash
# Copyright (C) MuleSoft, Inc. All rights reserved. http://www.mulesoft.com
#
# The software in this package is published under the terms of the
# Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License,
# a copy of which has been included with this distribution in the LICENSE.txt file.
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
