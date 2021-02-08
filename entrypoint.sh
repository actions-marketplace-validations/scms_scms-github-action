#!/bin/sh
set -eu

OPTIONS=""
RELATIVE_SOURCE_PATH="."

if [ -n "${INPUT_PARALLELITY:-}" ]; then
  OPTIONS="$OPTIONS -T$INPUT_PARALLELITY"
fi

if [ "${INPUT_VERBOSE:-}" = "true" ]; then
  OPTIONS="$OPTIONS -d"
fi

if [ -n "${INPUT_INPUTPATH:-}" ]; then
  if echo "${INPUT_INPUTPATH:-}" | grep -q "^/"; then
    echo "parameter with: inputpath: … may not start with '/'!" > /dev/stderr
    exit 1
  fi
  if echo "${INPUT_INPUTPATH:-}" | grep -q -e "/\.\." -e "\.\./" -e "^\.\.$"; then
    echo "parameter with: inputpath: … may not contain '/..' or '../'!" > /dev/stderr
    exit 1
  fi
  RELATIVE_SOURCE_PATH="${INPUT_INPUTPATH:-}"
fi

# shellcheck disable=SC2086
/opt/scms/bin/scms $OPTIONS "/github/workspace/${RELATIVE_SOURCE_PATH}" "/tmp/scms-output"
