#!/usr/bin/env bash

check_certificate_expiration() {
    local chect_port_list=$(ss -lnt | awk 'NR!=1' | awk '{print $4}')
    for port in ${chect_port_list[@]} ; do
        local end_time=$(echo 'Q' | timeout 5 openssl s_client -connect ${port} 2>/dev/null | openssl x509 -noout -enddate)
        if [[ ${end_time} == '' ]]; then
            continue
        fi
        local end_time=$(echo ${end_time} | awk -F '=' '{print $2}'| awk -F ' +' '{print $1,$2,$4 }')
        local current_time=$(date | awk -F ' +'  '{print $2,$3,$6}')
        local end_time_format=$(date +%s -d "${end_time}")
        local current_time_format=$(date +%s -d "${current_time}")
        local remaining_end_time=$(($((end_time_format-current_time_format))/(60*60*24)))

        if [[ ${remaining_end_time} -lt 10 ]]; then
            echo ${port} ${remaining_end_time}
        fi
    done
}