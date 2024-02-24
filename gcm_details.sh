#!/bin/bash

#0 - Calculate Execution Time
start=$SECONDS

#0 - Credentials
#Apache Guacamole
GCMSERVER=$1
GCMUSR=$2
GCMPWD=$3

echo $GCMSERVER $GCMUSR $GCMPWD

#1 - Authentication
export TOKEN=$(curl -s -k -X POST  https://$GCMSERVER/api/tokens -d 'username='$GCMUSR'&password='$GCMPWD'' | jq -r .authToken)
echo ====================================================

#2 - Retrieve Connection Details with IP Addresses
echo ./gcmdetails.sh $GCMSERVER $GCMUSR $GCMPWD $4

filename=$4
while IFS= read -r CONNECTIONID;
do
filename=$4
while IFS= read -r CONNECTIONID;
do
CHECKCONNECTIONID=$(cat ./files/gcm.json | jq --arg CONNECTIONID "$CONNECTIONID" '.[$CONNECTIONID].name' | tr -d '"')
CHECKCONNECTIONPROTOCOL=$(cat ./files/gcm.json | jq --arg CONNECTIONID "$CONNECTIONID" '.[$CONNECTIONID].protocol' | tr -d '"')
CHECKCONNECTIONIP=$(curl -s -k -X GET -H 'Content-Type: application/json' https://$GCMSERVER/api/session/data/postgresql/connections/$CONNECTIONID/parameters?token=$TOKEN | jq .hostname | tr -d '"')
echo $CONNECTIONID,$CHECKCONNECTIONID,$CHECKCONNECTIONIP,$CHECKCONNECTIONPROTOCOL >> ./files/gcm_connections.file
echo $CONNECTIONID,$CHECKCONNECTIONID,$CHECKCONNECTIONIP,$CHECKCONNECTIONPROTOCOL
end=$SECONDS
duration=$((end - start))
echo "Execution time: $duration seconds"
done < "$filename"
