#! /bin/bash

declare -A targets
get_wait=0.450

cat config_curl | shuf -n 3 | {
idx=1
while IFS=" " read -r targ
do
    targets[$((idx++))]=$targ
done

#echo "url\texitcode\tresponse_code\ttime_total" > curl_test.csv

for target in "${targets[@]}"
do

#curl -m $get_wait -w "%{url}\t%{exitcode}\t%{response_code}\t%{time_total}\n" -o /dev/null -s $target >> curl_test.csv

if curl --interface $1 -m $get_wait -o /dev/null -s $target
then
    echo "$2,$1,curl,1" >> isp_mon.tmp
    exit
fi
done

echo "$2,$1,curl,0" >> isp_mon.tmp

}
