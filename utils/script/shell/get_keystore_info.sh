#! /bin/bash

LOG=/var/log/find/keystore/info.log
cd /
INFO=$(find / -name *.keystore 2>/dev/null)

for path in ${INFO[@]}
do
echo ${path} >> ${LOG}
${JAVA_HOME}/bin/keytool -v -list -storepass <password> -keystore ${path}  2>/dev/null | grep -E "Alias name|Owner:" >> ${LOG}
done
