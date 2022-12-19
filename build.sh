#!/bin/bash
# Copyright (C) MuleSoft, Inc. All rights reserved. http://www.mulesoft.com
#
# The software in this package is published under the terms of the
# Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License,
# a copy of which has been included with this distribution in the LICENSE.txt file.
set -Eeuo pipefail

# Build this Mule app
# including running all (unit) tests (can be skipped, default is false, i.e., don't skip if not provided), and
# beforehand install (which may include: build) all required local dependencies (those in the same monorepo)
#
# Usage  : build.sh <secure-props-key>   [skip-tests]
# Example: build.sh securePropsCryptoKey false

ENCRYPTKEY=$1          # Mule app secure properties en/decryption key
SKIP_TESTS=${2:-false} # whether to skip (MUnit) tests, if not set default to false

scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd $scriptdir

sts="$scriptdir/../../../etc/settings.xml"
mvns="mvn -s $sts -ff -U -q"

UNIT="$(basename $scriptdir)"

# build local dependencies, skipping tests
../../apps-commons/build.sh              "$ENCRYPTKEY" true
../../resilience-mule-extension/build.sh "$ENCRYPTKEY" true
# install the parent POM this app depends on
../install-parent-poms.sh

echo "Building $UNIT"
if [ "$SKIP_TESTS" == "true" ]; then skipTests="-DskipTests"; else skipTests=""; fi
$mvns verify -Dencrypt.key=$ENCRYPTKEY $skipTests
