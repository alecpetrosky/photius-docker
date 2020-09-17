#!/bin/bash

[[ $(echo "($(date +%s) - $(cat /tmp/healthcheck))" | bc -l) -lt 300 ]] && exit 0 || exit 1
