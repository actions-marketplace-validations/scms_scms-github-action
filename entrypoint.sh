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
/opt/scms/bin/scms $OPTIONS "${GITHUB_WORKSPACE}/${RELATIVE_SOURCE_PATH}" "/tmp/scms-output"
rc=$?

# make sure we do not proceed on errors.
if [ $rc -ne 0 ]; then
  exit $rc
fi

# check if output is wanted
if [ -z "${INPUT_OUTPUTBRANCH:-}" ]; then
  exit 0
fi

TARGETBRANCH="${INPUT_OUTPUTBRANCH}"

#OLD_BRANCH="$(git branch --show-current)"
cd "${GITHUB_WORKSPACE}" || exit 1
git fetch origin

set -x

# see if we need to create a new branch.
if git ls-remote --heads origin site-staging | grep -q "refs/heads/${TARGETBRANCH}"; then
  echo "now checking out existing [origin/${TARGETBRANCH}]."
  git checkout --track "origin/${TARGETBRANCH}" || exit 1
else
  echo "now checking out new orphan branch [origin/${TARGETBRANCH}]."
  git checkout --orphan "${TARGETBRANCH}" || exit 1
  git rm -rf .
fi

if [ "${INPUT_WIPEOUTPUTBRANCH}" = "true" ]; then
  # find . -exec git rm -rf --ignore-unmatch -- '{}' +
  echo "Wipe output branch is not supported yet!" > /dev/stderr
  exit 1
fi

git clean --force -d -x || exit 1
cp --recursive --verbose --force "/tmp/scms-output/." "${GITHUB_WORKSPACE}/"
git config --local user.email "${GITHUB_ACTOR}@users.noreply.github.com}"
git config --local user.name "${GITHUB_ACTOR}"
git add .

if [ "$(git status -s | wc -l)" -gt 0 ]; then
  git commit --allow-empty --all --message "check in scms build [$GITHUB_SHA]" \
      && git push --force-with-lease origin "${TARGETBRANCH}"
  exit 0
fi

# no new files. check emptycommit.
if [ "${INPUT_EMPTYCOMMIT}" = "true" ]; then
  git commit --allow-empty --all --message "check in scms build [$GITHUB_SHA]" \
   && git push --force-with-lease origin "${TARGETBRANCH}"
fi
