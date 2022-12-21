#!/bin/bash
set -Eeuo pipefail

# Build this Mule app
# including running all (unit) tests (can be skipped, default is false, i.e., don't skip if not provided), and
# beforehand install (which may include: build) all required local dependencies (those in the same monorepo)
#
# Usage  : build.sh <secure-props-key>   [skip-tests]
# Example: build.sh secure12345 false

ENCRYPTKEY=$1          # Mule app secure properties en/decryption key
SKIP_TESTS=${2:-false} # whether to skip (MUnit) tests, if not set default to false

scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd $scriptdir

sts="$scriptdir/../../../etc/settings.xml"
mvns="mvn -s $sts -ff -U -q"

UNIT="$(basename $scriptdir)"

if [ "$SKIP_DEPS" != "true" ]; then
# install the parent POM this app depends on
../install-parent-poms.sh
# build local dependencies, skipping tests
../../apps-commons/build.sh              true
../../custom-connectors/resilient-http/build.sh true
fi

echo "Building $UNIT"
if [ "$SKIP_TESTS" == "true" ]; then skipTests="-DskipTests"; else skipTests=""; fi
$mvns verify -Dencrypt.key=$ENCRYPTKEY $skipTests
