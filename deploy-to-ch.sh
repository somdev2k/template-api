#!/bin/bash
set -Eeuo pipefail

# Deploy this Mule app to the given CloudHub environment using the given configuration
#
# Usage  : deploy-to-ch.sh <env> <suffix> <worker-type> <ap-client-id> <ap-client-secret> <secure-props-key> <ca-client-id> <ca-client-secret>
# Example: deploy-to-ch.sh dev -dev MICRO 0ba141c45f1f405784c20b035ab24964 1902FA4eE4e6460caC4300493A9A3Cc5 secure12345 1420005218c74440960ee6beb6c064a9 ffB051a094d84427B7132FC9076f3c6f

ENV=$1        # Environment identifier, only for the Mule app properties files selection, NOT for AP environment
SUFFIX=$2     # Mule app name suffix
CHWORKER=$3   # CloudHub worker type (MICRO, SMALL, ...)
APCID=$4      # Anypoint Platform client ID to register with API Manager for autodiscovery
APSECRET=$5   # Anypoint Platform client secret for client ID
ENCRYPTKEY=$6 # Mule app secure properties en/decryption key
APCACID=$7    # Anypoint Platform Connected app client ID for deployment auth
APCASECRET=$8 # Anypoint Platform Connected app client secret for deployment auth

APREGION=us-east-2

scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd $scriptdir

sts="$scriptdir/../../../etc/settings.xml"
mvns="mvn -s $sts -ff -U -q -DskipMunitTests"

echo Confiuguration environment  : $ENV
echo Mule app name suffix        : $SUFFIX
echo Anypoint Platform region    : $APREGION
echo CloudHub worker type        : $CHWORKER
echo Anypoint Platform client ID : $APCID

$mvns -DmuleDeploy deploy \
      -Ddeployment.env=$ENV -Ddeployment.suffix=$SUFFIX \
      -Dap.region=$APREGION -Dch.workerType=$CHWORKER \
      -Dap.client_id=$APCID -Dap.client_secret=$APSECRET \
      -Dap.ca.client_id=$APCACID -Dap.ca.client_secret=$APCASECRET \
      -Dencrypt.key=$ENCRYPTKEY
