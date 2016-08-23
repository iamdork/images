#!/usr/bin/env bash
set -e

# shellcheck source=/dev/null
source $(dirname "$0")/setup.sh

apache2-foreground
