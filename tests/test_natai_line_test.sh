#!/bin/sh
set -eu

SCRIPT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/natai-line-test.sh"

test -x "$SCRIPT"
"$SCRIPT" --help | grep -q 'NAT VPS'
"$SCRIPT" --help | grep -q -- '--quick'
"$SCRIPT" --help | grep -q -- '--target'

echo "ok"
