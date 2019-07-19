#!/bin/bash

MODE=""
KEYTOOL="${JAVA_HOME}/bin/keytool"
OPENSSL="/usr/bin/openssl"
PASSWORD=""
EXPIRATION_TIME="3650"
KEY_LENGTH="2048"
CERTIFICATE_TYPE="pkcs12"
KEY_TYPE="des3"
PRIVATE_PATH="/var/tmp/trial/keystore/private/"
CRT_PATH="/var/tmp/trial/keystore/crt/"
KEYSTORE_PATH="/var/tmp/trial/keystore/"

generate_ca_trust_keystore() {

    local CERTIFICATE_NAME="CA"
    CA_KEY_PATH="${PRIVATE_PATH}${CERTIFICATE_NAME}.key"
    CA_PEM_PATH="${CRT_PATH}${CERTIFICATE_NAME}.pem"
    local COMMON_NAME=""
    local CA_CSR_PATH="${PRIVATE_PATH}${CERTIFICATE_NAME}.csr"
    local CA_P12_PATH="${CRT_PATH}${CERTIFICATE_NAME}.p12"
    local CA_KEYSTORE_PATH="${KEYSTORE_PATH}${CERTIFICATE_NAME}.keystore"
    local SUBJECT_INFO="/C=/ST=/L=/O=/OU=/CN=${COMMON_NAME}/emailAddress="

    ${OPENSSL} genrsa -${KEY_TYPE} -passout pass:${PASSWORD} -out ${CA_KEY_PATH} ${KEY_LENGTH} || exit 1
    ${OPENSSL} req -new -key ${CA_KEY_PATH} -out ${CA_CSR_PATH} -subj "${SUBJECT_INFO}" -passin pass:${PASSWORD} || exit 1
    ${OPENSSL} x509 -req -sha256 -days ${EXPIRATION_TIME} -in ${CA_CSR_PATH} -out ${CA_PEM_PATH} -signkey ${CA_KEY_PATH} -CAcreateserial -passin pass:${PASSWORD} || exit 1
    ${OPENSSL} ${CERTIFICATE_TYPE} -export -clcerts -in ${CA_PEM_PATH} -inkey ${CA_KEY_PATH} -out ${CA_P12_PATH} -name ${CERTIFICATE_NAME} -passin pass:${PASSWORD} -password pass:${PASSWORD} || exit 1
    ${KEYTOOL} -importkeystore -trustcacerts -deststoretype ${CERTIFICATE_TYPE} -srcstoretype ${CERTIFICATE_TYPE} -srckeystore ${CA_P12_PATH} -destkeystore ${CA_KEYSTORE_PATH} -alias ${CERTIFICATE_NAME} -deststorepass ${PASSWORD} -destkeypass ${PASSWORD} -srcstorepass ${PASSWORD} || exit 1
}

generate_server_client_keystore() {

    local CERTIFICATE_NAME=$1
    local COMMON_NAME=$2
    local KEY_PATH="${PRIVATE_PATH}${CERTIFICATE_NAME}.key"
    local CSR_PATH="${PRIVATE_PATH}${CERTIFICATE_NAME}.csr"
    local P12_PATH="${CRT_PATH}${CERTIFICATE_NAME}.p12"
    local KEYSTORE_PATH="${KEYSTORE_PATH}${CERTIFICATE_NAME}.keystore"
    local PEM_PATH="${CRT_PATH}${CERTIFICATE_NAME}.pem"
    local SUBJECT_INFO="/C=/ST=/L=/O=/OU=/CN=${COMMON_NAME}/emailAddress="

    ${OPENSSL} genrsa -${KEY_TYPE} -passout pass:${PASSWORD} -out ${KEY_PATH} ${KEY_LENGTH} || exit 1
    ${OPENSSL} req -new -key ${KEY_PATH} -out ${CSR_PATH} -subj "${SUBJECT_INFO}" -passin pass:${PASSWORD} || exit 1
    ${OPENSSL} x509 -req -sha256 -days ${EXPIRATION_TIME} -in ${CSR_PATH} -out ${PEM_PATH} -signkey ${KEY_PATH} -CAkey ${CA_KEY_PATH} -CA ${CA_PEM_PATH} -CAcreateserial -passin pass:${PASSWORD} || exit 1
    ${OPENSSL} ${CERTIFICATE_TYPE} -export -clcerts -in ${PEM_PATH} -inkey ${KEY_PATH} -out ${P12_PATH} -name ${CERTIFICATE_NAME} -passin pass:${PASSWORD} -password pass:${PASSWORD} || exit 1
    ${KEYTOOL} -importkeystore -trustcacerts -deststoretype ${CERTIFICATE_TYPE} -srcstoretype ${CERTIFICATE_TYPE} -srckeystore ${P12_PATH} -destkeystore ${KEYSTORE_PATH} -alias ${CERTIFICATE_NAME} -deststorepass ${PASSWORD} -destkeypass ${PASSWORD} -srcstorepass ${PASSWORD} || exit 1
}

install_keystore(){

    if [[ ! ${MODE} == "MODE1" ]] && [[ ! ${MODE} == "2" ]]
    then
        exit 1
    fi

    mkdir -p ${PRIVATE_PATH} ${CRT_PATH} ${KEYSTORE_PATH}

    ${MODE}_install_keystore
}

MODE1_install_keystore() {

    generate_ca_trust_keystore

    local CERTIFICATE_NAME_LIST=("" "" "" "" "" "" "")
    local COMMON_NAME_LIST=("" "" "" "" "" "" "")

    for (( index = 0; index < ${#CERTIFICATE_NAME_LIST[*]}; ++index )); do
        generate_server_client_keystore ${CERTIFICATE_NAME_LIST[${index}]} "${COMMON_NAME_LIST[${index}]}"
    done

}

print_usage() {
    echo "Usage: $0 [-m]"
    echo ""
}

parse_param() {
    if [[ $# == 0 ]];then
      print_usage
      exit 1
    fi
    while getopts "m:" opt
    do
        case $opt in
        m)
            MODE=$OPTARG
            ;;
        *)
            print_usage
            exit 1
            ;;
        esac
        break
    done
    return 0
}

main(){

    parse_param $@

    install_keystore
}

main $@