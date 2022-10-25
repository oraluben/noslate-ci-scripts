#!/usr/bin/env bash

set -e

DIRNAME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPO_ROOT="$(dirname "$(dirname $DIRNAME)")"

HELP=$(cat <<END
report-pr-status.sh --state <name:ref> [name:ref]...
END
)

PROJ=()
# Can be one of: error, failure, pending, success
STATE=pending
while [ $# -gt 0 ]; do
case $1 in
'--help')
  printf $HELP
  exit
  ;;
'--root')
  REPO_ROOT=$2
  shift
  ;;
'--state')
  STATE=$2
  shift
  ;;
*)
  PROJ+=($1)
  ;;
esac
shift
done

cd $REPO_ROOT

if [ -z "$PROJ" ]; then
 exit
fi

if [ -z "$GITHUB_TOKEN" ]; then
  printf "\$GITHUB_TOKEN is not set."
  exit 1
fi

for proj in ${PROJ[@]}; do
  segments=(${proj//:/ })
  # Message of refs/pull/<pr-id>/merge, e.g.
  # Merge d02ea877346b12dc668f013ed627f5db3e0c25e8 into 1bc0af76fd45d7ba754a83c40c00e44bf0614246
  SCRIPTS=$(cat <<-END
    git merge --abort
    git rebase --abort
    SHA=\$(git log --format=%B -n 1 HEAD | cut -d " " -f 2)
    curl \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      https://api.github.com/repos/noslate-project/${segments[0]}/statuses/\$SHA \
      -d "{\"state\":\"$STATE\",\"target_url\":\"$BUILD_URL\",\"context\":\"continuous-integration/$JOB_BASE_NAME\"}"
END
)
  repo forall ${segments[0]} -c "bash -c '$SCRIPTS'"
done
