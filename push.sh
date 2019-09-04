#!/usr/bin/env bash

CURRENT_PATH=$(cd "$(dirname "$0")"; pwd)
if [[ $# -eq 0 ]] ; then
    COMMENT="update"
else
    COMMENT=$*
fi
cd ${CURRENT_PATH}


pre_check() {
    local status=$(git pull)
    if [[ ${status} == "Already up to date." ]]; then
        echo 'Pre-Check successfully.'
    else
        echo 'Need merge.'
        exit 1
    fi
}

post_push() {
    echo 'Start to push.'
    git add ./blogs/ || exit 1
    git add ./notes/ || exit 1
    git add ./push.sh || exit 1
    git commit -m "${COMMENT}" || exit 1
    git push origin master || exit 1
    echo 'Push successfully.'
}

main() {
    pre_check
    post_push
}

main