#!/usr/bin/env bash

set -ex

DIRNAME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPO_ROOT="$(dirname "$(dirname $DIRNAME)")"

HELP=$(cat <<END
download-pr.sh <name:ref> [name:ref]...
END
)

PROJ=()
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

for proj in ${PROJ[@]}; do
  segments=(${proj//:/ })
  SCRIPTS=$(cat <<-END
    set -x
    git merge --abort
    git rebase --abort
    set -e
    git fetch origin refs/pull/${segments[1]}/merge
    git checkout FETCH_HEAD
END
)
  repo forall ${segments[0]} -c "bash -c '$SCRIPTS'"
done
