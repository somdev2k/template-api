#!/bin/bash
set -Eeuo pipefail

# Deploy this Mule app to the given environment using the given configuration
#
# Usage  : deploy.sh <env> <ap-client-id> <ap-client-id> <ap-client-secret> <secure-props-key> <ca-client-id> <ca-client-secret>
# Example: deploy.sh dev 0ba141c45f1f405784c20b035ab24964 1902FA4eE4e6460caC4300493A9A3Cc5 secure12345 1420005218c74440960ee6beb6c064a9 ffB051a094d84427B7132FC9076f3c6f

ENV=$1        # Environment identifier
APCID=$2      # Anypoint Platform client ID to register with API Manager for autodiscovery
APSECRET=$3   # Anypoint Platform client secret for client ID
ENCRYPTKEY=$4 # Mule app secure properties en/decryption key
APCACID=$5    # Anypoint Platform Connected app client ID for deployment auth
APCASECRET=$6 # Anypoint Platform Connected app client secret for deployment auth

scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd $scriptdir

UNIT="$(basename $scriptdir)"

case $ENV in 
	dev|test)
		echo "Deploying $UNIT to $ENV"
		./deploy-to-ch.sh $ENV "-$ENV" MICRO $APCID $APSECRET $ENCRYPTKEY $APCACID $APCASECRET
		;;
	prod)
		echo "Deploying $UNIT to $ENV"
		./deploy-to-ch.sh $ENV '' MICRO $APCID $APSECRET $ENCRYPTKEY $APCACID $APCASECRET 
		;;
	*)
		echo "Unsupported environment $ENV for deploying $UNIT" 1>&2
		exit 1
esac
