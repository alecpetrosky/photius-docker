#!/bin/bash
set -eu

test -f /tmp/healthcheck || exit 1
[[ $(echo "($(date +%s) - $(cat /tmp/healthcheck))" | bc -l) -lt $PHOTIUS_FAILURE_THRESHOLD ]] || exit 1
