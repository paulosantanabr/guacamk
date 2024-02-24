#!/bin/bash

filename=$5
while IFS=',' read -r connectionid name ip protocol; do
if grep -q "$name" ./files/cmk_hosts.file
then
echo Already on Checkmk - Connection ID: $connectionid Name: $name $ip $protocol
else
echo NOT on Checkmk - Connection ID: $connectionid Name: $name $ip $protocol
./cmk_createhosts.sh $connectionid $name $ip $protocol > ./logs/mklog_$name.log
fi
done < "$filename"
