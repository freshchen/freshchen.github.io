#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
    comment="update"
else
    comment=$*
fi
current_path=$(cd "$(dirname "$0")"; pwd)
cd ${current_path}
status=$(git pull)
if [[ ${status} == "Already up to date." ]]; then
    echo 'Start to push.'
    git add ./docs/ || exit 1
    git commit -m "${comment}" || exit 1
    git push origin master || exit 1
    echo 'Push successfully.'
else
    echo 'Need merge.'
fi