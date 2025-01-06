#! /bin/bash

outputFile="isp_mon_outages.csv"
rawLogFile="isp_mon_raw.log"
collateTempFile="isp_mon_collate_tmp.log"
collateLastFile="isp_mon_collate_last.log"

declare currLog
declare nextLog

function currentFromLast() {
    IFS=',' read -r -a currLog < $collateLastFile
}

function currentFromNext() {
    for (( j = 0; j < ${#currLog[@]}; j++ ))
    do
      currLog[j]=${nextLog[j]}
    done
}

function statusChanged() {
    for (( j = 1; j < ${#currLog[@]}; j++ ))
    do
      if [ ${currLog[j]} -ne ${nextLog[j]} ]; then
        return 1
      fi
    done
    return 0
}

function currentIsUp() {
    for (( j = 1; j < ${#currLog[@]}; j++ ))
    do
      if [ ${currLog[j]} -ne 1 ]; then
        return 0
      fi
    done
    return 1
}

function nextIsUp() {
    for (( j = 1; j < ${#nextLog[@]}; j++ ))
    do
      if [ ${nextLog[j]} -ne 1 ]; then
        return 0
      fi
    done
    return 1
}

function statusIsUp() {
    local statusArr=("$@")
    for (( j = 1; j < ${#statusArr[@]}; j++ ))
    do
      if [ ${statusArr[j]} -ne 1 ]; then
        return 0
      fi
    done
    return 1
}

function writeOutage() {
    echo -n "${currLog[0]}" >> $outputFile
    echo -n ",${nextLog[0]}" >> $outputFile
    for (( j = 1; j < ${#currLog[@]}; j++ ))
    do
      echo -n ",${currLog[j]}" >> $outputFile
    done
    echo "" >> $outputFile

}

function writeLast() {
    echo -n "${currLog[0]}" > $collateLastFile
    for (( j = 1; j < ${#currLog[@]}; j++ ))
    do
      echo -n ",${currLog[j]}" >> $collateLastFile
    done
    echo "" >> $collateLastFile

}

# Overwrite temp with raw and start new raw
mv -f $rawLogFile $collateTempFile

currentFromLast

cat $collateTempFile | {
while IFS="," read -ra nextLog
do
    #check status change
    statusChanged
    # if no status change
    if [[ $? -eq 0 ]]; then
        currentIsUp
        # if uptime continues
        if [[ $? -eq 1 ]]; then
            currentFromNext
        fi
        # no update if outage continues

    # else status change
    else
        currentIsUp
        # if outage end
        if [[ $? -eq 0 ]]; then
            writeOutage
        fi
        # if up or different outage just set next
        currentFromNext
    fi
done

# write last current to file for next run
writeLast
}

#clean up tmp file
rm -f $collateTempFile
