#!/bin/bash

#0 - Calculate Execution Time
start=$SECONDS

#0 - Credentials
#Apache Guacamole
GCMSERVER=
GCMUSR=
GCMPWD=

#Checkmk
CMKUSR=
CMKPWD=

#1 - Authentication
export TOKEN=$(curl -s -k -X POST  https://$GCMSERVER/api/tokens -d 'username='$GCMUSR'&password='$GCMPWD'' | jq -r .authToken)
echo ====================================================

#2 - Retrieve connection ids from Apache Guacamole
curl -s -k -X GET -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/connections?token=$TOKEN | jq | grep -o '"identifier":\s*"[0-9]\+"' | tr -d '"identifier": ' > ./files/gcm_ids.file
export IDCOUNT=$(wc -l ./files/gcm_ids.file)
echo Collected IDs: $IDCOUNT
head -n 300 ./files/gcm_ids.file > ./files/gcm_ids_0_300.file
tail -n +301 ./files/gcm_ids.file > ./files/gcm_ids_301+.file
echo ====================================================

#3 - Retrieving connections details (Hostname and Connection Protocol) from Apache Guacamole
curl -s -k -X GET -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/connections?token=$TOKEN | jq > ./files/gcm.json

#4 - Retrieve Connection Details with IP Addresses
./gcm_details.sh $GCMSERVER $GCMUSR $GCMPWD ./files/gcm_ids_0_300.file &
./gcm_details.sh $GCMSERVER $GCMUSR $GCMPWD ./files/gcm_ids_301+.file &
wait








echo ====================================================









echo 3 - Retrieving current hosts from Checkmk
./cmk_gethosts.sh | grep id > ./files/cmk_hosts.file
echo ====================================================
echo 4 - Create connections on Checkmk

filename="./files/gcm_connections.file"

while IFS=',' read -r connectionid name ip protocol; do
if grep -q "$name" ./files/cmk_hosts.file
then
echo Already on Checkmk - Connection ID: $connectionid Name: $name $ip $protocol
else
echo NOT on Checkmk - Connection ID: $connectionid Name: $name $ip $protocol    
./cmk_createhosts.sh $connectionid $name $ip $protocol > ./logs/mklog_$name.log
fi
done < "$filename"

end=$SECONDS
duration=$((end - start))
echo "Execution time: $duration seconds"



exit
echo ===================================================
echo 5 - Activate changes on Checkmk
./cmk_activatechanges.sh
echo ====================================================
echo 6 -Cleanup
echo Removing gcm_ids.file
rm ./files/gcm_ids.file
echo Removing gcm_connections.file
rm ./files/gcm_connections.file
echo Removing cmk_hosts.file
rm ./files/cmk_hosts.file
echo ====================================================
exit
