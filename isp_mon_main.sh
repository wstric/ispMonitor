#! /bin/bash

tmpLogFile="isp_mon.tmp"
rawLogFile="isp_mon_raw.log"

declare -A interfaces
declare -A results
now=$(date -u +"%FT%TZ")
tests=2;

>$tmpLogFile

cat config_interfaces | {
idx=1
while IFS=" " read -r interface
do
    #echo $interface $idx
    interfaces[$idx]=$interface
    ((idx++))

done

idx=1
for i in "${!interfaces[@]}"
do
    ./isp_mon_ping.sh "${interfaces[$i]}" $((($i-1)*$tests+1)) &
    ./isp_mon_curl.sh "${interfaces[$i]}" $((($i-1)*$tests+2)) &
    #./isp_mon_dns.sh "${interfaces[$i]}" $((($i-1)*$tests+3)) &
done

wait

}

cat $tmpLogFile | {
idx=1
while IFS="," read -r idx interface method result
do
 #echo "$idx $interface $method $result"
 results[$idx]=$result
done

log_result=$now
for (( j = 1; j <= ${#results[@]}; j++ ))
do
    log_result="$log_result,${results[$j]}"
done

echo $log_result >> $rawLogFile

}

#clean up tmp file
rm -f $tmpLogFile
