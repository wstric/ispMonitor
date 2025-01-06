#! /bin/bash

declare -A targets
ping_wait=0.300

#echo ping test $1
#echo "$2,$1,ping,$2-$(($(date -u +"%N")/1000000))" >> isp_mon.tmp

cat config_ping | shuf -n 3 | {
idx=1
while IFS=" " read -r targ
do
    #echo $interface $idx
    targets[$((idx++))]=$targ
done

for target in "${targets[@]}"
do
#echo "$2,$1,ping,$target"
if ping -I $1 -c 1 -W $ping_wait $target &> /dev/null
then
    echo "$2,$1,ping,1" >> isp_mon.tmp
    exit
fi
done

echo "$2,$1,ping,0" >> isp_mon.tmp

}
