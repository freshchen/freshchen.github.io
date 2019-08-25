#!/usr/bin/env bash

current_path=$(cd "$(dirname "$0")"; pwd)
cd ${current_path}
status=$(git pull)
if [[ ${status} == "Already up to date." ]]; then
    echo 'Start to push.'
    git add ./docs/ || exit 1
    git commit -m 'notes' || exit 1
    git push origin master || exit 1
    echo 'Push successfully.'
else
    echo 'Need merge.'
fi