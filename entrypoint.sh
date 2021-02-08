#!/bin/sh
set -eu

OPTIONS=""

if [ -n "${INPUT_PARALLELITY:-}" ]; then
  OPTIONS="$OPTIONS -T$INPUT_PARALLELITY"
fi

if [ -n "${INPUT_VERBOSE:-}" ]; then
  OPTIONS="$OPTIONS -d"
fi

# shellcheck disable=SC2086
/opt/scms/bin/scms $OPTIONS /github/workspace /tmp/scms-output
