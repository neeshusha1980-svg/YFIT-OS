#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
exec ./tests/verify-iso.sh "${1:-output/yfit-os-amd64.iso}"
